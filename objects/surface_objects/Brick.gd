extends StaticBody2D

const _BrickFragment : PackedScene = preload("res://objects/BrickFragment.tscn")

func destroy() -> void:
	for i in range(0, 4):
		var fragment : Node2D = _BrickFragment.instance()
		fragment.planet = get_parent() # Assumes the brick's parent is the planet
		fragment.position = position + (Vector2.UP.rotated(rotation) * 8.0) + (Vector2(randf(), randf()) * 16.0)
		fragment.velocity = Vector2.RIGHT.rotated(rotation) * 96.0
		get_parent().add_child(fragment)
	queue_free()
