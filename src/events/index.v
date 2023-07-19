module events

import time

[noinit]
pub struct UnknownEvent {
pub:
	raw string
}

pub type Event = KeyboardEvent | MouseEvent | UnknownEvent | WindowEvent

pub fn event_from_buffer(buf string) Event {
	if buf.len > 2 && buf[2] == `<` {
		return Event(mouse_event(buf) or { return Event(UnknownEvent{buf}) })
	}
	return Event(keyboard_event(buf))
}

[params]
pub struct PollOptions {
	timeout time.Duration = time.Duration(0)
}

[noinit]
pub struct PollIterator {
	timeout time.Duration
mut:
	read_buf [25]u8
	halt bool
}

fn (mut iter PollIterator) next() ?Event {
	if iter.halt {
		return none
	}
	return iter.run()
}

pub fn poll(options PollOptions) PollIterator {
	return PollIterator{
		timeout: options.timeout
		read_buf: [25]u8{}
	}
}

fn (mut iter PollIterator) run() ?Event {
	mut sw := time.new_stopwatch(auto_start: true)
	for {
		// buf := os.get_raw_stdin().bytestr
		len := C.read(C.STDIN_FILENO, &iter.read_buf[0], sizeof(iter.read_buf))
		if len > 0 {
			buf := unsafe { tos(&iter.read_buf[0], len) }
			return event_from_buffer(buf)
		}
		if sw.elapsed().microseconds() > iter.timeout.microseconds() {
			break
		}
	}
	return none
}
