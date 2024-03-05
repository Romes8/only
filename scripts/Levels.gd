extends Node

const LEVEL_FILES : Dictionary = {
	"level1": "res://levels/level1.tres",
	"level2": "res://levels/level2.tres",
	"level3": "res://levels/level3.tres",
	"level4": "res://levels/level4.tres",
	"level5": "res://levels/level5.tres",
	"level6": "res://levels/level6.tres"
}

const letters : Dictionary = {
	"test_letter": "Letter contents go here.\n         Love, Mum",
	"level1_letter1": "What a wonderful world. We really are lucky, you know?\nSo many things just waiting to be found.",
	"level3_letter1": "It's sad to see what's going on out there, but try not to focus on it.\nWe have our own lives to live.",
	"level2_letter1": "Look around you; they're bringing their problems with them.\nWe need to protect ourselves.",
	"level4_letter1": "Don't listen to what the others are saying.\nThey're lying to you. They want to bring us\n down to their level.",
	"level5_letter1": "These measures are necessary to protect all that we hold dear.",
	"level6_letter1": "This is our home, and it is perfect.\nAll who think otherwise are our enemies.\nWe will protect the glory of this place."
}

const keys : Dictionary = {
	"test_key": "TEST KEY",
	"level1_key1": "FLEET KEY",
	"level3_key1": "HIGH KEY",
	"level4_key1": "ARMS KEY",
	"level3_key2": "SHIFT KEY"
}

var levels : Dictionary

func get_key_name(key_id : String) -> String:
	return keys[key_id]

func get_level(level_name : String) -> Dictionary:
	return levels[level_name]

func load_level(path : String) -> Dictionary:
	var file : File = File.new()
	file.open(path, File.READ)
	var contents : String = file.get_as_text()
	var json : Dictionary = parse_json(contents)
	file.close()
	return json

func load_levels() -> void:
	levels.clear()
	for level_name in LEVEL_FILES:
		var path : String = LEVEL_FILES[level_name]
		var level : Dictionary = load_level(path)
		levels[level_name] = level

func _enter_tree() -> void:
	load_levels()
