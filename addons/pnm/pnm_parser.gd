class_name PNMParser

var _pos := 0
var _data: PackedByteArray

func is_ascii_digit(byte: int) -> bool:
	return 0x30 <= byte && byte <= 0x39

func is_ascii_sign_number(byte: int) -> bool:
	return 35 == byte

func is_ascii_uppercase_p(byte: int) -> bool:
	return 80 == byte

func is_ascii_ctrl_line_feed(byte: int) -> bool:
	return 10 == byte

func skip_comment() -> void:
	var sz := self._data.size()
	while self._pos < sz:
		if self.is_ascii_ctrl_line_feed(self._data[self._pos]):
			break
		self._pos += 1

func forward(stop_at: Callable) -> void:
	var sz := self._data.size()
	while self._pos < sz:
		if stop_at.call(self._data[self._pos]): break
		if self.is_ascii_sign_number(self._data[self._pos]):
			self.skip_comment()
			continue
		self._pos += 1

func read_i8_be() -> int:
	var byte = self._data[self._pos]
	self._pos += 1
	return byte

func read_i16_be() -> int:
	var byte_hi := self._data[self._pos]
	var byte_lo := self._data[self._pos + 1]
	self._pos += 2
	return (byte_hi << 8) + byte_lo

func read_ascii_decimal() -> int:
	var pos_pre = self._pos
	self._pos += 1
	var sz = self._data.size()
	while self._pos < sz:
		if !self.is_ascii_digit(self._data[self._pos]): break
		self._pos += 1
	return self._data.slice(pos_pre, self._pos).get_string_from_ascii().to_int()

func read_magic() -> PNM.Magic:
	self.forward(is_ascii_uppercase_p)
	return self.read_i16_be()

func read_width() -> int:
	self.forward(is_ascii_digit)
	return self.read_ascii_decimal()

func read_height() -> int:
	self.forward(is_ascii_digit)
	return self.read_ascii_decimal()

func read_maxval() -> int:
	self.forward(is_ascii_digit)
	return self.read_ascii_decimal()

func read_pixels(c: Callable, pixels: PackedByteArray) -> void:
	var sz := min(self._data.size() - self._pos, pixels.size())
	for i in sz: pixels[i] = c.call()

func parse(data: PackedByteArray, pnm: PNM = null) -> PNM:
	self._pos = 0
	self._data = data
	
	if !is_instance_valid(pnm):
		pnm = PNM.new()
	
	pnm._magic = self.read_magic()
	pnm._width = self.read_width()
	pnm._height = self.read_height()
	pnm._maxval = self.read_maxval()
	
	if !is_instance_valid(pnm._pixels):
		pnm._pixels = PackedByteArray()
	pnm._pixels.resize(pnm.pixel_count * pnm.byte_count_per_pixel)
	var c: Callable
	match pnm._magic:
		PNM.Magic.PPM_PLAIN:
			self.forward(is_ascii_digit)
			c = read_ascii_decimal
		PNM.Magic.PPM:
			self.forward(is_ascii_ctrl_line_feed)
			self._pos += 1
			c = read_i8_be
		_:
			assert(is_instance_valid(c), "not impl")
	self.read_pixels(c, pnm._pixels)
	
	return pnm
