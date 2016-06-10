DOCKER_PREAMBLE=docker run -it --rm -v "${PWD}":/usr/src/myapp -w /usr/src/myapp ruby:latest

default:
	${DOCKER_PREAMBLE} ruby main.rb
.PHONY: default

irb:
	${DOCKER_PREAMBLE} irb
.PHONY: irb

shell:
	${DOCKER_PREAMBLE} bash
.PHONY: shell

test:
	${DOCKER_PREAMBLE} rake test
.PHONY: test
