extends Control

onready var back = $Back
onready var label_contents = $Back/Label_Contents
onready var label_prompt = $Label_Prompt
onready var tween = $Tween

var active : bool = false

func set_contents(text : String) -> void:
	label_contents.text = text

func appear() -> void:
	get_tree().paused = true
	tween.interpolate_property(back, "rect_position", Vector2(0, -96), Vector2(0, 140), 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(label_prompt, "rect_position", Vector2(0, 360), Vector2(0, 328), 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	active = true

func disappear() -> void:
	active = false
	tween.interpolate_property(back, "rect_position", Vector2(0, 140), Vector2(0, -96), 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.interpolate_property(label_prompt, "rect_position", Vector2(0, 328), Vector2(0, 360), 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().paused = false
	queue_free()

func _input(event : InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("interact"):
		disappear()
