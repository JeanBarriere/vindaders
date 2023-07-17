module shot

import time
import timer
import frame

[noinit]
pub struct Shot {
mut:
	timer timer.Timer
pub mut:
	x         usize
	y         usize
	exploding bool
}

pub fn new(x usize, y usize) Shot {
	return Shot{
		x: x
		y: y
		timer: timer.from_millis(50)
	}
}

pub fn (mut shot Shot) update(delta time.Duration) {
	shot.timer.update(delta)
	if !shot.exploding && shot.timer.ready {
		if shot.y > 0 {
			shot.y -= 1
		}
		shot.timer.reset()
	}
}

pub fn (mut shot Shot) explode() {
	shot.exploding = true
	shot.timer = timer.from_millis(250)
}

pub fn (shot Shot) dead() bool {
	return shot.y == 0 || (shot.exploding == true && shot.timer.ready)
}

// implement Drawable
pub fn (shot Shot) draw(mut f frame.Frame) {
	f[shot.x][shot.y] = if shot.exploding { '*' } else { '|' }
}
