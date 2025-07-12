package main

import "core:fmt"
import "core:os"

main :: proc() {
	input_char_buffer: [1]u8 // 1 byte
	for {
		bytes_read, err := os.read(os.stdin, input_char_buffer[:])
		if err != nil {
			fmt.printf("err reading input char: %v\n", err)
			os.exit(1)
		} else if bytes_read != 1 {
			fmt.printf("bytes read != 1, bytes_read:%v\n", bytes_read)
			os.exit(1)
		}
		fmt.printf("\nchar: %c (%v)\n", input_char_buffer[0], input_char_buffer[0])
		//os.write(os.stdout, input_char_buffer[:])
	}
}

