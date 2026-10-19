extends StaticBody3D


@onready var prompt_play = $play/hover
@onready var speech = $"../speech/1"

func _ready():
	if GameState.letter2_picked:
		queue_free()


func interact():
	self.visible=false
	
	GameState.letter2_picked = true
	speech.play("s1")
	await speech.animation_finished
	speech.stop()
	
	
	queue_free()
	
func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
