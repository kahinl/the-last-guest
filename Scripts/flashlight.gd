extends StaticBody3D


@onready var prompt_play = $play1/hover
@onready var speech = $"../speech/C1/speech2/2"

func _ready():
	if GameState.flashpicked:
		queue_free()

func interact():
	GameState.flashpicked = true

	# Nesne hemen serbest birakilirsa asagidaki await'in sonrasi hic kosmaz
	# (kuyruk serbest edilen nesneye baglidir) ve speech.stop() dusmez.
	# Gorunurluk + carpisma simdi kapaniyor; queue_free ses bitince.
	visible = false
	collision_layer = 0
	hide_prompt()

	speech.play("s2")
	await speech.animation_finished
	speech.stop()
	queue_free()


func show_prompt():
	prompt_play.visible = true

func hide_prompt():
	prompt_play.visible = false
