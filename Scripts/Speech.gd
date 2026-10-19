class_name Speech
extends RefCounted
## Ortak altyazi oynaticisi.
## Sahnelerdeki Label/AnimationPlayer adlandirmasi sahne basina degistigi icin
## (speech/C1/speech1, ./speech, C1/speech1, finalTruth/speech1 ...) yeni icerik
## tek bir tween deseni kullanir; sahneden sadece Label yolu ister.

const FADE := 0.28


static func say(label: Label, key: String) -> void:
	if label == null or key == "":
		return

	var shown := String(TranslationServer.translate(key))
	if shown.is_empty():
		shown = key

	label.text = key
	label.visible = true
	label.modulate.a = 0.0

	var hold := clampf(float(shown.length()) * 0.06, 2.2, 8.0)
	var tw := label.create_tween()
	tw.tween_property(label, "modulate:a", 1.0, FADE)
	tw.tween_interval(hold)
	tw.tween_property(label, "modulate:a", 0.0, FADE)
	await tw.finished
