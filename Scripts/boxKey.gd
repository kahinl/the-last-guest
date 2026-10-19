extends StaticBody3D


@onready var prompt_play = $"../play2/hover"
@onready var speech = $"../familyPicture/speech/speech1/1"

func _ready():
	if GameState.boxKey_picked:
		queue_free()

func interact():
	GameState.boxKey_picked = true
	hide_prompt() 
	queue_free()
	speech.play("s2")
	await speech.animation_finished
	speech.stop()
	
func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
