extends VBoxContainer
class_name BarContainer

@onready var bar : TextureProgressBar = $HBoxContainer/ProgressBar;
@onready var value_label : Label = $HBoxContainer/Points;
@onready var max_label : Label = $HBoxContainer/Max;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_progress(0, 1);
	
	
func set_progress(value : int, max_value : int) -> void:
	bar.value = float(value) / max_value;
	value_label.text = str(value);
	max_label.text = str(max_value);
