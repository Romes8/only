extends Area2D

onready var sprite = $Sprite
onready var audio_get = $Audio_Get
onready var tween = $Tween

var which_power : String
var collected : bool

var time : float = 0.0

func _process(delta : float) -> void:
	time += delta
	sprite.offset.x = sin(time * 1.25) * 3.0

func _body_entered(body : PhysicsBody2D) -> void:
	if body is Player and not collected:
		collected = true
		# Do shiny stuff
		tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(2.0, 0.0), 1.0, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		tween.interpolate_property(sprite, "rotation", sprite.rotation, sprite.rotation + (PI*6.0), 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		set_bright(true)
		audio_get.play()
		# I HAVE THE POWAAAAH!
		GameState.mark_powerup_collected(which_power)
		match which_power:
			"dash":
				body.unlocked_dash = true
				get_tree().call_group("game", "show_status_message", "Dash ability acquired! Press Z to dash.")
			"double_jump":
				body.unlocked_double_jump = true
				body.extra_jumps = 1
				get_tree().call_group("game", "show_status_message", "Double jump ability acquired! Press X to jump again in mid-air.")
			"punch":
				body.unlocked_punch = true
				get_tree().call_group("game", "show_status_message", "Punch ability acquired! Press C to punch.")
			"test_powerup":
				get_tree().call_group("game", "show_status_message", "Test power-up acquired.")

func set_bright(bright : bool) -> void:
	get_material().set_shader_param("bright", bright)

func _ready() -> void:
	set_material(get_material().duplicate(true))
	match which_power:
		"dash":
			sprite.region_rect.position.y = 0
		"double_jump":
			sprite.region_rect.position.y = 16
		"punch":
			sprite.region_rect.position.y = 32
	# Actually, did we already get collected?
	if GameState.is_powerup_collected(which_power):
		collected = true
		hide()
