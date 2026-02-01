extends RefCounted
class_name EventsStream


class PathSegment:
	extends RefCounted
	
	var points: PackedVector2Array = PackedVector2Array()
	var in_game_times: PackedFloat32Array = PackedFloat32Array()
	
	func start_time() -> float:
		return in_game_times[0]
	
	func end_time() -> float:
		return in_game_times[in_game_times.size() - 1]


class TimelineEntry:
	extends RefCounted
	
	var in_game_time: float
	var label: String
	var icon: String
	
	func _init(p_in_game_time: float, p_label: String, p_icon: String) -> void:
		in_game_time = p_in_game_time
		label = p_label
		icon = p_icon


class MapEntry:
	extends RefCounted
	
	var in_game_time: float
	var label: String
	var icon: String
	var x: float
	var y: float
	
	func _init(p_in_game_time: float, p_label: String, p_icon: String, p_x: float, p_y: float) -> void:
		in_game_time = p_in_game_time
		label = p_label
		icon = p_icon
		x = p_x
		y = p_y

# Events in here are always sorted by in-game time and are only appended to!

var in_game_time_end: float = 0.0  ## The in-game time of the most recent event
var segments: Array[PathSegment] = []
var timeline_entries: Array[TimelineEntry] = []
var map_entries: Array[MapEntry] = []
