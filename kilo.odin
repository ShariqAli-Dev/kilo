package main

import "core:c/libc"
import "core:fmt"
import "core:os"
import "core:sys/posix"


orig_termios: posix.termios
C_RETURN_SUCCESS :: 0

EnableRawModeError :: union {
	GenericError,
}

GenericError :: struct {
	msg: string,
}


main :: proc() {
	if err := enable_raw_mode(); err != nil {
		fmt.eprintln(err.(GenericError).msg)
		os.exit(1)
	}

	for {
		input_char_buffer := [1]u8{0} // 1 byte
		bytes_read, err := os.read(os.stdin, input_char_buffer[:])
		if err != nil {
			fmt.eprintf("err reading input char: %v\n", err)
			os.exit(1)
		} else if bytes_read > 1 {
			fmt.eprintf("bytes read > 1, bytes_read:%v\n", bytes_read)
			os.exit(1)
		}

		input_char_ascii := input_char_buffer[0]
		// returns 0 if not control_charecter
		if libc.iscntrl(i32(input_char_ascii)) != 0 {
			fmt.printf("%d\r\n", input_char_ascii)
		} else {
			fmt.printf("%d ('%c')\r\n", input_char_ascii, input_char_ascii)
		}
		if input_char_ascii == 'q' do os.exit(0)
	}
}

disable_raw_mode :: proc "c" () {
	if res := posix.tcsetattr(posix.STDIN_FILENO, .TCSAFLUSH, &orig_termios); res == .FAIL {
		// odin: cstring == c: ^u8  == *char
		posix.perror("error failed to disable raw mode")
		posix.exit(1)
	}
}

enable_raw_mode :: proc() -> EnableRawModeError {
	if res_getattr := posix.tcgetattr(posix.STDIN_FILENO, &orig_termios); res_getattr == .FAIL {
		return GenericError{msg = "error getting terminal params"}
	}

	// calls disable_raw_mode at program exit
	if res_atexit := posix.atexit(disable_raw_mode); res_atexit != C_RETURN_SUCCESS {
		return GenericError{msg = "error setting atexit to disable_raw_mode"}
	}

	raw: posix.termios = orig_termios
	/*
	// when i say *disable*, it means what we are doing. we are doing the disabling, these flags exist is is

	- ISIG disabling sigint terminate & suspend (ctrl-c & ctrl-v)
	- IXON disabling software contrel flow, stop & continue (ctrl-s & ctrl-v)
	- IEXTEN if you suspend w/ ctrl-s, you can still do ctrl-c to close before resuming w/ ctr-q
	- ICRNL ctrl-m and ctr-j carriage return & new line, disableds that
	- OPOST all outputs appended with \r\n. moves to first char, and then new line. disables that.
	*/
	// misc flags  (no observable effects) either off or legacy
	raw.c_iflag &= ~({.BRKINT} | {.INPCK} | {.ISTRIP})
	raw.c_cflag |= {.CS8}

	raw.c_iflag &= ~({.ICRNL} | {.IXON})
	raw.c_oflag &= ~{.OPOST}
	raw.c_lflag &= ~({.ECHO} | {.ICANON} | {.ISIG} | {.IEXTEN})
	raw.c_cc[.VMIN] = 0 // min input bytes  before read() can return
	raw.c_cc[.VTIME] = 1 // max time in tents of second before read() times out


	if res_setattr := posix.tcsetattr(posix.STDIN_FILENO, .TCSAFLUSH, &raw); res_setattr == .FAIL {
		return GenericError{msg = "error disabling raw mode"}
	}
	return nil
}
