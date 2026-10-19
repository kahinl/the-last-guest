extends Area3D

var entered = false
@onready var creak = $"../creaks"

func _ready():
	if GameState.phone_scene_visits >= 3 and not GameState.phone_picked:
		$"../Ring".play()

func _on_body_entered(body):
	if body is CharacterBody3D:
		entered = true
		GameState.room1js_entered += 1
		if GameState.room1js_entered == 2:
				creak.play(3.26) 
				await get_tree().create_timer(2.2).timeout
				creak.stop() 


func _on_body_exited(body):
	if body is CharacterBody3D:
		entered = false
