module invaders

import frame
import timer
import time
import math

[flag]
enum Direction {
	left
	right
}

pub fn (self Direction) value() int {
	return if self == Direction.left { -1 } else { 1 }
}

struct Invader {
pub mut:
	x usize
	y usize
}

[noinit]
struct Invaders {
mut:
	move_timer timer.Timer
	direction  Direction
pub mut:
	army []Invader
}

pub fn new() Invaders {
	mut army := []Invader{}

	for col_idx in 0 .. frame.num_cols {
		for row_idx in 0 .. frame.num_rows {
			if col_idx > 1 && col_idx < frame.num_cols - 2 && row_idx > 0 && row_idx < 9
				&& col_idx % 2 == 0 && row_idx % 2 == 0 {
				army << Invader{col_idx, row_idx}
			}
		}
	}

	return Invaders{
		move_timer: timer.from_millis(2000)
		direction: Direction.right
		army: army
	}
}

pub fn (mut self Invaders) update(delta time.Duration) bool {
	self.move_timer.update(delta)

	if self.move_timer.ready {
		self.move_timer.reset()
		mut downwards := false
		mut positions := self.army.map(fn (i Invader) usize {
			return i.x
		}).clone()
		if self.direction == Direction.left {
			positions.sort(a < b)
			min_x := positions[0] or { 0 }
			if min_x == 0 {
				self.direction = Direction.right
				downwards = true
			}
		} else {
			positions.sort(b < a)
			max_x := positions[0] or { 0 }
			if max_x == frame.num_cols - 1 {
				self.direction = Direction.left
				downwards = true
			}
		}
		if downwards {
			new_duration := u16(math.max(self.move_timer.duration.milliseconds() - 250,
				250))
			self.move_timer = timer.from_millis(new_duration)
			for mut invader in self.army {
				invader.y += 1
			}
		} else {
			for mut invader in self.army {
				invader.x = usize(int(invader.x) + self.direction.value())
			}
		}
		return true
	}
	return false
}

// implement Drawable
pub fn (self Invaders) draw(mut f frame.Frame) {
	for invader in self.army {
		f[invader.x][invader.y] = if f32(self.move_timer.time_left.milliseconds()) / f32(self.move_timer.duration.milliseconds()) > 0.5 {
			'x'
		} else {
			'+'
		}
	}
}
