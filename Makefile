build:
	@odin build . -out=./bin/kilo
build-debug:
	@odin build . -out=./bin/kilo-debug -debug -o:none

run: build
	@./bin/kilo

debug: build-debug
	@gdb ./bin/kilo

.PHONY: debug
