extends Node2D

const _Planet : PackedScene = preload("res://objects/Planet.tscn")
const _Player : PackedScene = preload("res://objects/surface_objects/Player.tscn")
const _Door : PackedScene = preload("res://objects/surface_objects/Door.tscn")
const _Tree : PackedScene = preload("res://objects/surface_objects/Tree.tscn")

var player
var planet
var door
onready var camera = $Camera2D
onready var prompt_message = $Overlay/PromptMessage
onready var transition = $Overlay/Transition

var active : bool = true

func show_prompt_message(message : String) -> void:
	prompt_message.show_message(message, 0.1)

func door_entered(id : String, angle : float, alt : float) -> void:
	if not active:
		return
	active = false
	transition.transition_out()
	yield(transition, "transition_finished")
	GameState.new_game()
	get_tree().change_scene("res://scenes/Game.tscn")

func spawn_stuff() -> void:
	planet = _Planet.instance()
	planet.radius = 31.9
	planet.tiles = [0]
	planet.grass = [0]
	planet.position = Vector2(0, 0)
	add_child(planet)
	planet.spawn_grass()
	player = _Player.instance()
	player.position = Vector2.RIGHT.rotated(-1.45) * planet.radius
	player.rotation = -1.45
	player.planet = planet
	add_child(player)
	door = _Door.instance()
	door.position = Vector2.RIGHT.rotated(2.0) * planet.radius
	door.rotation = 2.0
	door.key = "none"
	planet.add_child(door)
	door.connect("door_entered", self, "door_entered")
	var tree = _Tree.instance()
	tree.position = Vector2.RIGHT.rotated(-1.75) * planet.radius
	tree.rotation = -1.75
	planet.add_child(tree)

func _ready() -> void:
	transition.transition_speed = 1.0
	transition.set_visibility_level(0.0)
	spawn_stuff()
	yield(get_tree().create_timer(0.5), "timeout")
	MusicController.play_music()
	yield(get_tree().create_timer(0.5), "timeout")
	transition.transition_in()
