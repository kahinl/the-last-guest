extends ColorRect

var time_tracker: float = 0.0

func _process(delta: float) -> void:
	time_tracker += delta
	
	# Keep the number between 0 and 100 to prevent precision loss
	# 100 is plenty for a repeating noise effect
	time_tracker = fmod(time_tracker, 100.0)
	
	# Pass the value to the shader
	(material as ShaderMaterial).set_shader_parameter("local_time", time_tracker)
