extends Button

@onready var credit = $".."

func _ready() -> void:
	pass 

func _on_pressed() -> void:
	credit.visible = false
