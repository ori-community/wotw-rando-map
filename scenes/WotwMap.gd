extends Control
class_name WotwMap


@onready var origin: Node2D = %Origin
@onready var in_game_origin: Node2D = %InGameOrigin


var is_dragging: bool = false


func _ready() -> void:
	# Add @tool to this script and reload the scene in the editor
	# to regenerate map tile sprites.
	if Engine.is_editor_hint() && get_child_count() == 0:
		_editor_create_map_tiles()


func _editor_create_map_tiles() -> void:
	for x in range(36):
		for y in range(9):
			var resource_path := "res://assets/wotw-map-tiles/tile-%d_%d.png" % [x, y]
			
			if !ResourceLoader.exists(resource_path):
				continue
			
			var sprite := Sprite2D.new()
			sprite.texture = load(resource_path)
			sprite.name = "Tile-%d-%d" % [x, y]
			sprite.centered = false
			add_child(sprite)
			sprite.set_owner(get_tree().get_edited_scene_root())
			sprite.global_position = Vector2(x * 512, y * 512)


func get_in_game_mouse_position() -> Vector2:
	return in_game_origin.get_local_mouse_position()


func _zoom_to_position(position: Vector2, factor: float) -> void:
	var local_position := origin.to_local(position)
	origin.scale *= factor
	var global_position_after := origin.to_global(local_position)
	origin.position += position - global_position_after


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				is_dragging = event.pressed
			MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_to_position(get_global_mouse_position(), 0.96)
			MouseButton.MOUSE_BUTTON_WHEEL_UP:
				_zoom_to_position(get_global_mouse_position(), 1.04)

	elif event is InputEventMouseMotion:
		if is_dragging:
			origin.position += event.relative
