extends VBoxContainer
class_name BarContainer

@onready var bar : TextureProgressBar = $HBoxContainer/ProgressBar;
@onready var text : Label = $HBoxContainer/Text;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_progress(0, 1);
	
	
func set_progress(value : int, max_value : int) -> void:
	bar.value = float(value) / max_value;
	text.text = "%d / %d" % [value, max_value];
	
