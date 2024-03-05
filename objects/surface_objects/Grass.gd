extends Area2D

const TILE_SIZE : Vector2 = Vector2(8, 8)

onready var sprite = $Sprite
onready var tween = $Tween

func set_tile(which : Vector2) -> void:
	sprite.region_rect.position = which * TILE_SIZE

func rustle() -> void:
	tween.interpolate_property(sprite, "scale", sprite.scale, Vector2(1.5, 0.5), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(sprite, "scale", Vector2(1.5, 0.5), Vector2.ONE, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.25)
	tween.start()

func _body_entered(body : PhysicsBody2D) -> void:
	if body is Player and not tween.is_active():
		rustle()
