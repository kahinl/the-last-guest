extends StaticBody3D
## Genel inceleme / toplama nesnesi. Yeni icerigin tamami bunu kullanir.
## Inspector'dan doldur: flag_name, speech_key, label_path.
## destroy_on_pick = true ise alininca yok olur (kus, kaset, gunluk sayfasi...).
## counter_name/counter_target/reward_key ucuncu kusta G18 odulunu tetikler.

@export var flag_name: String = ""
@export var speech_key: String = ""
@export var second_flag: String = ""
@export var second_key: String = ""
@export var label_path: NodePath = NodePath("../extraSpeech/line")
@export var prompt_path: NodePath = NodePath("play1/hover")
@export var destroy_on_pick: bool = false
@export var requires_flag: String = ""
@export var requires_value: bool = true
@export var counter_name: String = ""
@export var counter_target: int = 0
@export var reward_key: String = ""
@export var reward_flag: String = ""
@export var add_sanity: int = 0

var _used := false


func _ready() -> void:
	if destroy_on_pick and flag_name != "" and bool(GameState.get(flag_name)):
		queue_free()
		return
	_apply_visibility()


func _process(_delta: float) -> void:
	# requires_flag kosulu sahne icinde sonradan saglanabilir (tape1 oynatilinca
	# tape02'nin gorunmesi gibi), o yuzden kosul saglanana kadar kontrol edilir.
	if _requirements_ok():
		set_process(false)
		_apply_visibility()


func _requirements_ok() -> bool:
	return requires_flag == "" or bool(GameState.get(requires_flag)) == requires_value


func _apply_visibility() -> void:
	var ok := _requirements_ok()
	visible = ok
	collision_layer = 1 if ok else 0


func interact() -> void:
	if _used:
		return

	var key := speech_key
	var flag := flag_name

	# Ikinci asamali inceleme: ayna (bath_2 -> symptom_2) gibi
	if flag != "" and bool(GameState.get(flag)) and second_key != "":
		if second_flag != "" and bool(GameState.get(second_flag)):
			return
		key = second_key
		flag = second_flag
	elif flag != "" and bool(GameState.get(flag)):
		return

	# Konusma boyunca kilit; iki asamali incelemelerde ikinci tur icin tekrar acilir
	_used = true
	if flag != "":
		GameState.set(flag, true)
	if add_sanity != 0:
		GameState.sanity = clampi(int(GameState.sanity) + add_sanity, 0, 100)

	hide_prompt()
	if destroy_on_pick:
		visible = false
		collision_layer = 0

	await Speech.say(_label(), key)

	if counter_name != "":
		var total: int = int(GameState.get(counter_name)) + 1
		GameState.set(counter_name, total)
		if counter_target > 0 and total >= counter_target and reward_key != "":
			if reward_flag == "" or not bool(GameState.get(reward_flag)):
				if reward_flag != "":
					GameState.set(reward_flag, true)
				var rl := _label()
				if rl:
					await get_tree().create_timer(0.9).timeout
					await Speech.say(rl, reward_key)

	_used = false

	if destroy_on_pick:
		queue_free()


func _label() -> Label:
	return get_node_or_null(label_path) as Label


func show_prompt() -> void:
	var p := get_node_or_null(prompt_path)
	if p:
		p.visible = true


func hide_prompt() -> void:
	var p := get_node_or_null(prompt_path)
	if p:
		p.visible = false
