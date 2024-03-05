extends Area2D

onready var sprite = $Sprite
onready var tween = $Tween

var key : String
var destination : String
var destination_angle : float
var destination_altitude : float

signal door_entered

func is_locked() -> bool:
	if key == "none":
		return false
	return GameState.is_key_collected(key) == false

func get_interact_message() -> String:
	if is_locked():
		var key_name : String = Levels.get_key_name(key)
		return "You need the " + key_name + " to enter."
	else:
		return "Press [E] to enter"

func interact() -> void:
	if not is_locked():
		emit_signal("door_entered", destination, destination_angle, destination_altitude)
