extends StaticBody3D


@onready var prompt_play = $play1/hover
@onready var speech = $"../speech/C1/speech2/2"

func _ready():
	if GameState.flashpicked:
		queue_free()

func interact():
	GameState.flashpicked = true
	
	queue_free()
	
	speech.play("s2")
	await speech.animation_finished
	speech.stop()


func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
