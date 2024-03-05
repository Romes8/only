extends Camera2D

const STRETCH_START : float = 64.0
const STRETCH_END : float = 128.0

var target : Node2D
var anchor : Node2D

func _process(delta : float) -> void:
	var target_anchor_distance : float = target.position.distance_to(anchor.position)
	var ratio : float = clamp((target_anchor_distance - STRETCH_START) / (STRETCH_END - STRETCH_START), 0.25, 1.0)
	var camera_pos : Vector2 = lerp(anchor.position, target.position, ratio)
	position = lerp(position, camera_pos, delta * 5.0)
	var target_angle : float = target.position.direction_to(anchor.position).angle() - PI/2.0
	rotation = lerp_angle(rotation, target_angle, delta * 5.0)
