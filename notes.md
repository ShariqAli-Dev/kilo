# bitsets

Direction :: enum u8 {
NORTH,
SOUTH,
EAST,
WEST,
}
Direction_Set :: bit_set[Direction;u8]
question:
if each direction is 8bits, how can direction_set, which is also u8, fit all 4 enums values without overflowing?

answer:
key-distinction: Value Vs. Postition
bit_set is not STORING multiple directions. its storing a single u8 where each bit indicates if a direction value is included in the set.

## setting a bit

`raw.c_lflag &= ({.ECHO} | {.ICANON})`  
will always try to enable the bit to positive unless told otherwise with
`raw.c_lflag &= ~({.ECHO} | {.ICANON}) #enables raw mode by disablding canonical & echo`

`raw befor: 00000000000000001000101000111011
raw after: 00000000000000000000000000001010
raw enabled again: 00000000000000000000000000001010`

# terminal modes

## canonical mode || cooked mode

default state of terminal,

- keyboard input sent when enter is pressed
- backspace to fix errors
- enter to send text to the program

## raw mode

disabling many flags

### flags

#### echo

echo mode shows you the key you have typed when you press it
ex. echo mode is off when you use sudo
