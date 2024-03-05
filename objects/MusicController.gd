extends Node

onready var bgm : AudioStreamPlayer = $BGM
onready var tween : Tween = $Tween

func change_music_pitch(pitch : float) -> void:
	bgm.pitch_scale = pitch

func play_music() -> void:
	bgm.volume_db = 0.0
	bgm.play()

func fade_out_music() -> void:
	tween.interpolate_property(bgm, "volume_db", bgm.volume_db, -60.0, 5.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
