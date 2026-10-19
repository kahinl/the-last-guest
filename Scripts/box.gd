extends StaticBody3D


@onready var prompt_play = $"../play1/hover"
@onready var action = $open
@onready var needs = $"../speech/C1/1"




func interact():
	if GameState.boxKey_picked == true:
		action.get_animation("Open _ Close").loop_mode = Animation.LOOP_NONE
		action.play("Open _ Close")
		await action.animation_finished
		$CollisionShape3D.queue_free()
		action.pause() 
	else:
		needs.play("s2")

func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
