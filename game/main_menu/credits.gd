extends PanelContainer
class_name Credits

signal on_response(yes : bool);
var response : bool;

func _ready() -> void:
	on_response.connect(func(got : bool): response = got);

func is_ok() -> bool:
	await on_response;
	get_parent().remove_child(self);
	queue_free();
	return response;

func _on_ok_pressed() -> void:
	on_response.emit(true);
