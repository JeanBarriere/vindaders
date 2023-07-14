module events

pub enum KeyCode {
	@none = 0
	tab = 9
	enter = 10
	escape = 27
	space = 32
	backspace = 127
	exclamation = 33
	double_quote = 34
	hashtag = 35
	dollar = 36
	percent = 37
	ampersand = 38
	single_quote = 39
	left_paren = 40
	right_paren = 41
	asterisk = 42
	plus = 43
	comma = 44
	minus = 45
	period = 46
	slash = 47
	_0 = 48
	_1 = 49
	_2 = 50
	_3 = 51
	_4 = 52
	_5 = 53
	_6 = 54
	_7 = 55
	_8 = 56
	_9 = 57
	colon = 58
	semicolon = 59
	less_than = 60
	equal = 61
	greater_than = 62
	question_mark = 63
	at = 64
	a = 97
	b = 98
	c = 99
	d = 100
	e = 101
	f = 102
	g = 103
	h = 104
	i = 105
	j = 106
	k = 107
	l = 108
	m = 109
	n = 110
	o = 111
	p = 112
	q = 113
	r = 114
	s = 115
	t = 116
	u = 117
	v = 118
	w = 119
	x = 120
	y = 121
	z = 122
	left_square_bracket = 91
	backslash = 92
	right_square_bracket = 93
	caret = 94
	underscore = 95
	backtick = 96
	left_curly_bracket = 123
	vertical_bar = 124
	right_curly_bracket = 125
	tilde = 126
	insert = 260
	delete = 261
	up = 262
	down = 263
	right = 264
	left = 265
	page_up = 266
	page_down = 267
	home = 268
	end = 269
	f1 = 290
	f2 = 291
	f3 = 292
	f4 = 293
	f5 = 294
	f6 = 295
	f7 = 296
	f8 = 297
	f9 = 298
	f10 = 299
	f11 = 300
	f12 = 301
	f13 = 302
	f14 = 303
	f15 = 304
	f16 = 305
	f17 = 306
	f18 = 307
	f19 = 308
	f20 = 309
	f21 = 310
	f22 = 311
	f23 = 312
	f24 = 313
}

[flag]
pub enum Modifiers {
	@none
	ctrl
	shift
	alt
}

[noinit]
pub struct KeyboardEvent {
pub:
	code      KeyCode
	modifiers Modifiers
	bytes     []u8
}

fn to_key_code(ch u8) KeyCode {
	unsafe {
		code := KeyCode(ch)
		if code != nil {
			return code
		}
		return KeyCode(0)
	}
}

fn key_down(ch u8) KeyboardEvent {
	mut event := KeyboardEvent{
		bytes: [ch]
		code: to_key_code(ch)
	}

	match ch {
		// special handling for `ctrl + letter`
		// TODO: Fix assoc in V and remove this workaround :/
		// 1  ... 26 { event = Event{ ...event, code: KeyCode(96 | ch), modifiers: .ctrl  } }
		// 65 ... 90 { event = Event{ ...event, code: KeyCode(32 | ch), modifiers: .shift } }
		// The bit `or`s here are really just `+`'s, just written in this way for a tiny performance improvement
		// don't treat tab, enter as ctrl+i, ctrl+j
		1...8, 11...26 {
			event = KeyboardEvent{
				...event
				code: unsafe { KeyCode(96 | ch) }
				modifiers: .ctrl
			}
		}
		65...90 {
			event = KeyboardEvent{
				...event
				code: unsafe { KeyCode(32 | ch) }
				modifiers: .shift
			}
		}
		else {}
	}

	return event
}

fn keyboard_event(buf string) KeyboardEvent {
	if buf.len <= 1 {
		return key_down(buf[0] or { 0 })
	}

	// ----------------------------
	//   Special key combinations
	// ----------------------------

	mut code := KeyCode.@none
	mut modifiers := Modifiers.@none
	match buf[1..] {
		'[A', 'OA' { code = .up }
		'[B', 'OB' { code = .down }
		'[C', 'OC' { code = .right }
		'[D', 'OD' { code = .left }
		'[5~', '[[5~' { code = .page_up }
		'[6~', '[[6~' { code = .page_down }
		'[F', 'OF', '[4~', '[[8~' { code = .end }
		'[H', 'OH', '[1~', '[[7~' { code = .home }
		'[2~' { code = .insert }
		'[3~' { code = .delete }
		'OP', '[11~' { code = .f1 }
		'OQ', '[12~' { code = .f2 }
		'OR', '[13~' { code = .f3 }
		'OS', '[14~' { code = .f4 }
		'[15~' { code = .f5 }
		'[17~' { code = .f6 }
		'[18~' { code = .f7 }
		'[19~' { code = .f8 }
		'[20~' { code = .f9 }
		'[21~' { code = .f10 }
		'[23~' { code = .f11 }
		'[24~' { code = .f12 }
		else {}
	}

	if buf[1..] == '[Z' {
		code = .tab
		modifiers.set(.shift)
	}

	if buf.len == 5 && buf[0] == `[` && buf[1].is_digit() && buf[2] == `;` {
		match buf[3] {
			`2` { modifiers = .shift }
			`3` { modifiers = .alt }
			`4` { modifiers = .shift | .alt }
			`5` { modifiers = .ctrl }
			`6` { modifiers = .ctrl | .shift }
			`7` { modifiers = .ctrl | .alt }
			`8` { modifiers = .ctrl | .alt | .shift }
			else {}
		}

		if buf[1] == `1` {
			match buf[4] {
				`A` { code = KeyCode.up }
				`B` { code = KeyCode.down }
				`C` { code = KeyCode.right }
				`D` { code = KeyCode.left }
				`F` { code = KeyCode.end }
				`H` { code = KeyCode.home }
				`P` { code = KeyCode.f1 }
				`Q` { code = KeyCode.f2 }
				`R` { code = KeyCode.f3 }
				`S` { code = KeyCode.f4 }
				else {}
			}
		} else if buf[1] == `5` {
			code = KeyCode.page_up
		} else if buf[1] == `6` {
			code = KeyCode.page_down
		}
	}

	return KeyboardEvent{
		code: code
		bytes: buf.bytes()
		modifiers: modifiers
	}
}
