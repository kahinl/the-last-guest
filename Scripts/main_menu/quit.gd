extends Button

@onready var pressSound = $"../../../ButtonPressed"

func _on_pressed() -> void:
	if pressSound:
		pressSound.play()
		
	await get_tree().create_timer(0.28).timeout
	
	get_tree().quit()
