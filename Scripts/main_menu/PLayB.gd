extends Button

@onready var pressSound = $"../../../ButtonPressed"
@onready var fade = $"../../../CanvasLayer/AnimationPlayer"
@export_file("*.tscn") var main_scene_path: String = "res://assets/main/main.tscn"

func _on_pressed() -> void:
	if pressSound:
		pressSound.play()
		
	fade.play("fade")
	await fade.animation_finished
	var error = get_tree().change_scene_to_file(main_scene_path)
	
	if error != OK:
		print("Error: Could not find or load the scene at ", main_scene_path)
