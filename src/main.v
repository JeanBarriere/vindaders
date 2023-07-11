module main

import audio as au
import app

fn main() {
	mut audio := au.Player.new()

	audio.add('explode', 'assets/explode.wav')
	audio.add('lose', 'assets/lose.wav')
	audio.add('move', 'assets/move.wav')
	audio.add('pew', 'assets/pew.wav')
	audio.add('startup', 'assets/startup.wav')
	audio.add('win', 'assets/win.wav')
	audio.play('startup')

	// Terminal
	mut game := app.create('V Invaders', audio)

	game.start() or { eprintln('error while rendering ${err}') }
}
