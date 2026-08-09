class_name PNM extends Resource

enum Magic {
	UNKNOWN = 0,
	PBM_PLAIN = 0x5031, # P1
	PGM_PLAIN = 0x5032, # P2
	PPM_PLAIN = 0x5033, # P3
	PBM = 0x5034, # P4
	PGM = 0x5035, # P5
	PPM = 0x5036, # P6
}

static func create_from_data(data: PackedByteArray) -> PNM:
	return PNMParser.new().parse(data)

var _magic := Magic.UNKNOWN
var _width := 0
var _height := 0
var _maxval := 0
var _pixels: PackedByteArray

var pixel_count: int:
	get: return _width * _height

var byte_count_per_pixel: int:
	get: return 3

var image_format: Image.Format:
	get: return Image.Format.FORMAT_RGB8

func info() -> void:
	var desc := "unknown"
	match self._magic:
		Magic.PBM_PLAIN:
			desc = "P1, Portable Bit Map(Plain)"
		Magic.PGM_PLAIN:
			desc = "P2, Portable Gray Map(Plain)"
		Magic.PPM_PLAIN:
			desc = "P3, Portable Pixel Map(Plain)"
		Magic.PBM:
			desc = "P4, Portable Bit Map"
		Magic.PGM:
			desc = "P5, Portable Gray Map"
		Magic.PPM:
			desc = "P6, Portable Pixel Map"
		_:
			print(desc)
			return
	print("format: %s\n width: %d\nheight: %d\nmaxval: %d\n" % [desc, self._width, self._height, self._maxval])
