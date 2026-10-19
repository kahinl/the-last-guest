extends Node
## Sahneye ilk giriste bir kez oynayan giris monologu (G08 room3, G17 attic).
## Sahne kokune "intro" adinda cocuk Node olarak ekle.

@export var played_flag: String = ""
@export var speech_key: String = ""
@export var label_path: NodePath = NodePath("../extraSpeech/line")
@export var delay: float = 1.6


func _ready() -> void:
	if played_flag != "" and bool(GameState.get(played_flag)):
		return

	await get_tree().create_timer(delay).timeout

	# Sahne yuklu geldiyse (teleport) bir kare bekle; Player/Camera hazir olsun
	await get_tree().process_frame

	# Oyuncu bu arada sahneden ciktiysa bayrak yakilmasin, tekrar girince oynasin
	if not is_inside_tree():
		return
	if played_flag != "":
		if bool(GameState.get(played_flag)):
			return
		GameState.set(played_flag, true)

	var label := get_node_or_null(label_path) as Label
	if label == null:
		push_warning("scene_intro: label bulunamadi: %s" % label_path)
		return
	await Speech.say(label, speech_key)
