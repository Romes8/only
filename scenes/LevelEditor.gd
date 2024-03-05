extends Node2D

const FontInterface : Font = preload("res://fonts/interface.tres")
const PlayerIcon : Texture = preload("res://sprites/player.png")
const Icons : Texture = preload("res://sprites/level_editor_icons.png")

const _Planet : PackedScene = preload("res://objects/Planet.tscn")
const _Platform : PackedScene = preload("res://objects/surface_objects/Platform.tscn")
const _Door : PackedScene = preload("res://objects/surface_objects/Door.tscn")
const _Key : PackedScene = preload("res://objects/surface_objects/Key.tscn")
const _Letter : PackedScene = preload("res://objects/surface_objects/Letter.tscn")
const _Powerup : PackedScene = preload("res://objects/surface_objects/Powerup.tscn")
const _Tree : PackedScene = preload("res://objects/surface_objects/Tree.tscn")
const _SpikeWall : PackedScene = preload("res://objects/surface_objects/SpikeWall.tscn")
const _SpikeFloor : PackedScene = preload("res://objects/surface_objects/SpikeFloor.tscn")
const _SpikePiston : PackedScene = preload("res://objects/surface_objects/SpikePiston.tscn")
const _SpikeRing : PackedScene = preload("res://objects/surface_objects/SpikeRing.tscn")
const _Brick : PackedScene = preload("res://objects/surface_objects/Brick.tscn")

const ALTITUDE_STEP : float = 8.0
const ANGLE_STEP : float = 5.0

const objects : Dictionary = {
	"platform": _Platform,
	"door": _Door,
	"key": _Key,
	"letter": _Letter,
	"powerup": _Powerup,
	"tree": _Tree,
	"spike_wall": _SpikeWall,
	"spike_floor": _SpikeFloor,
	"spike_piston": _SpikePiston,
	"spike_ring": _SpikeRing,
	"brick": _Brick
}

var planet : Node2D

var cursor_angle : float
var cursor_altitude : float

var player_spawn_angle : float
var player_spawn_altitude : float

var object_index : int = 0

func get_selected_object_name() -> String:
	return objects.keys()[object_index]

func get_cursor_pos() -> Vector2:
	return planet.position + (Vector2.RIGHT.rotated(cursor_angle) * (planet.radius + cursor_altitude))

func save_object(type : String, object : Node2D) -> Dictionary:
	var altitude : float = stepify(planet.global_position.distance_to(object.global_position) - planet.radius, ALTITUDE_STEP)
	var angle : float = stepify(rad2deg(planet.global_position.direction_to(object.global_position).angle()), ANGLE_STEP)
	var object_data : Dictionary = {"type": type, "altitude": altitude, "angle": angle}
	match type:
		"door":
			object_data["key"] = "test_key"
			object_data["destination"] = "test"
			object_data["destination_angle"] = 0.0
			object_data["destination_altitude"] = 0.0
		"key":
			object_data["id"] = "test_key"
		"letter":
			object_data["id"] = "test_letter"
		"powerup":
			object_data["which_power"] = "test_powerup"
		"spike_ring":
			object_data["spike_altitude"] = 64.0
			object_data["number_of_spikes"] = 40
	return object_data

func place_object() -> void:
	var object_scene : PackedScene = objects[get_selected_object_name()]
	var object : Node2D = object_scene.instance()
	object.position = get_cursor_pos() - planet.position
	object.rotation = cursor_angle
	planet.add_child(object)

func remove_object() -> void:
	for object_type in objects.keys():
		for object in get_tree().get_nodes_in_group(object_type):
			if object.global_position.distance_to(get_cursor_pos()) < 8.0:
				object.queue_free()

func clear_level() -> void:
	for object_type in objects.keys():
		for object in get_tree().get_nodes_in_group(object_type):
			object.queue_free()

func load_level(level_data : Dictionary) -> void:
	clear_level()
	for object_data in level_data["objects"]:
		var object_scene : PackedScene = objects[object_data["type"]]
		var object : Node2D = object_scene.instance()
		object.position = Vector2.RIGHT.rotated(deg2rad(object_data["angle"])) * (object_data["altitude"] + planet.radius)
		object.rotation = deg2rad(object_data["angle"])
		planet.add_child(object)

func save_level() -> Dictionary:
	var object_list : Array = []
	for object_type in objects.keys():
		for object in get_tree().get_nodes_in_group(object_type):
			object_list.append(save_object(object_type, object))
	return {"radius": 65.0, "tiles": [0], "grass": [0], "objects": object_list}

func play_level() -> void:
	GameState.player_spawn_angle = player_spawn_angle
	GameState.player_spawn_altitude = player_spawn_altitude
	GameState.current_level = "test"
	GameState.test_level_data = save_level()
	GameState.keys_collected.clear()
	GameState.letters_read.clear()
	GameState.powerups_unlocked = ["double_jump", "dash"]
	get_tree().change_scene("res://scenes/Game.tscn")

func _input(event : InputEvent) -> void:
	if event is InputEventMouse:
		cursor_altitude = stepify(clamp(planet.position.distance_to(event.position) - planet.radius, 0.0, 500.0), ALTITUDE_STEP)
		cursor_angle = deg2rad(stepify(rad2deg(planet.position.direction_to(event.position).angle()), ANGLE_STEP))
	if event.is_action_pressed("level_editor_place_object"):
		place_object()
	elif event.is_action_pressed("level_editor_remove_object"):
		remove_object()
	elif event.is_action_pressed("level_editor_next_object"):
		object_index = wrapi(object_index + 1, 0, objects.size())
	elif event.is_action_pressed("level_editor_previous_object"):
		object_index = wrapi(object_index - 1, 0, objects.size())
	elif event.is_action_pressed("level_editor_place_player"):
		player_spawn_angle = rad2deg(cursor_angle)
		player_spawn_altitude = cursor_altitude
	elif event.is_action_pressed("level_editor_clear"):
		clear_level()
	elif event.is_action_pressed("level_editor_load"):
		var level_data : Dictionary = parse_json(OS.clipboard)
		load_level(level_data)
	elif event.is_action_pressed("level_editor_save"):
		var level_data : Dictionary = save_level()
		var level_string : String = to_json(level_data)
		OS.clipboard = level_string
	elif event.is_action_pressed("level_editor_play"):
		play_level()
	update()

func _draw() -> void:
	# Draw object
	draw_set_transform(get_cursor_pos(), cursor_angle, Vector2.ONE)
	draw_texture_rect_region(Icons, Rect2(-16, -16, 80, 32), Rect2(0, 32*object_index, 80, 32))
	# Draw cursor
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(get_cursor_pos(), 2.0, Color.white)
	# Draw stats
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(2, 2))
	draw_string(FontInterface, Vector2(5, 10), "ANGLE:")
	draw_string(FontInterface, Vector2(60, 10), str(rad2deg(cursor_angle)))
	draw_string(FontInterface, Vector2(5, 20), "ALT:")
	draw_string(FontInterface, Vector2(60, 20), str(cursor_altitude))
	draw_string(FontInterface, Vector2(5, 30), "OBJECT:")
	draw_string(FontInterface, Vector2(60, 30), str(get_selected_object_name()))

func _ready() -> void:
	planet = _Planet.instance()
	planet.radius = 65.0
	planet.position = Vector2(640, 360)
	planet.tiles = [0]
	planet.grass = [0]
	add_child(planet)
	planet.spawn_grass()
	if GameState.test_level_data != null:
		load_level(GameState.test_level_data)
