extends Node

var current_level : String
var keys_collected : Array
var letters_read : Array
var powerups_unlocked : Array
var player_spawn_altitude : float
var player_spawn_angle : float

var start_time_msec : int
var end_time_msec : int

var player_deaths : int = 0

var test_level_data = null

func new_game() -> void:
	current_level = "level1"
	keys_collected.clear()
	letters_read.clear()
	powerups_unlocked.clear()
	player_spawn_altitude = 0.0
	player_spawn_angle = -30.0
	player_deaths = 0
	start_time_msec = OS.get_ticks_msec()

func is_letter_read(letter_name : String) -> bool:
	return letters_read.has(letter_name)

func mark_letter_read(letter_name : String) -> void:
	letters_read.append(letter_name)

func is_key_collected(key_id : String) -> bool:
	return keys_collected.has(key_id)

func mark_key_collected(key_id : String) -> void:
	keys_collected.append(key_id)

func is_powerup_collected(powerup_id : String) -> bool:
	return powerups_unlocked.has(powerup_id)

func mark_powerup_collected(powerup_id : String) -> void:
	powerups_unlocked.append(powerup_id)

func is_dash_unlocked() -> bool:
	return powerups_unlocked.has("dash")

func is_double_jump_unlocked() -> bool:
	return powerups_unlocked.has("double_jump")

func is_punch_unlocked() -> bool:
	return powerups_unlocked.has("punch")

func _enter_tree() -> void:
	new_game()
