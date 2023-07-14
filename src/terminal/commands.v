module terminal

interface Command {
	execute()
}

[noinit]
struct EnterAlternateScreen {}

fn (_ EnterAlternateScreen) execute() {
	// switch to the alternate buffer
	print('\x1b[?1049h')
	// clear the terminal and set the cursor to the origin
	// print('\x1b[2J\x1b[3J\x1b[1;1H')
	flush_stdout()
}

[noinit]
struct ClearAll {}

fn (_ ClearAll) execute() {
	// switch to the alternate buffer
	print('\x1b[2J')
	// clear the terminal and set the cursor to the origin
	// print('\x1b[2J\x1b[3J\x1b[1;1H')
	flush_stdout()
}

[noinit]
struct LeaveAlternateScreen {}

fn (_ LeaveAlternateScreen) execute() {
	print('\x1b[?1049l')
	flush_stdout()
}

[noinit]
struct Stdout {}

pub fn stdout() Stdout {
	return Stdout{}
}

pub fn (_ Stdout) set_window_title(window_title string) {
	print('\x1b]0;${window_title}\x07')
	flush_stdout()
}

pub fn (_ Stdout) execute(command Command) {
	command.execute()
}

[noinit]
struct HideCursor {}

fn (_ HideCursor) execute() {
	print('\x1b[?25l')
	flush_stdout()
}

[noinit]
struct ShowCursor {}

fn (_ ShowCursor) execute() {
	print('\x1b[?25h')
	flush_stdout()
}

pub const (
	enter_alternate_screen = EnterAlternateScreen{}
	leave_alternate_screen = LeaveAlternateScreen{}
	hide                   = HideCursor{}
	show                   = ShowCursor{}
)
