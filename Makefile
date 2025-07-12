build:
	@odin build . -out=./bin/kilo
run: build
	@./bin/kilo
