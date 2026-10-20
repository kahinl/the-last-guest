extends StaticBody3D

@export var speed: float = 1.0
@export var rotation_speed: float = 4.5

@onready var path_follow = get_parent() as PathFollow3D
@onready var anim = $AnimationPlayer
@onready var shoot_anim = $"../../../Player/Head/Hands/AnimationPlayer"
@onready var prompt_play = $play3/hover
@onready var black = $"../../../FadeLayer/AnimationPlayer"

var shooted = 0
var activated = false
var can_move = false
var is_processing_shot = false # Prevents input spam during the await
var _safety: Timer = null


func _ready() -> void:
	visible = false
	activated = false
	can_move = false
	$CollisionShape3D.disabled = true
	$Area3D/CollisionShape3D.disabled = true
	# Aktive edilmeden fizik karesi kosmasin; eskiden her Basement karesinde
	# GameState.pistol_picked yoklaniyordu (saniyede ~60).
	if GameState.pistol_picked:
		activate_monster()
		return
	set_physics_process(false)
	GameState.flag_set.connect(_on_game_state_flag_set)
	# Guvenlik agi: flag_set'i atlayip `GameState.pistol_picked = true` diyen
	# cagri yerleri var (tools/test_monster.gd gibi). Sinyal aninda tetikler,
	# bu sadece saniyede 1 yoklama ile yedek.
	_safety = Timer.new()
	_safety.wait_time = 1.0
	_safety.timeout.connect(_check_pistol)
	add_child(_safety)
	_safety.start()


func _check_pistol() -> void:
	if GameState.pistol_picked:
		activate_monster()


func _on_game_state_flag_set(name: String, value: Variant) -> void:
	if name == "pistol_picked" and bool(value):
		activate_monster()


func _physics_process(delta: float) -> void:
	if activated and can_move and path_follow:
		path_follow.progress += speed * delta
		
		var target_rot = path_follow.rotation.y
		
		if path_follow.progress >= 3.2 and path_follow.progress <= 7.5:
			target_rot = -2.3
		elif path_follow.progress > 7.5:
			target_rot = -3.6
		
		path_follow.rotation.y = lerp_angle(path_follow.rotation.y, target_rot, rotation_speed * delta)

func activate_monster():
	if activated:
		return  # sinyal + guvenlik zamanlayicisi + ilk kontrol ayni anda gelebilir
	activated = true
	visible = true
	set_physics_process(true)
	if _safety:
		_safety.stop()
	if GameState.flag_set.is_connected(_on_game_state_flag_set):
		GameState.flag_set.disconnect(_on_game_state_flag_set)
	if anim:
		anim.play("Getting Up")
		await get_tree().create_timer(2.0).timeout
		
		$CollisionShape3D.disabled = false
		$Area3D/CollisionShape3D.disabled = false
		
		$"../../../MosterShows".play()
		$"../../../MosterShows2".play()
		
		await get_tree().create_timer(4.0).timeout

		can_move = true
		anim.play("Walk")
		$"../../../steps".play()

func interact():
	# If we are already mid-shot or monster is dead, do nothing
	if is_processing_shot or not activated:
		return

	# SON B: suringe bulunduysa ates etmek yerine yanina gidersin (G15)
	if GameState.syringe_found and not GameState.ending_holdon_done:
		await _ending_holdon()
		return

	if shoot_anim:
		is_processing_shot = true
		shooted += 1 
		
		# Play audio and animation
		$"../../../shoot".play()
		shoot_anim.play("allanims")
		shoot_anim.seek(0, true)

		# If it's the killing blow, jump straight to die()
		if shooted >= 2:
			die()
			return # Exit the function here so we don't run the timer below

		# If it's only the first shot, wait for the animation to finish
		await get_tree().create_timer(2.79).timeout
		shoot_anim.pause()
		is_processing_shot = false 
		
		# FORCE the prompt to check again after the timer is done
		# This ensures that if the player is still looking at the monster, 
		# the text reappears immediately.
		show_prompt()

func die():
	is_processing_shot = true 
	can_move = false 
	hide_prompt() 

	# --- هذا السطر سيوقف اللاعب عن الحركة وسماع صوت خطواته فوراً ---
	var player = $"../../../Player" # تأكد أن هذا هو المسار الصحيح للاعب عندك
	if player and player.has_method("freeze"):
		player.freeze()
	
	# إيقاف أي أصوات خطوات كانت تعمل للوحش نفسه
	if $"../../../steps":
		$"../../../steps".stop()

	$CollisionShape3D.set_deferred("disabled", true)
	$Area3D/CollisionShape3D.set_deferred("disabled", true) 
	
	# إيقاف أصوات البيئة والوحش
	$"../../../MosterShows".stop()
	$"../../../MosterShows2".stop()
	$"../../../BackgroundSound".stop()

	# SON A: karartma baslamadan once son sozler (G14)
	if not GameState.ending_letgo_done:
		GameState.ending_letgo_done = true
		await get_tree().create_timer(2.0).timeout
		await Speech.say(_line(), "ending_letgo_1")
		await Speech.say(_line(), "ending_letgo_2")

	black.play("fade_in")
	
	await black.animation_finished
	# الانتقال للمنيو الآن سيكون "صامتاً" تماماً
	get_tree().change_scene_to_file("res://assets/main/main_menu.tscn")

# SON B - suringe bulunduysa ates etmek yerine yanina gidersin (G15)
func _ending_holdon():
	is_processing_shot = true
	can_move = false
	hide_prompt()

	GameState.ending_holdon_done = true

	var player = $"../../../Player"
	if player and player.has_method("freeze"):
		player.freeze()

	if $"../../../steps":
		$"../../../steps".stop()

	$CollisionShape3D.set_deferred("disabled", true)
	$Area3D/CollisionShape3D.set_deferred("disabled", true)

	$"../../../MosterShows".stop()
	$"../../../MosterShows2".stop()
	$"../../../BackgroundSound".stop()
	Wind.stop()
	Comfy.stop()

	await Speech.say(_line(), "ending_holdon_1")
	await Speech.say(_line(), "ending_holdon_2")
	await Speech.say(_line(), "ending_holdon_3")

	black.play("fade_in")
	await black.animation_finished
	get_tree().change_scene_to_file("res://assets/main/main_menu.tscn")

func _line() -> Label:
	return get_node_or_null("../../../extraSpeech/line") as Label

func show_prompt():
	if visible and not is_processing_shot: 
		prompt_play.visible = true

func hide_prompt():
	if prompt_play:
		prompt_play.visible = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player" and can_move:
		if body.has_method("freeze"):
			body.freeze()
		
		black.play("fade_in")
		$"../../../Died".visible = true
		
		$"../../../MosterShows".stop()
		$"../../../BackgroundSound".stop()
		$"../../../MosterShows2".stop()
		Wind.stop()
		Comfy.stop()
		
		await get_tree().create_timer(0.5).timeout
		get_tree().call_deferred("reload_current_scene")
