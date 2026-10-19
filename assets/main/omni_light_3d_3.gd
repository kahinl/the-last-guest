extends OmniLight3D

@export var min_energy: float = 0.2
@export var max_energy: float = 2.0
@export var lerp_speed: float = 5.2 

var target_energy: float = 1.0

func _process(delta):
	# If we are close to the target, pick a new random target
	if abs(light_energy - target_energy) < 0.1:
		target_energy = randf_range(min_energy, max_energy)
	
	# Smoothly move the current energy toward the target energy
	light_energy = lerp(light_energy, target_energy, lerp_speed * delta)
