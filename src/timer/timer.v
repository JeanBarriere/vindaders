module timer

import time

pub struct Timer {
pub mut:
	duration  time.Duration
	time_left time.Duration
	ready     bool
}

pub fn from_millis(ms u16) Timer {
	duration := time.Duration(ms * time.millisecond)
	return Timer{
		duration: duration
		time_left: duration
		ready: false
	}
}

pub fn (mut self Timer) reset() {
	self.ready = false
	self.time_left = self.duration
}

pub fn (mut self Timer) update(delta time.Duration) {
	if self.ready {
		return
	}
	if self.time_left.milliseconds() - delta.milliseconds() < 0 {
		self.ready = true
	} else {
		self.time_left -= delta
	}
}
