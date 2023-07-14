module terminal

import term.termios

const termios_at_startup = get_termios()

[inline]
fn get_termios() termios.Termios {
	mut t := termios.Termios{}
	termios.tcgetattr(C.STDIN_FILENO, mut t)
	return t
}

pub fn enable_raw_mode() {
	// store the current title, so restore_terminal_state can get it back
	save_title()
	// Set raw input mode by unsetting ICANON and ECHO
	mut tios := get_termios()

	// tios.c_lflag &= termios.invert(C.ICANON | C.ECHO)

	tios.c_iflag &= termios.invert(C.IGNBRK | C.BRKINT | C.PARMRK | C.IXON)
	tios.c_lflag &= termios.invert(C.ICANON | C.ISIG | C.ECHO | C.IEXTEN | C.TOSTOP)

	tios.c_cc[C.VTIME] = 0
	tios.c_cc[C.VMIN] = 0
	termios.tcsetattr(C.STDIN_FILENO, C.TCSAFLUSH, mut tios)

	print('\x1b[?1003h\x1b[?1006h')
	flush_stdout()

	C.atexit(reset_terminal_state)
}

fn reset_terminal_state() {
	disable_raw_mode()
	stdout().execute(LeaveAlternateScreen{})
	stdout().execute(ShowCursor{})
}

pub fn disable_raw_mode() {
	print('\x1b[?1003l\x1b[?1006l')
	flush_stdout()

	mut startup := terminal.termios_at_startup
	termios.tcsetattr(C.STDIN_FILENO, C.TCSAFLUSH, mut startup)

	load_title()
}

[inline]
fn save_title() {
	// restore the previously saved terminal title
	print('\x1b[22;0t')
	flush_stdout()
}

[inline]
fn load_title() {
	// restore the previously saved terminal title
	print('\x1b[23;0t')
	flush_stdout()
}
