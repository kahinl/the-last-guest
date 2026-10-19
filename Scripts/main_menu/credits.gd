extends Button

@onready var pressSound = $"../../../ButtonPressed" # Ensure this path is correct
@onready var credit = $"../../../CREDITS"

func _on_pressed() -> void:
	if pressSound:
		pressSound.play()
	credit.visible = true
