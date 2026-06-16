extends Node3D
class_name PlayerAnimation

@onready var animation_player:AnimationPlayer = $AnimationPlayer;

func play_forward():
	if !animation_player.current_animation == "Run2":
		animation_player.stop()
	animation_player.play("Run2")
func play_idle():
	if !animation_player.current_animation == "Idle2":
		animation_player.stop()
	animation_player.play("Idle2")
