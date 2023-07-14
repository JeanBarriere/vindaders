module player

import frame

[noinit]
pub struct Player {
mut:
	x usize
	y usize
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

// implement Drawable
pub fn (mut player Player) draw(mut f frame.Frame) {
	f[player.x][player.y] = 'A'
}
