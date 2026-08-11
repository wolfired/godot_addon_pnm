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

func read_pixels4pbm_ascii(pixels: PackedByteArray) -> void:
	var sz := pixels.size()
	for o in range(0, sz, 3):
		self.forward(is_ascii_digit)
		
		var color := 0x0 if 0x1 == self.read_ascii_decimal() else 0xff
		
		pixels[o + 0] = color
		pixels[o + 1] = color
		pixels[o + 2] = color

func read_pixels4pbm(width:int, height:int, pixels: PackedByteArray) -> void:
	self._pos += 1
	var data := self._data.slice(self._pos)
	self._pos += ((width + 7) >> 3) * height
	
	var o := 0
	for row in height:
		var bas := ((width + 7) >> 3) * row
		for col in width:
			var ii := bas + (col >> 3) # bas + col / 8
			var oo := 7 - (col & 7) # 7 - col % 8
			var color := 0x0 if 0x1 == (data[ii] >> oo) & 0x1 else 0xff
			
			pixels[o + 0] = color
			pixels[o + 1] = color
			pixels[o + 2] = color
			
			o += 3

func read_pixels4pgm_ascii(pixels: PackedByteArray) -> void:
	var sz := pixels.size()
	for o in range(0, sz, 3):
		self.forward(is_ascii_digit)
		
		var color := self.read_ascii_decimal()
		
		pixels[o + 0] = color
		pixels[o + 1] = color
		pixels[o + 2] = color

func read_pixels4pgm(pixels: PackedByteArray) -> void:
	self._pos += 1
	
	var sz := pixels.size()
	for o in range(0, sz, 3):
		var color := self.read_i8_be()
		
		pixels[o + 0] = color
		pixels[o + 1] = color
		pixels[o + 2] = color

func read_pixels4ppm_ascii(pixels: PackedByteArray) -> void:
	var sz := pixels.size()
	for o in range(0, sz, 3):
		self.forward(is_ascii_digit)
		
		pixels[o + 0] = self.read_ascii_decimal()
		pixels[o + 1] = self.read_ascii_decimal()
		pixels[o + 2] = self.read_ascii_decimal()

func read_pixels4ppm(pixels: PackedByteArray) -> void:
	self._pos += 1
	
	var sz := pixels.size()
	for o in range(0, sz, 3):
		pixels[o + 0] = self.read_i8_be()
		pixels[o + 1] = self.read_i8_be()
		pixels[o + 2] = self.read_i8_be()

func parse(data: PackedByteArray, pnm: PNM = null) -> PNM:
	self._pos = 0
	self._data = data
	
	if !is_instance_valid(pnm):
		pnm = PNM.new()
	
	pnm._magic = self.read_magic()
	pnm._width = self.read_width()
	pnm._height = self.read_height()
	
	if !is_instance_valid(pnm._pixels):
		pnm._pixels = PackedByteArray()
	pnm._pixels.resize(pnm.pixel_count * pnm.byte_count_per_pixel)
	match pnm._magic:
		PNM.Magic.PBM_PLAIN:
			self.read_pixels4pbm_ascii(pnm._pixels)
		PNM.Magic.PBM:
			self.read_pixels4pbm(pnm._width, pnm._height, pnm._pixels)
		PNM.Magic.PGM_PLAIN:
			pnm._maxval = self.read_maxval()
			self.read_pixels4pgm_ascii(pnm._pixels)
		PNM.Magic.PGM:
			pnm._maxval = self.read_maxval()
			self.read_pixels4pgm(pnm._pixels)
		PNM.Magic.PPM_PLAIN:
			pnm._maxval = self.read_maxval()
			self.read_pixels4ppm_ascii(pnm._pixels)
		PNM.Magic.PPM:
			pnm._maxval = self.read_maxval()
			self.read_pixels4ppm(pnm._pixels)
		_:
			assert(false, "not impl")
	
	return pnm
