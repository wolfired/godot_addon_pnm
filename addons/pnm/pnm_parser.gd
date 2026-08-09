class_name PNMParser

var _pos := 0
var _data: PackedByteArray

var cur_byte: int:
	get:
		var sz := self._data.size()
		return self._data[self._pos] if self._pos < sz else 0

func is_ascii_digit(byte: int) -> bool:
	return 0x30 <= byte && byte <= 0x39

func is_ascii_hash(byte: int) -> bool:
	return 35 == byte

func is_ascii_P(byte: int) -> bool:
	return 80 == byte

func is_ascii_newline(byte: int) -> bool:
	return 10 == byte

func skip_whitespaces() -> void:
	var sz := self._data.size()
	while self._pos < sz:
		if self.is_ascii_digit(self.cur_byte) \
		|| self.is_ascii_hash(self.cur_byte) \
		|| self.is_ascii_P(self.cur_byte):
			break
		else:
			self._pos += 1

func skip_comment() -> void:
	if !self.is_ascii_hash(self.cur_byte):
		return
		
	var sz := self._data.size()
	while self._pos < sz:
		if self.is_ascii_newline(self.cur_byte):
			break
		else:
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
	var i := self._pos + 1
	var sz = self._data.size()
	while i < sz:
		if !self.is_ascii_digit(self._data[i]):
			break
		i += 1
	var val = self._data.slice(self._pos, i).get_string_from_ascii().to_int()
	self._pos = i
	return val

func forward(stop_if: Callable) -> void:
	while !stop_if.call(self.cur_byte):
		self.skip_whitespaces()
		self.skip_comment()

func read_magic() -> PNM.Magic:
	self.forward(is_ascii_P)
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
	var i := 0
	var sz := min(self._data.size() - self._pos, pixels.size())
	while i < sz:
		pixels[i] = c.call()
		i += 1

func parse(data: PackedByteArray, pnm: PNM = null) -> PNM:
	self._pos = 0
	self._data = data
	
	if !is_instance_valid(pnm):
		pnm = PNM.new()
	
	pnm._magic = self.read_magic()
	pnm._width = self.read_width()
	pnm._height = self.read_height()
	pnm._maxval = self.read_maxval()
	
	var c: Callable
	match pnm._magic:
		PNM.Magic.PPM_PLAIN:
			self.forward(is_ascii_digit)
			c = read_ascii_decimal
		PNM.Magic.PPM:
			self.forward(is_ascii_newline)
			self._pos += 1
			c = read_i8_be
		_:
			assert(is_instance_valid(c), "not impl")
	
	if !is_instance_valid(pnm._pixels):
		pnm._pixels = PackedByteArray() 
	pnm._pixels.resize(pnm.pixel_count * pnm.byte_count_per_pixel)
	self.read_pixels(c, pnm._pixels)
	
	return pnm
