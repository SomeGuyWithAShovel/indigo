extends PanelContainer
class_name Confirmation

signal on_response(yes : bool);
var response : bool;
@onready var label : Label = $VBoxContainer/Text;
@onready var yes_text : Label = $VBoxContainer/HBoxContainer/Yes;
@onready var no_text : Label  = $VBoxContainer/HBoxContainer/No;

func _ready() -> void:
	on_response.connect(func(got : bool): response = got);

func set_text(new_text : String) -> void:
	label.text = new_text;
	
func is_yes() -> bool:
	await on_response;
	return response;
	
func _on_yes() -> void:
	on_response.emit(true);

func _on_no() -> void:
	on_response.emit(false);
