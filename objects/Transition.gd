extends Control

onready var tween = $Tween

var transition_amount : float = 0.5
var transition_speed : float = 1.0

signal transition_finished

func transition_in() -> void:
	transition_amount = 0.0
	set_visibility_level(0.0)
	tween.interpolate_property(self, "transition_amount", 0.0, 1.0, 0.5 / transition_speed, Tween.TRANS_CIRC, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	emit_signal("transition_finished")

func transition_out() -> void:
	transition_amount = 1.0
	set_visibility_level(1.0)
	tween.interpolate_property(self, "transition_amount", 1.0, 0.0, 0.5 / transition_speed, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	emit_signal("transition_finished")

func set_visibility_level(visibility_level : float) -> void:
	get_material().set_shader_param("visibility_level", visibility_level)

func _process(delta : float) -> void:
	if tween.is_active():
		set_visibility_level(transition_amount)
