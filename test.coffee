Pengine = require('./pengine')
ng = new Pengine


waitThenPrint = (n) ->
  Promise.delay(n * 20).then ->
    console.log "Finished", n
    return n

# ng.map([1..10], waitThenPrint).then(console.log.bind(null, "map"))
# ng.filter([1..10], ((x) -> x % 2 == 0)).then(console.log.bind(null, "filter"))
# ng.reduce([1, 1, 1, 1, 1], ((x, y) -> x + y)).then(console.log.bind(null, "reduce"))

ng.run ->
  throw new Error "test"

.then console.log
