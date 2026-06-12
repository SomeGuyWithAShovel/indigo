extends Node3D
class_name PlayerAnimation

@onready var animation_player:AnimationPlayer = $AnimationPlayer;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_forward():
	if !animation_player.current_animation == "Run2":
		animation_player.stop()
	animation_player.play("Run2")
func play_idle():
	if !animation_player.current_animation == "Idle2":
		animation_player.stop()
	animation_player.play("Idle2")
