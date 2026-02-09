extends Control
class_name WotwMap


signal map_in_game_center_changed(center: Vector2)


@export var drag_limit_top_left := Vector2(-2023, -3423)  ## Top-left drag limit of the map center in in-game coordinates
@export var drag_limit_bottom_right := Vector2(2382, -4656)  ## Bottom-right drag limit of the map center in in-game coordinates

@export var map_top_left := Vector2(0, 0)
@export var map_bottm_right := Vector2(0, 0)

@onready var origin: Node2D = %Origin
@onready var in_game_origin: Node2D = %InGameOrigin
@onready var slot: Node2D = %Slot


const SCROLL_ZOOM_SPEED := 0.04

var _nodes_to_reparent_to_in_game_origin: Array[Node] = []
var _is_dragging: bool = false
var _map_in_game_center_position_cache: Vector2 = Vector2(0, 0)  ## Cache to recenter the map when the control is resized
var _map_in_game_center_position: Vector2:
	set(value):
		_map_in_game_center_position_cache = value
		if is_node_ready():
			_update_map_position(value)
		map_in_game_center_changed.emit(value)
	get():
		return in_game_origin.to_local(get_global_rect().get_center())
var _map_scale: Vector2:
	set(value):
		if is_node_ready():
			var current_center = _map_in_game_center_position
			origin.scale = value
			_update_map_position(current_center)
	get():
		return origin.scale
var follow_center:= Vector2.INF
		
func _ready() -> void:
	for node in _nodes_to_reparent_to_in_game_origin:
		node.reparent(slot, false)
	_nodes_to_reparent_to_in_game_origin.clear()
	
	_map_in_game_center_position_cache = _map_in_game_center_position
		
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
	return _map_in_game_center_position


func _zoom_around_screen_position(screen_position: Vector2, factor: float) -> void:
	var local_position := origin.to_local(screen_position)
	origin.scale *= factor
	var global_position_after := origin.to_global(local_position)
	origin.position += screen_position - global_position_after
	map_in_game_center_changed.emit(_map_in_game_center_position)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				_is_dragging = event.pressed
			MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_around_screen_position(get_global_mouse_position(), 1.0 - SCROLL_ZOOM_SPEED)
			MouseButton.MOUSE_BUTTON_WHEEL_UP:
				_zoom_around_screen_position(get_global_mouse_position(), 1.0 + SCROLL_ZOOM_SPEED)

	elif event is InputEventMouseMotion:
		if _is_dragging:
			origin.position += event.relative
			map_in_game_center_changed.emit(_map_in_game_center_position)


func _on_resized() -> void:
	_map_in_game_center_position = _map_in_game_center_position_cache

	
func _update_map_position(center: Vector2):
	var position_offset := get_global_rect().get_center() - in_game_origin.to_global(center)
	origin.position += position_offset

func _process(delta: float) -> void:

	# follow specific point
	# testing required
	if follow_center != Vector2.INF:
		if _map_in_game_center_position.is_equal_approx(follow_center):
			_map_in_game_center_position = follow_center
		else:
			var speed = minf(_map_in_game_center_position.distance_to(follow_center) * 0.01, 5)
			_map_in_game_center_position = _map_in_game_center_position.lerp(follow_center, clampf(delta * speed, minf(5 * delta, 1.0)  , 1.0))
			
	# Clamp map to drag limits
	if !_is_dragging:
		var map_in_game_center_position := _map_in_game_center_position
		var is_out_of_drag_bounds_x := map_in_game_center_position.x < drag_limit_top_left.x || map_in_game_center_position.x > drag_limit_bottom_right.x
		var is_out_of_drag_bounds_y := map_in_game_center_position.y > drag_limit_top_left.y || map_in_game_center_position.y < drag_limit_bottom_right.y
		
		if is_out_of_drag_bounds_x || is_out_of_drag_bounds_y:
			var clamped_map_center_position = Vector2(
				clampf(map_in_game_center_position.x, drag_limit_top_left.x, drag_limit_bottom_right.x),
				clampf(map_in_game_center_position.y, drag_limit_bottom_right.y, drag_limit_top_left.y),
			)
			
			var new_position := map_in_game_center_position.lerp(clamped_map_center_position, delta * 20.0)
			
			if clamped_map_center_position.is_equal_approx(new_position):
				_map_in_game_center_position = clamped_map_center_position
			else:
				_map_in_game_center_position = new_position
					
func _on_map_in_game_center_changed(center: Vector2) -> void:
	_map_in_game_center_position_cache = center


func _on_child_entered_tree(node: Node) -> void:
	if !node.is_in_group("MapOrigin"):
		if is_node_ready():
			node.reparent(slot, false)
		else:
			_nodes_to_reparent_to_in_game_origin.push_back(node)


func center_on(center: Vector2, instantly: bool = false, scale: float = origin.scale.x):
	if instantly:
		_map_in_game_center_position = center
		_map_scale = Vector2(scale, scale)
	else:
		create_tween().tween_property(self, "_map_in_game_center_position", center, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		create_tween().tween_property(self, "_map_scale", Vector2(scale, scale), 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	
func zoom_on(points: Array[Vector2], instantly: bool = false):
	if points.size() == 0:
		return
	
	if points.size() == 1:
		center_on(points[0], instantly)
		return
	
	var rect:= Rect2(points[0], Vector2.ZERO)
	
	for point in points.slice(1):
		rect = rect.expand(point)
	
	var screen_rect = in_game_origin.global_transform * rect

	var scaleX = origin.scale.x / (screen_rect.size.x / self.size.x)
	var scaleY = origin.scale.y / (screen_rect.size.y / self.size.y)
	var min_scale = min(scaleX, scaleY)
	
	center_on(rect.get_center(), instantly, min_scale)


func zoom_to_fit(instantly: bool = false):
	zoom_on([map_top_left, map_bottm_right], instantly)
	
