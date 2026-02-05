extends Control

@onready var wotw_map: WotwMap = %WotwMap
@onready var events_view: EventsView = %EventsView
@onready var time_slider: HSlider = %TimeSlider
@onready var speed_slider: HSlider = %SpeedSlider
@onready var play_button: TextureButton = %PlayButton
@onready var speed_label: Label = %SpeedLabel

var is_playing = false:
	set(value):
		is_playing = value
		if value:
			play_button.texture_normal = preload("res://assets/ui/Pause.svg")
		else:
			play_button.texture_normal = preload("res://assets/ui/Play.svg")
		
var sliders_gets_dragged = false

func _ready() -> void:
	speed_label.text = str(speed_slider.value, "x")
	var save_file_reader := WotwSaveFileReader.new(FileAccess.get_file_as_bytes("C:/Users/Mawe/AppData/Local/Ori and the Will of The Wisps/saveFile1 - Copy.uberstate"))
	var slot_data := save_file_reader.read_events_stream()
	var events_stream_reader := WotwEventsStreamReader.new()
	events_stream_reader.append_events(slot_data)
	
	events_view.stream = events_stream_reader.stream
	time_slider.max_value = events_stream_reader.stream.in_game_time_end

func _process(_delta: float) -> void:
	if is_playing && !sliders_gets_dragged:
		time_slider.value += _delta * speed_slider.value

func _on_time_slider_value_changed(value: float) -> void:
	events_view.slice_end_time = value

func _on_button_pressed() -> void:
	is_playing = !is_playing


func _on_time_slider_drag_started() -> void:
	sliders_gets_dragged = true

func _on_time_slider_drag_ended(value_changed: bool) -> void:
	sliders_gets_dragged = false


func _on_speed_slider_value_changed(value: float) -> void:
	speed_label.text = str(value, "x")


func _on_fade_out_button_toggled(toggled_on: bool) -> void:
	events_view.fade_out = toggled_on
