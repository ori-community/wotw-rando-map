extends Control
class_name WotwMap


@export var drag_limit_top_left := Vector2(-2023, -3423)  ## Top-left drag limit of the map center in in-game coordinates
@export var drag_limit_bottom_right := Vector2(2382, -4656)  ## Bottom-right drag limit of the map center in in-game coordinates


@onready var origin: Node2D = %Origin
@onready var in_game_origin: Node2D = %InGameOrigin


const SCROLL_ZOOM_SPEED := 0.04


var is_dragging: bool = false
var map_in_game_center_position: Vector2:
	set(value):
		map_in_game_center_position = value
		if is_node_ready():
			var position_offset := get_global_rect().get_center() - in_game_origin.to_global(value)
			origin.position += position_offset
	get():
		return in_game_origin.to_local(get_global_rect().get_center())


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


func get_in_game_map_center() -> Vector2:
	return map_in_game_center_position


func _zoom_around_screen_position(screen_position: Vector2, factor: float) -> void:
	var local_position := origin.to_local(screen_position)
	origin.scale *= factor
	var global_position_after := origin.to_global(local_position)
	origin.position += screen_position - global_position_after


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				is_dragging = event.pressed
			MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_around_screen_position(get_global_mouse_position(), 1.0 - SCROLL_ZOOM_SPEED)
			MouseButton.MOUSE_BUTTON_WHEEL_UP:
				_zoom_around_screen_position(get_global_mouse_position(), 1.0 + SCROLL_ZOOM_SPEED)

	elif event is InputEventMouseMotion:
		if is_dragging:
			origin.position += event.relative


func _on_resized() -> void:
	if is_node_ready():
		pass # TODO


func _process(delta: float) -> void:
	# Clamp map to drag limits
	if !is_dragging:
		var is_out_of_drag_bounds_x := map_in_game_center_position.x < drag_limit_top_left.x || map_in_game_center_position.x > drag_limit_bottom_right.x
		var is_out_of_drag_bounds_y := map_in_game_center_position.y > drag_limit_top_left.y || map_in_game_center_position.y < drag_limit_bottom_right.y
		
		if is_out_of_drag_bounds_x || is_out_of_drag_bounds_y:
			var clamped_map_center_position = Vector2(
				clampf(map_in_game_center_position.x, drag_limit_top_left.x, drag_limit_bottom_right.x),
				clampf(map_in_game_center_position.y, drag_limit_bottom_right.y, drag_limit_top_left.y),
			)
			
			var new_position := map_in_game_center_position.lerp(clamped_map_center_position, delta * 20.0)
			
			if clamped_map_center_position.is_equal_approx(new_position):
				map_in_game_center_position = clamped_map_center_position
			else:
				map_in_game_center_position = new_position
