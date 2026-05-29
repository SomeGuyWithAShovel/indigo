extends Node3D
class_name WaveSpawnPoint

@onready var wave_generator : WaveGenerator = $"..";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wave_generator.wave_spawn_points.append(self);
