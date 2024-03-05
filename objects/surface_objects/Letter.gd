extends Area2D

onready var sprite = $Sprite
onready var audio_get = $Audio_Get
onready var tween = $Tween

var id : String
var collected : bool

var time : float = 0.0

func _process(delta : float) -> void:
	time += delta
	sprite.offset.x = sin(time * 1.25) * 3.0

func _body_entered(body : PhysicsBody2D) -> void:
	if body is Player and not collected:
		tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(0.0, 1.0), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
		audio_get.play()
		collected = true
		GameState.mark_letter_read(id)
		get_tree().call_group("game", "letter_collected", id)

func _ready() -> void:
	# Actually, did we already get collected?
	if GameState.is_letter_read(id):
		collected = true
		hide()
