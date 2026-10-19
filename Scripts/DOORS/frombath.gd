extends StaticBody3D


@onready var prompt_play =$play2/hover



func interact():
	if Input.is_action_just_pressed("ui_accept"):
		FadeLayer.fade_and_change_scene(
			"res://assets/House/Floor2/hallWay/hallWay.tscn",
			"from_bath"
		)

func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
