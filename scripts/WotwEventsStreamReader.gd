extends RefCounted
class_name WotwEventsStreamReader


var _data: PackedByteArray
var _reader: StreamReader


func _init(data: PackedByteArray) -> void:
	_data = data
	_reader = StreamReader.new(_data)


func read() -> Array[PackedVector2Array]:
	var lines: Array[PackedVector2Array] = []
	var current_line := PackedVector2Array()
	
	while _reader.available():
		var event_type := _reader.read_u64()
		var event_time := _reader.read_f32()
		
		match event_type:
			0:
				var position := Vector2(_reader.read_f32(), _reader.read_f32())
				current_line.push_back(position)
			1:
				var type := _reader.read_i32()
				var from := Vector2(_reader.read_f32(), _reader.read_f32())
				var to := Vector2(_reader.read_f32(), _reader.read_f32())
				var time_lost := _reader.read_f32()
				
				current_line.push_back(from)
				lines.push_back(current_line)
				current_line = PackedVector2Array()
				current_line.push_back(to)
			2:
				var label := _reader.read_string_with_length()
				var icon := _reader.read_string_with_length()
			3:
				var label := _reader.read_string_with_length()
				var icon := _reader.read_string_with_length()
	return lines
