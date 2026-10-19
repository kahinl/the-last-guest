extends StaticBody3D


@onready var prompt_play= $play2/hover
@onready var speech = $"../speech/CanvasLayer/speech3/3"

func _ready():
	if GameState.letter1_picked:
		queue_free()

func interact():
	GameState.letter1_picked = true
	
	queue_free()
	
	speech.play("s3")
	await speech.animation_finished
	speech.stop()
	
func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
