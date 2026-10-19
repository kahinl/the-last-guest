extends StaticBody3D


@onready var prompt_play =$play5/hover



func interact():
	if GameState.interaction_locked:
		if GameState.casset_putted: 
			$"../AnimationPlayer".play("need2")
			return
		else : return
 
	if Input.is_action_just_pressed("ui_accept"):
		FadeLayer.fade_and_change_scene(
			"res://assets/House/Floor2/hallWay/hallWay.tscn",
			"from_room2"
		)

func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
