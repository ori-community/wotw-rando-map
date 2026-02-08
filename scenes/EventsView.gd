extends Node2D
class_name EventsView


const PathSegmentLineScene := preload("res://scenes/PathSegmentLine.tscn")


@onready var segment_lines_container: Node2D = %SegmentLinesContainer


var slice_start_time: float = 0.0:
	set(value):
		slice_start_time = value
		for line in segment_lines:
			line.slice_start_time = value 
var slice_end_time: float = INF:
	set(value):
		slice_end_time = value
		for line in segment_lines:
			line.slice_end_time = value 
var fade_out: bool = true:
	set(value):
		fade_out = value
		for line in segment_lines:
			line.max_length_time = 10 if value else INF
var stream: EventsStream = null:
	set(value):
		stream = value
		_update_segment_lines()
var segment_lines: Array[PathSegmentLine] = []


func _ready() -> void:
	_update_segment_lines()


func _update_segment_lines() -> void:
	if !is_node_ready():
		return
	
	for line in segment_lines:
		line.queue_free()
	
	if stream == null:
		return
	
	for segment in stream.segments:
		var line: PathSegmentLine = PathSegmentLineScene.instantiate()
		line.slice_start_time = slice_start_time
		line.slice_end_time = slice_end_time
		line.segment = segment
		segment_lines_container.add_child(line)
		segment_lines.push_back(line)


func _get_path_segment_with_time(target_time: float) -> EventsStream.PathSegment:
	var index = stream.segments.find_custom(func (seg: EventsStream.PathSegment) -> bool:
		return target_time >= seg.start_time() and target_time <= seg.end_time()
	)
	return stream.segments[index] if index >= 0 else null


func get_positions_at(target_time: float) -> Vector2:
	var segment = _get_path_segment_with_time(target_time)
	var left := 0
	var right :int = segment.in_game_times.size() - 1
	var event_index := -1

	while left <= right:
		var mid := (left + right) / 2

		if segment.in_game_times[mid] < target_time:
			event_index = mid
			left = mid + 1
		else:
			right = mid - 1

	return segment.points[event_index]
	
