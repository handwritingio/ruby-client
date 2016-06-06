default:
	docker run -it --rm --name my-running-script -v "${PWD}":/usr/src/myapp -w /usr/src/myapp ruby:latest ruby main.rb

irb:
	docker run -it --rm --name irb -v "${PWD}":/usr/src/myapp -w /usr/src/myapp ruby:latest irb
