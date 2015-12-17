all: test

heroku-buildpack-testrunner/:
	git clone git@github.com:heroku/heroku-buildpack-testrunner.git
	docker build --tag heroku/testrunner heroku-buildpack-testrunner

test: heroku-buildpack-testrunner/
	docker run --rm --interactive --tty=true --volume $(shell pwd):/app/buildpack:ro heroku/testrunner
