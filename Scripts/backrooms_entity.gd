extends Node3D
## Backrooms varligi — ARTIK KOVALAMIYOR, SESI TAKIP EDIYOR.
##
## Duvara kazinmis kural (level2_help: "IT FOLLOWS THE SOUND YOU MAKE. BE
## STILL.") eskiden yalandi: Trigger'a giren oyuncuya kilitlenip kosuyordu ve
## varlik 2.6 m/s > oyuncu 2.2 m/s oldugu icin bir kere tetiklenince kurtulus
## yoktu (fanlarin "asiri kullanilmis" dedigi kovala → jumpscare → olum dongusu
## + kazanimi olmayan bir karsilasma).
##
## Simdi kural gercek: hareket ettigin surece yaklasir, DURDUGUN ANDA oldugu
## yerde kalir ve bir kac saniye sonra geri cekilir. Kacmak icgudusu olum,
## durmak icgudusu hayattir.
##
## Sahnedeki "entity" dugumune asilir; cocuklar Body/Trigger/Scare/Growl/Scream.

@export var chase_speed: float = 2.6
##  Uyaniş icin gereken dikkat birikimi.
@export var wake_alert: float = 0.5
##  Sesin dikkati yukseltme / sessizligin sondurme hizi.
@export var alert_gain: float = 0.5
@export var alert_decay: float = 0.35
##  Oyuncu bu kadar sure tam sessiz kalirsa varlik ilgilenmeyi birakir.
@export var give_up_time: float = 3.0
@export var catch_radius: float = 1.2
@export var despawn_radius: float = 24.0
@export var body_path: NodePath = NodePath("Body")
@export var trigger_path: NodePath = NodePath("Trigger")
@export var scare_root_path: NodePath = NodePath("Scare")
@export var scare_path: NodePath = NodePath("Scare/Black/Tex")
@export var growl_path: NodePath = NodePath("Growl")
@export var scream_path: NodePath = NodePath("Scream")

var _player: Node3D = null
var _state := 0          # 0 uyuyor, 1 sesi takip ediyor, 2 yakaladi
var _alert := 0.0
var _quiet := 0.0
var _in_zone := false
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
		trig.body_entered.connect(_on_zone_entered)
		trig.body_exited.connect(_on_zone_exited)
	set_process(false)


func _player_node() -> Node3D:
	if _player and is_instance_valid(_player):
		return _player
	_player = get_tree().current_scene.find_child("Player", true, false) as Node3D
	return _player


##  Trigger artik kovalamacayi BASLATMIYOR; bölgeye girildigini söylüyor,
##  uyanma yalnizca ses birikince oluyor.
func _on_zone_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	_in_zone = true
	_player = body
	set_process(true)


func _on_zone_exited(body: Node3D) -> void:
	if body.name == "Player":
		_in_zone = false


func _process(delta: float) -> void:
	var p := _player_node()
	if p == null:
		return
	var to := p.global_position - global_position
	to.y = 0.0
	var dist := to.length()
	if dist > despawn_radius:
		_sleep()
		return

	var nz := float(p.get("noise")) if p.get("noise") != null else 0.0
	if nz > 0.04:
		_alert += alert_gain * nz * delta
		_quiet = 0.0
	else:
		_alert = maxf(0.0, _alert - alert_decay * delta)
		_quiet += delta

	if _state == 0:
		if _alert >= wake_alert:
			_wake()
		elif not _in_zone and _alert <= 0.01:
			set_process(false)
		return

	if _quiet >= give_up_time:
		_sleep()
		return

	#  Hiz dogrudan sese bagli: oyuncu durursa varlik da oldugu yerde kalir.
	if nz > 0.02 and dist > catch_radius * 0.5:
		global_position += to.normalized() * chase_speed * minf(nz * 1.6, 1.0) * delta
		look_at(Vector3(p.global_position.x, global_position.y, p.global_position.z), Vector3.UP)
	if dist < catch_radius:
		_catch(p)


func _wake() -> void:
	_state = 1
	if _body:
		_body.visible = true
	var g := get_node_or_null(growl_path) as AudioStreamPlayer3D
	if g and not g.playing:
		g.play()


func _sleep() -> void:
	_state = 0
	_alert = 0.0
	_quiet = 0.0
	set_process(false)
	if _body:
		_body.visible = false
	var g := get_node_or_null(growl_path) as AudioStreamPlayer3D
	if g:
		g.stop()


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
	await get_tree().create_timer(1.7).timeout
	GameState.sanity = maxf(0.0, float(GameState.sanity) - 35.0)
	GameState.deaths += 1
	get_tree().reload_current_scene()
