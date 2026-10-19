extends StaticBody3D

@onready var prompt_play = $play11/hover
@onready var action = $"../../../../left"

var is_open = false
var anim_name = "left"

func interact():
	action.get_animation(anim_name).loop_mode = Animation.LOOP_NONE
	
	if not is_open:
		action.play(anim_name)
		is_open = true
	else:
		action.play(anim_name, -1, -1.0, true)
		is_open = false

func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
