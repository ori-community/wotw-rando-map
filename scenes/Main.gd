extends Control


@onready var wotw_map: WotwMap = %WotwMap


func _ready() -> void:
	var save_file_reader := WotwSaveFileReader.new(FileAccess.get_file_as_bytes("H:/wotw-rando-map/saveFile1.uberstate"))
	var slot_data := save_file_reader.read_events_stream()
	var events_stream_reader := WotwEventsStreamReader.new(slot_data)
	var lines := events_stream_reader.read()
	
	for line in lines:
		var instance := Line2D.new()
		instance.points = line
		instance.width = 1.0
		instance.joint_mode = Line2D.LINE_JOINT_ROUND
		instance.default_color = Color.ROYAL_BLUE
		wotw_map.add_child(instance)


func _process(_delta: float) -> void:
	pass # print(wotw_map.get_in_game_mouse_position())
