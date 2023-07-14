module events

import time

[noinit]
pub struct UnknownEvent {
pub:
	raw string
}

pub type Event = KeyboardEvent | MouseEvent | UnknownEvent | WindowEvent

pub fn event_from_buffer(buf string) &Event {
	if buf.len > 2 && buf[2] == `<` {
		return &Event(mouse_event(buf) or { return &Event(UnknownEvent{buf}) })
	}
	return &Event(keyboard_event(buf))
}

[params]
pub struct PollOptions {
	timeout time.Duration = time.Duration(0)
}

[noinit]
pub struct PollIterator {
	timeout time.Duration
mut:
	halt bool
}

fn (mut iter PollIterator) next() ?&Event {
	if iter.halt {
		return none
	}
	return iter.run()
}

pub fn poll(options PollOptions) PollIterator {
	return PollIterator{
		timeout: options.timeout
	}
}

fn (iter PollIterator) run() ?&Event {
	mut s := ''
	mut sw := time.new_stopwatch(auto_start: true)
	for {
		unsafe {
			buf := malloc_noscan(25)
			len := C.read(C.STDIN_FILENO, buf, 24)
			buf[len] = 0
			s = tos(buf, len)
		}
		if s.len > 0 {
			return event_from_buffer(s)
		}
		if sw.elapsed().microseconds() > iter.timeout.microseconds() {
			break
		}
	}
	return none
}
