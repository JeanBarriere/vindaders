module render

import frame

fn move_to(x u16, y u16) {
	print('\x1b[${y + 1};${x + 1}H')
}

pub fn render(last_frame frame.Frame, curr_frame frame.Frame, force bool) {
	if force {
		print('\x1b[48;2;${int(0)};${int(0)};${int(255)}m')
		print('\x1b[2J')
		print('\x1b[48;2;${int(0)};${int(0)};${int(0)}m')
	}

	for col_idx, col in curr_frame {
		for row_idx, text in col {
			if text != last_frame[col_idx][row_idx] || force {
				move_to(u16(col_idx), u16(row_idx))
				print('${text}')
			}
		}
	}
	flush_stdout()
}
