extends Node3D
## Backrooms stalker: oyuncu tetik alanina girince beliren, kovan, yakalayinca
## jumpscare + olum + level spawn'a geri donen varlik. monster.obj mesh'i kullanir.
## Sahnedeki "entity" dugumune asilir; cocuklar Body/Trigger/Scare/Growl/Scream.

@export var chase_speed: float = 2.6
@export var despawn_radius: float = 16.0
@export var catch_time: float = 1.7
@export var body_path: NodePath = NodePath("Body")
@export var trigger_path: NodePath = NodePath("Trigger")
@export var scare_root_path: NodePath = NodePath("Scare")
@export var scare_path: NodePath = NodePath("Scare/Black/Tex")
@export var growl_path: NodePath = NodePath("Growl")
@export var scream_path: NodePath = NodePath("Scream")

var _player: Node3D = null
var _state := 0   # 0 gizli, 1 kovaliyor, 2 yakalandi
var _body: MeshInstance3D
var _scare: Control
var _scare_root: CanvasLayer


func _ready() -> void:
	_body = get_node_or_null(body_path) as MeshInstance3D
	_scare = get_node_or_null(scare_path) as Control
	_scare_root = get_node_or_null(scare_root_path) as CanvasLayer
	if _body:
		_body.visible = false
	if _scare_root:
		_scare_root.visible = false
	if _scare:
		_scare.modulate.a = 0.0
	var trig := get_node_or_null(trigger_path) as Area3D
	if trig:
		trig.body_entered.connect(_on_trigger)
	set_process(false)


func _player_node() -> Node3D:
	if _player and is_instance_valid(_player):
		return _player
	_player = get_tree().current_scene.find_child("Player", true, false) as Node3D
	return _player


func _on_trigger(body: Node3D) -> void:
	if _state != 0 or body.name != "Player":
		return
	_state = 1
	if _body:
		_body.visible = true
	var g := get_node_or_null(growl_path) as AudioStreamPlayer3D
	if g:
		g.play()
	set_process(true)


func _process(delta: float) -> void:
	if _state != 1:
		return
	var p := _player_node()
	if p == null:
		return
	var to := p.global_position - global_position
	to.y = 0.0
	var dist := to.length()
	if dist > despawn_radius:
		_reset()
		return
	global_position += to.normalized() * chase_speed * delta
	if dist > 0.1:
		look_at(Vector3(p.global_position.x, global_position.y, p.global_position.z), Vector3.UP)
	if dist < 1.2:
		_catch(p)


func _catch(p: Node3D) -> void:
	if _state == 2:
		return
	_state = 2
	set_process(false)
	if p.has_method("freeze"):
		p.freeze()
	var s := get_node_or_null(scream_path)
	if s:
		s.play()
	if _scare_root:
		_scare_root.visible = true
	if _scare:
		var tw := _scare.create_tween()
		tw.tween_property(_scare, "modulate:a", 1.0, 0.12)
	await get_tree().create_timer(catch_time).timeout
	GameState.sanity = maxf(0.0, float(GameState.sanity) - 35.0)
	GameState.deaths += 1
	get_tree().reload_current_scene()


func _reset() -> void:
	_state = 0
	set_process(false)
	if _body:
		_body.visible = false
	var g := get_node_or_null(growl_path) as AudioStreamPlayer3D
	if g:
		g.stop()
