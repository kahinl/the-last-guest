extends StaticBody3D
## Genel kapi (kapi_sablonu.gd deseninin Speech'li hali).
## Cat kati gidis-donus ve benzeri yeni kapi ihtiyacini tek dosyadan karsilar.
## Inspector: target_scene, spawn_name, required_flags (virgulle), need_key.

@export_file("*.tscn") var target_scene: String = ""
@export var spawn_name: String = "default"
@export var required_flags: String = ""
@export var need_key: String = "hallWay_need1"
@export var label_path: NodePath = NodePath("../extraSpeech/line")
@export var prompt_path: NodePath = NodePath("play1/hover")


func interact() -> void:
	if not Input.is_action_just_pressed("ui_accept"):
		return

	if _flags_ok():
		FadeLayer.fade_and_change_scene(target_scene, spawn_name)
		return

	await Speech.say(get_node_or_null(label_path) as Label, need_key)


func _flags_ok() -> bool:
	if required_flags.strip_edges() == "":
		return true
	for f in required_flags.split(","):
		if not bool(GameState.get(f.strip_edges())):
			return false
	return true


func show_prompt() -> void:
	var p := get_node_or_null(prompt_path)
	if p:
		p.visible = true


func hide_prompt() -> void:
	var p := get_node_or_null(prompt_path)
	if p:
		p.visible = false
