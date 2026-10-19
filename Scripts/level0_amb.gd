extends Node3D
## Level 0 atmosferi: titreyen flüoresan + rastgele uzak fısıltılar + oda-C nefes tetigi.
## Sahnedeki "amb" dugumune asilir; isik/cizgi/alan referanslari inspector'dan.

@export var flicker_light: NodePath
@export var whisper_player: NodePath
@export var breath_area: NodePath
@export var breath_player: NodePath

var _whispers: Array[float] = []
var _rng := RandomNumberGenerator.new()
var _breath_played := false


func _ready() -> void:
	_rng.randomize()
	for i in 3:
		_whispers.append(_rng.randf_range(28.0, 60.0))
	var area := get_node_or_null(breath_area) as Area3D
	if area:
		area.body_entered.connect(_on_breath_area_entered)
	_schedule()


func _process(delta: float) -> void:
	var light := get_node_or_null(flicker_light) as OmniLight3D
	if light:
		var t := Time.get_ticks_msec() / 1000.0
		var f := 0.82 + 0.1 * sin(t * 11.0) + 0.06 * sin(t * 37.0)
		if _rng.randf() < 0.004:
			f *= 0.15
		light.light_energy = maxf(0.05, f)


func _schedule() -> void:
	if _whispers.is_empty():
		return
	await get_tree().create_timer(_whispers.pop_front()).timeout
	var wp := get_node_or_null(whisper_player) as AudioStreamPlayer3D
	if wp:
		wp.play()
	_schedule()


func _on_breath_area_entered(body: Node3D) -> void:
	if _breath_played or body.name != "Player":
		return
	_breath_played = true
	var bp := get_node_or_null(breath_player) as AudioStreamPlayer3D
	if bp:
		bp.play()
