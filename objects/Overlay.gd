extends CanvasLayer

onready var letter = $Letter
onready var prompt_message = $PromptMessage
onready var status_message = $StatusMessage
onready var transition = $Transition

func display_letter(message : String) -> void:
	letter.set_contents(message)
	letter.appear()
