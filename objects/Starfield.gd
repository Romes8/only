extends Sprite

const SCROLL_DELTA : Vector2 = Vector2.LEFT * 8.0
var scroll : Vector2 = Vector2.ZERO

func _process(delta : float) -> void:
	scroll += SCROLL_DELTA * delta
	region_rect.position = scroll.round()
