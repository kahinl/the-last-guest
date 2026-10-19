extends Area3D

var entered = false
@onready var light =$"../CanvasLayer/AnimationPlayer"



func _on_body_entered(body):
	if body is CharacterBody3D:
		entered = true
		light.play("light_in")
		await light.animation_finished
		get_tree().change_scene_to_file("res://assets/Dream/dream_HappyKitchen.tscn")



func _on_body_exited(body):
	if body is CharacterBody3D:
		entered = false
