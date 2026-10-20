extends Node3D
@onready var somthing = $somthing


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.kitchen_entered += 1

	if GameState.kitchen_entered == 1:
		await get_tree().create_timer(3).timeout
		somthing.play()
		return

	# Ikinci giristen itibaren semptom (G12)
	if not GameState.symptom1_done:
		await get_tree().create_timer(3).timeout
		GameState.symptom1_done = true
		Speech.say(get_node_or_null("extraSpeech/line") as Label, "symptom_1")
