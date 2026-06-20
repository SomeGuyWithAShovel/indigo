extends Node

@onready var lifetime : Timer = $Lifetime;
@onready var particles : GPUParticles3D = $GPUParticles3D;
func _ready() -> void:
	lifetime.timeout.connect(free_once_done);
	
func free_once_done() -> void:
	particles.emitting = false;
	await particles.finished;
	queue_free();
