extends Area2D

onready var sprite_a = $SpriteA
onready var sprite_b = $SpriteB
onready var audio_get = $Audio_Get
onready var tween = $Tween

var id : String
var collected : bool

var time : float = 0.0

func _process(delta : float) -> void:
	time += delta
	sprite_a.offset.x = sin(time * 1.25) * 3.0
	sprite_b.offset.x = sin(time * 1.25) * 3.0

func _body_entered(body : PhysicsBody2D) -> void:
	if body is Player and not collected:
		tween.interpolate_property(sprite_a, "scale", sprite_a.scale, Vector2(2.0, 0.0), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.interpolate_property(sprite_b, "scale", sprite_b.scale, Vector2(0.0, 2.0), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		set_bright(true)
		audio_get.play()
		collected = true
		GameState.mark_key_collected(id)
		var key_name : String = Levels.get_key_name(id)
		get_tree().call_group("game", "show_status_message", key_name + " acquired.")

func set_bright(bright : bool) -> void:
	get_material().set_shader_param("bright", bright)

func _ready() -> void:
	set_material(get_material().duplicate(true))
	# Actually, did we already get collected?
	if GameState.is_key_collected(id):
		collected = true
		hide()
