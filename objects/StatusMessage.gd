extends Label

const MESSAGE_DISPLAY_TIME : float = 3.0

onready var timer_disappear = $Timer_Disappear
onready var tween = $Tween

var showing : bool = false

func show_message(message : String, display_time : float = MESSAGE_DISPLAY_TIME) -> void:
	timer_disappear.start(display_time)
	if message == text and showing:
		return
	showing = true
	text = message
	tween.stop_all()
	tween.interpolate_property(self, "percent_visible", 0.0, 1.0, 0.25)
	tween.start()

func _on_Timer_Disappear_timeout():
	tween.interpolate_property(self, "percent_visible", 1.0, 0.0, 0.25)
	tween.start()
	yield(tween, "tween_all_completed")
	showing = false
