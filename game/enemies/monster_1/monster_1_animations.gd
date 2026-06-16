extends Node3D
class_name Monster1Animations;

@onready var animations : AnimationPlayer = $AnimationPlayer;

enum Anim {
	IDLE,
	WALK,
	ATTACK,
	HURT,
}

# Priorité : Attack > Hurt > Walk > Idle

func is_hurt_playing() -> bool:
	return animations.current_animation == &"HitRecieve";

func start_attack() -> void:
	_play(&"Bite_Front");
	
func start_idle() -> void:
	animations.animation_finished.connect(func (_name : String):
		_play(&"Idle");
	);
	
func start_walk() -> void:
	if not [&"HitRecieve", &"Bite_Front"].any(
		func (a): return animations.current_animation == a
	):
		_play(&"Walk");
	
func start_hurt() -> void:
	if not [&"HitRecieve", &"Bite_Front"].any(
		func (a): return animations.current_animation == a
	):
		_play(&"HitRecieve");
	
func disconnect_all() -> void:
	for c in animations.animation_finished.get_connections():
		animations.animation_finished.disconnect(c["callable"]);	

func _play(anim_name : StringName, speed := 1.0) -> void:
	disconnect_all();
	animations.play(anim_name, -1, speed);
	
