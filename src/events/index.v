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
	fps int = 30
}

pub struct PollIterator {
	fps int
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
		fps: options.fps
	}
}

fn (iter PollIterator) run() &Event {
	mut s := ''
	frame_time := 1_000_000 / iter.fps
	mut sw := time.new_stopwatch(auto_start: false)
	mut sleep_len := 0
	for {
		if sleep_len > 0 {
			time.sleep(sleep_len * time.microsecond)
		}
		sw.restart()
		unsafe {
			buf := malloc_noscan(25)
			len := C.read(C.STDIN_FILENO, buf, 24)
			buf[len] = 0
			s = tos(buf, len)
		}
		if s.len > 0 {
			event := event_from_buffer(s)
			return event
		}
		sleep_len = frame_time - int(sw.elapsed().microseconds())
	}
	return &Event(UnknownEvent{s})
}
