extends Control


@onready var wotw_map: WotwMap = %WotwMap
@onready var events_view: EventsView = %EventsView
@onready var time_slider: HSlider = %TimeSlider


func _ready() -> void:
	var save_file_reader := WotwSaveFileReader.new(FileAccess.get_file_as_bytes("C:/Users/Timo/AppData/Local/Ori and the Will of The Wisps/saveFile1 - Copy.uberstate"))
	var slot_data := save_file_reader.read_events_stream()
	var events_stream_reader := WotwEventsStreamReader.new()
	events_stream_reader.append_events(slot_data)
	
	events_view.stream = events_stream_reader.stream
	time_slider.max_value = events_stream_reader.stream.in_game_time_end


func _process(_delta: float) -> void:
	pass # print(wotw_map.get_in_game_mouse_position())


func _on_time_slider_value_changed(value: float) -> void:
	events_view.slice_end_time = value
