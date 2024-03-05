extends Node2D

onready var spike = $Area2D_Deadly
onready var audio_strike = $Audio_Strike
onready var tween = $Tween

func do_animation() -> void:
	tween.interpolate_property(spike, "position", Vector2(-64, 0), Vector2(0, 0), 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.interpolate_property(spike, "position", Vector2(0, 0), Vector2(-64, 0), 2.0, Tween.TRANS_SINE, Tween.EASE_IN, 1.5)
	tween.start()
	audio_strike.play()

func _on_Tween_tween_all_completed():
	do_animation()

func _ready() -> void:
	yield(get_tree().create_timer(rotation / 2.0), "timeout")
	do_animation()
