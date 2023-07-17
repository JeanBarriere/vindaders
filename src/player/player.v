module player

import frame
import shot
import time

[noinit]
pub struct Player {
mut:
	x     usize
	y     usize
	shots []shot.Shot
}

pub fn new() Player {
	return Player{
		x: frame.num_cols / 2
		y: frame.num_rows - 1
	}
}

pub fn (mut player Player) move_left() {
	if player.x > 0 {
		player.x -= 1
	}
}

pub fn (mut player Player) move_right() {
	if player.x < frame.num_cols - 1 {
		player.x += 1
	}
}

pub fn (mut player Player) shoot() bool {
	if player.shots.len < 2 {
		player.shots << shot.new(player.x, player.y - 1)
		return true
	}
	return false
}

pub fn (mut player Player) update(delta time.Duration) {
	for mut s in player.shots {
		s.update(delta)
	}
	player.shots = player.shots.filter(fn (s shot.Shot) bool {
		return !s.dead()
	})
}

// implement Drawable
pub fn (player Player) draw(mut f frame.Frame) {
	f[player.x][player.y] = 'A'
	for s in player.shots {
		s.draw(mut f)
	}
}
