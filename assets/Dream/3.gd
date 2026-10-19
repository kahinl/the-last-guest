extends Area3D

var entered = false
@onready var light = $"../light3"
@onready var lightSound = $"../lightOFF"



func _on_body_entered(body):
	if body is CharacterBody3D:
		entered = true
		lightSound.play()
		light.visible = false
		



func _on_body_exited(body):
	if body is CharacterBody3D:
		entered = false
