module frame

const (
	num_rows = 20
	num_cols = 40
)

pub type Frame = [][]string

pub fn new_frame() Frame {
	mut self := [][]string{}

	for _ in 0 .. frame.num_cols {
		mut col := []string{}
		for _ in 0 .. frame.num_rows {
			col << ' '
		}
		self << col
	}

	return self
}
