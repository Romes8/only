extends CanvasLayer

onready var vbox = $VBox
onready var label_time = $VBox/Label_Time
onready var label_letters = $VBox/Label_Letters
onready var label_deaths = $VBox/Label_Deaths
onready var label_thank_you = $VBox/Label_ThankYou
onready var tween = $Tween

const NUMBERS : Array = ["zero", "one", "two", "three", "four", "five", "six", "sev- wait, seven? Okay, seven"]

func _ready() -> void:
	var clear_time : float = round((GameState.end_time_msec - GameState.start_time_msec) / 1000.0)
	var clear_time_minutes : int = int(floor(clear_time / 60.0))
	var clear_time_seconds : int = int(clear_time) % 60
	label_time.text = "Your time was %d %s, %d %s." % [clear_time_minutes, "minute" if clear_time_minutes == 1 else "minutes", clear_time_seconds, "second" if clear_time_seconds == 1 else "seconds"]
	label_letters.text = "You collected %s out of six letters." % NUMBERS[GameState.letters_read.size()]
	label_deaths.text = "You died %d %s." % [GameState.player_deaths, "time" if GameState.player_deaths == 1 else "times"]
	tween.interpolate_property(label_time, "modulate", Color.black, Color.white, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 2.0)
	tween.interpolate_property(label_letters, "modulate", Color.black, Color.white, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 4.0)
	tween.interpolate_property(label_deaths, "modulate", Color.black, Color.white, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 6.0)
	tween.interpolate_property(label_thank_you, "modulate", Color.black, Color.white, 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 9.0)
	tween.interpolate_property(vbox, "modulate", Color.white, Color.black, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 14.0)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://scenes/TitleScreen.tscn")
