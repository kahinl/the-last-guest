extends Area3D

var entered = false

func _on_body_entered(body):
	if body is CharacterBody3D:
		entered = true

func _on_body_exited(body):
	if body is CharacterBody3D:
		entered = false

#func _process(_delta):
	#if entered and Input.is_action_just_pressed("ui_accept"):
		#FadeLayer.fade_and_change_scene(
			#"res://assets/House/Floor2/Bedrooms/room3.tscn",
		#	"default2"	
		#)
