all: build


lib/%.js: src/%.coffee
	@mkdir -p lib
	coffee -o lib -c $?


build: lib/pengine.js lib/test.js

clean:
	rm -rf lib

reset: clean
	rm -rf node_modules

dist: clean build

install:
	npm install -g

uninstall:
	npm uninstall -g pengine

publish: dist
	npm publish

pack: dist
	npm pack
