extends StaticBody3D


@onready var prompt_play = $"../../../../../../../play2/hover"
@onready var action = $AnimationPlayer


func interact():
	action.get_animation("Take 001").loop_mode = Animation.LOOP_NONE
	action.play("Take 001")
	$CollisionShape3D.queue_free()
	await get_tree().create_timer(4).timeout
	action.pause() 

func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
