extends StaticBody3D


@onready var prompt_play = $play/hover
@onready var speech = $"../speech/C1/speech1/1"

func _ready():
	if GameState.floor2Key_picked:
		queue_free()

func interact():
	GameState.floor2Key_picked = true
	queue_free()
	speech.play("s1")
	await speech.animation_finished
	speech.stop()
	
func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
