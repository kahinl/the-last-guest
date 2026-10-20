extends StaticBody3D


@onready var prompt_play = $"../play2/hover"
@onready var speech = $"../speech/C1/1"

func _ready():
	$"../flies/AnimationPlayer".speed_scale = 3
	$"../flies/AnimationPlayer".play("animation_model_idle")
	if GameState.phone_scene_visits >= 3 and not GameState.phone_picked:
		$"../Ring".play()

	if GameState.Cassette_picked:
		queue_free()

func interact():
	GameState.Cassette_picked = true
	hide_prompt()
	# flashlight.gd ile ayni sebep: nesne await'den once serbest birakilirsa
	# speech.stop() hic kosmuyor. Gorunurluk/carpisma hemen, free sonda.
	visible = false
	collision_layer = 0

	speech.play("s1")
	await speech.animation_finished
	speech.stop()
	queue_free()


func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
