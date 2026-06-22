extends Node3D
class_name RepairBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var bar_step = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$Timer.is_stopped():
		print($Control/TextureProgressBar.value)
		$Control/TextureProgressBar.value += bar_step*delta*100

func setRepairTime(max_time:float):
	$Timer.wait_time = max_time

func Interupt():
	$Control/TextureProgressBar.visible = false
	$Timer.stop()

func start_repair():
	$Control/TextureProgressBar.value = 0
	$Control/TextureProgressBar.visible = true
	bar_step = 1.0/$Timer.wait_time
	$Timer.start()
