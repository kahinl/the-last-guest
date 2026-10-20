extends Node3D

##  epi_* / garden_* anahtarlari lang.csv'de yaziliydi ama hicbir kod veya sahne
##  referans vermiyordu (G27): oyunun cozum cumleleri hic oynanmiyordu.
##  Menu acilmadan once siyah perde uzerinde geciyorlar.
const EPILOGUE := {
	"letgo": ["epi_1", "garden_1", "garden_2", "epi_a"],
	"holdon": ["epi_1", "garden_1", "garden_2", "epi_b"],
	"leave": ["epi_1", "epi_3"],
}


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Wind.stop()
	Comfy.stop()

	# CRT overlay ayari (B5): varsayilan acik, ana menude kapatilabilir.
	var crt := $Buttons/VBoxContainer/crt as CheckButton
	crt.button_pressed = bool(GameState.crt_enabled)
	crt.toggled.connect(_on_crt_toggled)

	var lines := _epilogue_lines()
	if lines.is_empty():
		$CanvasLayer/AnimationPlayer.play("fade_out")
		return

	$Epilogue.visible = true
	for key in lines:
		await Speech.say($Epilogue/Line as Label, key)
	$Epilogue.visible = false
	$CanvasLayer/AnimationPlayer.play("fade_out")


##  *_done bayraklari ayni oturumda birden fazla son icin true kalabildiginden
##  hangisinin AZ once oynandigi GameState.last_ending'den alinir ve oynatildiktan
##  sonra temizlenir; aksi halde menuye her donuste metin tekrar oynar.
func _epilogue_lines() -> Array[String]:
	var out: Array[String] = []
	var which := String(GameState.last_ending)
	GameState.last_ending = ""
	if EPILOGUE.has(which):
		for k in EPILOGUE[which]:
			out.append(String(k))
	if out.is_empty():
		return out
	# Darkwood kurali: arc'i bitiren oyuncunun kapanisina tek satir eklenir.
	# Dorduncu son acilmaz; mevcut sonun son cumlesi agirlasir.
	if bool(GameState.backrooms_survived):
		out.append("epi_ledger")
	return out


func _on_crt_toggled(on: bool) -> void:
	GameState.set_flag("crt_enabled", on)
