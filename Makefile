DOCKER_PREAMBLE=docker run -it --rm -v "${PWD}":/usr/src/myapp -w /usr/src/myapp ruby:latest

test:
	${DOCKER_PREAMBLE} rake test
.PHONY: test

irb:
	${DOCKER_PREAMBLE} irb
.PHONY: irb

shell:
	${DOCKER_PREAMBLE} bash
.PHONY: shell
