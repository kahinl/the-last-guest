extends Node3D

@onready var black = $FadeLayer/AnimationPlayer
@onready var Reset2 = $AnimationPlayer
@onready var pistol = $AnimationPlayer2  
@onready var wall1 = $wall1/CollisionShape3D
@onready var wall2 = $wall2/CollisionShape3D
@onready var wall3 = $wall3/CollisionShape3D

func _ready() -> void:
	black.play("fade_in")
	black.advance(10.0)
	Wind.play()
	Comfy.play()


	GameState.pistol_picked = false
	
	wall1.disabled = true
	wall2.disabled = true
	wall3.disabled = true
	
	if GameState.Reset2:
		GameState.can_pick_pistol = true
		
		if pistol:
			pistol.play("pi")
		$Glitch.visible = true
		
		wall1.disabled = false
		wall2.disabled = false
		wall3.disabled = false

		Reset2.play("Reset2")
		black.play("fade_out")
		
		await black.animation_finished
		
		var player = get_tree().current_scene.find_child("Player", true, false)
		if player:
			player.freeze()
				
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
		await Reset2.animation_finished
		
		Reset2.play("Reset3")
	
		if player:
			player.unfreeze()
				
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		# Ilk berrak ruya ani (G11)
		if not GameState.lucid1_done:
			GameState.lucid1_done = true
			Speech.say(get_node_or_null("extraSpeech/line") as Label, "lucid_1")

		# Ruya duvari inceltti: Backrooms'a gecis artik hazir (kolay giris)
		GameState.box_seen = true
		GameState.Reset2 = false
		Speech.say(get_node_or_null("extraSpeech/line") as Label, "wall_thin")
	else:
		black.play("fade_out")
		# Olum/geri donus yeniden yuklemelerinde tabanca masada kalmali;
		# aksi halde "pi" animasyonu hic calismadan tabanca zeminin altinda kalir
		if GameState.can_pick_pistol:
			$Pistol.position = Vector3(1.832, 0.07, 3.876)
		if GameState.backrooms_survived and not GameState.wall_thin_seen:
			GameState.wall_thin_seen = true
			Speech.say(get_node_or_null("extraSpeech/line") as Label, "under_it")
		
	GameState.flashlight_on = false
	GameState.flashpicked = false
