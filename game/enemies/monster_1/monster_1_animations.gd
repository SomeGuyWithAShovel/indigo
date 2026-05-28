extends Node3D
class_name Monster1Animations;

@onready var animations : AnimationPlayer = $AnimationPlayer;

enum Anim {
	IDLE,
	WALK,
	ATTACK,
	HURT,
}

func is_hurt_playing() -> bool:
	return animations.current_animation == &"HitRecieve";

func start_attack() -> void:
	_play(&"Bite_Front");
	
func start_idle() -> void:
	animations.animation_finished.connect(func ():
		_play(&"Idle");
	);
	
func start_walk() -> void:
	if animations.current_animation != &"Walk":
		_play(&"Walk");
	
func start_hurt() -> void:
	_play(&"HitRecieve");
	
func disconnect_all() -> void:
	for c in animations.animation_finished.get_connections():
		animations.animation_finished.disconnect(c["callable"]);	

func _play(anim_name : StringName, speed := 1.0) -> void:
	disconnect_all();
	animations.play(anim_name, -1, speed);
	
