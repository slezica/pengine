Promise = require 'bluebird'


merge = (objects...) ->
  base = {}
  for object in objects
    base[key] = object[key] for own key of object
  base


captureStack = ->
  stack = new Error().stack
  "Task scheduled at:\n" + stack.split('\n')[3...].join('\n')


class Pengine
  Pengine.defaults =
    limit  : 10
    trace  : true
    forward: null

  constructor: (options = {}) ->
    @options = merge(Pengine.defaults, options)
    @pending = []
    @running = 0

  spawn: ->
    while @pending.length > 0 and @running < @options.limit
      { task, accept, reject } = @pending.shift()
      @running++

      process.nextTick =>
        Promise.try(task)
        .then(accept)
        .catch(reject)
        .finally =>
          @running--
          @spawn()

    undefined

  run: (task) ->
    stack = if @options.trace then captureStack() else ""

    if @options.forward?
      @options.forward.run(task)

    else
      new Promise (accept, reject) =>
        @pending.push({ task, accept, reject })
        @spawn()

      .catch (error) ->
        error.stack = "#{error.stack}\n#{stack}"
        throw error

  map: (array, f, $each = ->) ->
    @reduce(array, (results, item) ->
      Promise.try ->
        f(item)

      .then (fitem) ->
        results.push(fitem)
        $each(fitem)
        results
    , [])

  filter: (array, f, $each = ->) ->
    @reduce(array, (results, item) ->
      Promise.try ->
        f(item)

      .then (is_included) ->
        if is_included
          results.push(item)
          $each(item)

        results
    , [])

  reduce: (array, f, initial, $each = ->) ->
    remaining = array.slice()
    current   = initial ? remaining.shift()

    do reduceNext = =>
      if remaining.length > 0
        @run ->
          f(current, remaining.shift())
        .then (value) =>
          current = value
          $each(current)
          reduceNext()
      else
        current

  serial: (tasks) ->


module.exports = Pengine
