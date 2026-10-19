extends StaticBody3D
## On kapiya anahtari takma. handelPlacing.gd'nin kopyasiydi ve yanlis bayraklari
## okuyup yaziyordu; frontKey akisina duzeltildi (G16).

@onready var prompt_play = $play6/hover
@onready var key = $"../defaultMaterial"
@onready var need =$"../speech/C1/speech2/2"


func _ready():
	if GameState.is_frontkey_installed:
		key.visible = true
		$CollisionShape3D.queue_free()

func interact():
	if GameState.frontKey_picked:
		key.visible = true
		$CollisionShape3D.queue_free()
		GameState.is_frontkey_installed = true
	else:
		need.play("s4")

func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
