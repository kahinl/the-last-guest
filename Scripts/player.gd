extends CharacterBody3D
class_name Player

# ================= Movement =================
var speed
const WALK_SPEED = 2.2
const SPRINT_SPEED = 2.2
const JUMP_VELOCITY = 2.5
const SENSITIVITY = 0.004
var gravity = 9.8

# Govde merkezi ile zemin araligi: CollisionShape3D ofseti 0.297, disbuoy
# yarim capi 0.977 -> ayak tabani origin'in 0.68 m asagisinda.
const SPAWN_FOOT_Y = 0.68

# ================= Headbob =================
const BOB_FREQ = 2.4
const BOB_AMP = 0.025  # Subtle headbob
var t_bob = 0.0

# ================= FOV =================
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# ================= Nodes =================
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/RayCast3D
var cursor_locked = true
var current_interactable = null

@onready var anim_player = $AnimationPlayer 
@onready var speech1 = $"C1/1"
@onready var speech2 = $"C2/2"
@onready var speech3 = $"C3/3"
@onready var speech4 = $"C4/4"

#=================== INTERACTION ====================
@onready var b_hover = $BHover/Sprite2D

# =================== Freeze Flag ===================
var frozen = false

# ==========================================================
# READY (SPAWN + MOUSE CAPTURE)
# ==========================================================
func _ready():
	GameState.interaction_locked = false
	speed = WALK_SPEED 
	floor_max_angle = deg_to_rad(75.0)

	# إخفاء الماوس فوراً عند بدء اللعبة
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# منطق الانترو (Intro Logic)
	var _cs := get_tree().current_scene
	if anim_player and anim_player.has_animation("wake_up") and _cs and _cs.scene_file_path == "res://assets/main/main.tscn":
		set_physics_process(false) # تعطيل الحركة أثناء الانيميشن
		
		anim_player.play("wake_up")
		
		$C2.visible = false
		speech1.play("s1")
		await speech1.animation_finished
		$C1.visible = false
		
		$C2.visible = true
		speech2.play("s2")
		await speech2.animation_finished
		$C2.visible = false
		
		if anim_player.is_playing():
			await anim_player.animation_finished
		
		anim_player.stop()
		speech1.stop()
		speech2.stop()

		head.rotation = Vector3.ZERO
		set_physics_process(true) # تفعيل الحركة بعد الاستيقاظ
		
		speech3.play("s3")
		await speech3.animation_finished
		$C3.visible = false
		speech3.stop()
		
		speech4.play("s4")
		await speech4.animation_finished
		$C4.visible = false
		speech4.stop()
	else:
		set_physics_process(true)

	await get_tree().process_frame
	
	# منطق الـ Spawn Points
	if get_node_or_null("/root/FadeLayer") != null:
		var spawn_name = FadeLayer.next_spawn_name
		var _sc := get_tree().current_scene
		if _sc and _sc.has_node("SpawnPoints"):
			var spawns = _sc.get_node("SpawnPoints")
			if spawns.has_node(spawn_name):
				var spawn_point = spawns.get_node(spawn_name)
				global_transform = spawn_point.global_transform
				_snap_to_floor()
			else:
				push_warning("SpawnPoints/%s yok (%s); sahnedeki Player konumuna dusuldu" % [spawn_name, _sc.name])

	# تأكيد أخير لوضع الماوس
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if GameState.flashlight_on:
		$Head/Camera3D/flash.visible = true

## Spawn markerlari zemine gore ~0.4 m asagida duruyor; govde merkezi dogru
## yukseklige cekilmezse oyuncu her geciste zemine gomulup fizik tarafindan
## disari firlatiliyor (titreme + yan yon kaymasi).
## Beklemeden isin atilir: bir fizik karesi beklesem gravite oyuncuyu zaten
## zeminden disari dogru iter.
func _snap_to_floor() -> void:
	var space := get_world_3d().direct_space_state
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * 0.9,
		global_position - Vector3.UP * 2.0,
		0xFFFFFFFF, [get_rid()]))
	if not hit.is_empty():
		global_position.y = hit.position.y + SPAWN_FOOT_Y

# ==========================================================
# MOUSE LOOK
# ==========================================================
func _input(event):
	if frozen:
		return

	if not is_physics_processing():
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		head.rotate_x(-event.relative.y * SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

# ==========================================================
# PHYSICS PROCESS
# ==========================================================
func _physics_process(delta):
	if frozen:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Sprint
	speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

	# Movement logic
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			
			# صوت الخطوات
			var cs := get_tree().current_scene
			var csp := cs.scene_file_path if cs else ""
			if csp == "res://assets/main/main.tscn":
				var main_steps = get_node_or_null("../footSteps")
				if main_steps and not main_steps.playing:
					main_steps.play(4)
			else:
				if csp == "res://assets/Dream/dream.tscn":
					var steps = get_node_or_null("../steps")
					if steps and not steps.playing:
						steps.play(0.87)
					
				else:
					var snode := Steps.get_node_or_null(_step_node_name())
					if snode == null:
						snode = Steps.get_node("wood_footsteps")
					if snode and not snode.playing:
						snode.play(2)
		else:
			var main_steps = get_node_or_null("../footSteps")
			if main_steps: 
				await get_tree().create_timer(0.20).timeout
				main_steps.stop()
			
			var steps = get_node_or_null("../steps")
			if steps: 
				await get_tree().create_timer(0.25).timeout
				steps.stop()
			for sn in ["wood_footsteps", "concrete_footsteps", "metal_footsteps", "water_footsteps"]:
				var n = Steps.get_node_or_null(sn)
				if n:
					n.stop()

			velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 7.0)

	# Headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV Change
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

	# Interaction Inputs
	if Input.is_action_just_pressed("activate"):
		activate()
	
	check_hover_collision()
	
	# Flashlight logic
	if Input.is_action_just_pressed("flash") and GameState.flashpicked:
		GameState.flashlight_on = not GameState.flashlight_on
		$Head/Camera3D/flash.visible = GameState.flashlight_on

# ==========================================================
# HELPERS
# ==========================================================
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2.0) * BOB_AMP
	return pos

func check_hover_collision():
	if raycast.is_colliding():
		var hover_collider = raycast.get_collider()
		if hover_collider and is_instance_valid(hover_collider) and hover_collider.has_method("interact"):
			if current_interactable != hover_collider:
				if current_interactable:
					current_interactable.hide_prompt()
				current_interactable = hover_collider
				current_interactable.show_prompt()
				if b_hover: b_hover.visible = false
		else:
			hide_current_prompt()
	else:
		hide_current_prompt()

func hide_current_prompt():
	if current_interactable:
		current_interactable.hide_prompt()
		current_interactable = null
	if b_hover:
		b_hover.visible = true

func activate():
	if raycast.is_colliding():
		var hit = raycast.get_collider()
		if hit and hit.has_method("interact"):
			hit.interact()

# ================= Freeze Control Functions =================
func freeze():
	frozen = true
	# إيقاف أصوات الخطوات عند التجميد
	var main_steps = get_node_or_null("../footSteps")
	if main_steps: main_steps.stop()
	for sn in ["wood_footsteps", "concrete_footsteps", "metal_footsteps", "water_footsteps"]:
		var n = Steps.get_node_or_null(sn)
		if n:
			n.stop()


func _step_node_name() -> String:
	match String(GameState.step_surface):
		"concrete": return "concrete_footsteps"
		"metal": return "metal_footsteps"
		"water": return "water_footsteps"
		_: return "wood_footsteps"

func unfreeze():
	frozen = false
