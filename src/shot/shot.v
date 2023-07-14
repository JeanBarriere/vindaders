module shot

import time
import frame

[noinit]
pub struct Shot {
mut:
	timer usize
pub mut:
	x         usize
	y         usize
	exploding bool
}

pub fn new(x usize, y usize) Shot {
	return Shot{
		x: x
		y: y
	}
}

pub fn (mut shot Shot) update(delta time.Duration) {
	shot.timer += delta
	if !shot.exploding && shot.timer > (50 * time.millisecond) {
		if shot.y > 0 {
			shot.y -= 1
		}
		shot.timer = 0
	}
}

pub fn (mut shot Shot) explode() {
	shot.exploding = true
	shot.timer = 0
}

pub fn (shot Shot) dead() bool {
	return shot.y == 0 || (shot.exploding == true && shot.timer > (250 * time.millisecond))
}

// implement Drawable
pub fn (shot Shot) draw(mut f frame.Frame) {
	f[shot.x][shot.y] = if shot.exploding { '*' } else { '|' }
}
