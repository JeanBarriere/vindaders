module main

import audio as au

fn main() {
	mut audio := au.Player.new()
	audio.init()

	audio.add('explode', 'assets/explode.wav')
	audio.add('lose', 'assets/lose.wav')
	audio.add('move', 'assets/move.wav')
	audio.add('pew', 'assets/pew.wav')
	audio.add('startup', 'assets/startup.wav')
	audio.add('win', 'assets/win.wav')
	audio.play('startup')

	// cleanup
	audio.stop()
}
