extends Area3D

var entered = false
@onready var moving = $"../Bug/AnimationPlayer2"
@onready var cruttling = $"../Bug2"
@onready var metal = $"../metal"

func _on_body_entered(body):
	if body is CharacterBody3D:
		entered = true
		if GameState.bathjs_entered == 0:
			GameState.bathjs_entered += 1
			moving.play("Crawl_Room")
			cruttling.play()
			metal.play()
			await moving.animation_finished
			cruttling.stop()
			await get_tree().create_timer(3.77).timeout
			metal.stop()

			
func _on_body_exited(body):
	if body is CharacterBody3D:
		entered = false
