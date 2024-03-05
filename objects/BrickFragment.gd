extends Sprite

const STARTING_SPEED : float = 64.0
const ACCEL : float = 320.0

var velocity : Vector2
var planet : Node2D

func _physics_process(delta : float) -> void:
	velocity += global_position.direction_to(planet.global_position) * ACCEL * delta
	position += velocity * delta

func _on_Timer_Expire_timeout():
	queue_free()

func _ready() -> void:
	velocity += Vector2(randf()-0.5, randf()-0.5).normalized() * STARTING_SPEED
