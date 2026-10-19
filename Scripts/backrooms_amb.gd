extends Node3D
## Backrooms genellestirilmis atmosfer: titreyen isik + zamanlanmis fisilti,
## uzaktan varlik hirlamasi ve metal/boru sarsintilari. Sahnedeki "amb" dugumune
## asilir; bos birakilan NodePath'lar atlanir.

@export var flicker_light: NodePath
@export var whisper_player: NodePath
@export var growl_player: NodePath
@export var sfx_player: NodePath
@export var surface: String = ""
@export var drain_sanity: bool = false
@export var sanity_rate: float = 0.6

var _rng := RandomNumberGenerator.new()
var _sanity_frac: float = 0.0


func _ready() -> void:
	_rng.randomize()
	if surface != "":
		GameState.step_surface = surface
	_schedule(whisper_player, 22.0, 55.0)
	_schedule(growl_player, 40.0, 90.0)
	_schedule(sfx_player, 15.0, 40.0)


func _process(delta: float) -> void:
	if drain_sanity:
		GameState.sanity = maxi(0, GameState.sanity - int(sanity_rate * delta * 10))
		var rem: float = (sanity_rate * delta * 10) - int(sanity_rate * delta * 10)
		_sanity_frac += rem
		if _sanity_frac >= 1.0:
			GameState.sanity = maxi(0, GameState.sanity - 1)
			_sanity_frac -= 1.0
	if flicker_light.is_empty():
		return
	var light := get_node_or_null(flicker_light) as OmniLight3D
	if light == null:
		return
	var t := Time.get_ticks_msec() / 1000.0
	var f := 0.8 + 0.12 * sin(t * 11.0) + 0.06 * sin(t * 37.0)
	if _rng.randf() < 0.006:
		f *= 0.12
	light.light_energy = maxf(0.05, f)


func _schedule(path: NodePath, lo: float, hi: float) -> void:
	if path.is_empty():
		return
	while true:
		await get_tree().create_timer(_rng.randf_range(lo, hi)).timeout
		if not is_inside_tree():
			return
		var p := get_node_or_null(path) as AudioStreamPlayer3D
		if p and not p.playing:
			p.play()
