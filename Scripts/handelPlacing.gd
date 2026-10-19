extends StaticBody3D

@onready var prompt_play = $play5/hover
@onready var handel = $"../Object_2"
@onready var need = $"../speech/C1/speech2/2"

func _ready():
	if GameState.is_handel_installed:
		handel.visible = true
		$CollisionShape3D.queue_free()

func interact():
	if GameState.doorHandel_picked: 
		handel.visible = true
		$CollisionShape3D.queue_free()
		GameState.is_handel_installed = true 
	else:
		need.play("s3")

func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
