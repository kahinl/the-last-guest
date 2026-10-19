extends Node3D

@onready var speech1 = $"speech/C1/speech1/1"


func _ready() -> void:
	if GameState.speech1_played:
		return
		
	GameState.speech1_played = true
	
	speech1.play("s1")
	await speech1.animation_finished
	speech1.stop()
	
	
	
	
  
