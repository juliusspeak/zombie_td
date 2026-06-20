extends Node3D

@onready var blood_particle: CPUParticles3D = $blood_particle
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D
@onready var cpu_particles_3d_3: CPUParticles3D = $CPUParticles3D3
@onready var cpu_particles_3d_2: CPUParticles3D = $CPUParticles3D2
@onready var cpu_particles_3d_4: CPUParticles3D = $CPUParticles3D4
@onready var cpu_particles_3d_5: CPUParticles3D = $CPUParticles3D5

var fin: int = 0

func _ready() -> void:
	blood_particle.emitting = true
	cpu_particles_3d.emitting = true
	cpu_particles_3d_3.emitting = true
	cpu_particles_3d_2.emitting = true
	cpu_particles_3d_4.emitting = true
	cpu_particles_3d_5.emitting = true

func _on_blood_particle_finished() -> void:
	fin += 1
	check_fin()

func _on_cpu_particles_3d_finished() -> void:
	fin += 1
	check_fin()

func _on_cpu_particles_3d_3_finished() -> void:
	fin += 1
	check_fin()
func check_fin() -> void:
	if fin == 6:
		queue_free()
