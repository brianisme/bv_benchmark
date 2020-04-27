ruby-build:
	cd ruby && bundle
ruby-bm: ruby-build
	ruby ruby/main.rb

js-build:
	cd js && yarn
js-bm: js-build
	node js/index.js

py-build:
	cd python && pip install -r requirements.txt
py-bm: py-build
	python python/main.py