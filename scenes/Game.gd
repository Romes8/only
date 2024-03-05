extends Node2D

const _Planet : PackedScene = preload("res://objects/Planet.tscn")
const _Player : PackedScene = preload("res://objects/surface_objects/Player.tscn")
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

var player : Node2D
var planet : Node2D
onready var camera : Camera2D = $Camera
onready var overlay : CanvasLayer = $Overlay

var active : bool = true

func end_game() -> void:
	print("Game over!")
	GameState.end_time_msec = OS.get_ticks_msec()
	yield(get_tree().create_timer(10.0), "timeout")
	overlay.transition.transition_speed = 0.25
	overlay.transition.transition_out()
	yield(overlay.transition, "transition_finished")
	overlay.transition.transition_speed = 1.0
	get_tree().change_scene("res://scenes/TheEnd.tscn")

func letter_collected(id : String) -> void:
	var letter_contents = Levels.letters[id]
	overlay.display_letter(letter_contents)
	# If this is the letter that ends the game, get on that
	if id == "level6_letter1":
		end_game()

func show_prompt_message(message : String) -> void:
	overlay.prompt_message.show_message(message, 0.1)

func show_status_message(message : String) -> void:
	overlay.status_message.show_message(message)

func door_entered(destination : String, destination_angle : float, destination_altitude : float) -> void:
	if not active:
		return
	active = false
	overlay.transition.transition_out()
	yield(overlay.transition, "transition_finished")
	# Switch to the new level
	GameState.current_level = destination
	GameState.player_spawn_angle = destination_angle
	GameState.player_spawn_altitude = destination_altitude
	get_tree().reload_current_scene()

func player_hit() -> void:
	if not active:
		return
	active = false
	GameState.player_deaths += 1
	overlay.transition.transition_out()
	yield(overlay.transition, "transition_finished")
	get_tree().reload_current_scene()

func spawn_object(type : String, altitude : float, angle : float, attributes : Dictionary) -> void:
	var scene : PackedScene = objects[type]
	var object : Node2D = scene.instance()
	object.position = Vector2.RIGHT.rotated(deg2rad(angle)) * (altitude + planet.radius)
	object.rotation = deg2rad(angle)
	# Add object-specific attributes
	match type:
		"door":
			object.destination = attributes["destination"]
			object.destination_angle = attributes["destination_angle"]
			object.destination_altitude = attributes["destination_altitude"]
			object.key = attributes["key"]
			object.connect("door_entered", self, "door_entered")
		"key":
			object.id = attributes["id"]
		"letter":
			object.id = attributes["id"]
		"powerup":
			object.which_power = attributes["which_power"]
		"spike_ring":
			object.spike_altitude = attributes["spike_altitude"]
			object.number_of_spikes = attributes["number_of_spikes"]
			object.planet = planet
	planet.add_child(object)

func spawn_level() -> void:
	var level_data : Dictionary
	if GameState.current_level == "test":
		level_data = GameState.test_level_data
	else:
		level_data = Levels.get_level(GameState.current_level)
	# Set up planet
	planet = _Planet.instance()
	planet.radius = level_data["radius"]
	planet.tiles = level_data["tiles"]
	planet.grass = level_data["grass"]
	add_child(planet)
	planet.spawn_grass()
	# Set up player
	player = _Player.instance()
	player.position = Vector2.RIGHT.rotated(deg2rad(GameState.player_spawn_angle)) * (GameState.player_spawn_altitude + planet.radius)
	player.rotation = deg2rad(GameState.player_spawn_angle)
	player.unlocked_dash = GameState.is_dash_unlocked()
	player.unlocked_double_jump = GameState.is_double_jump_unlocked()
	player.unlocked_punch = GameState.is_punch_unlocked()
	add_child(player)
	# Spawn objects
	for object in level_data["objects"]:
		var type : String = object["type"]
		var altitude : float = object["altitude"]
		var angle : float = object["angle"]
		spawn_object(type, altitude, angle, object)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("level_editor_back") and GameState.current_level == "test":
		get_tree().change_scene("res://scenes/LevelEditor.tscn")

func _ready() -> void:
	spawn_level()
	camera.global_position = planet.global_position
	player.planet = planet
	camera.target = player
	camera.anchor = planet
	overlay.transition.transition_in()
	# If we're reached the end, slowly fade out the music
	if GameState.current_level == "level6":
		MusicController.fade_out_music()
