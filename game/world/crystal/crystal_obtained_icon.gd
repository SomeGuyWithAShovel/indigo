extends Control
class_name CrystalObtainedIcon

@onready var unprojector : Unprojector = $"Unprojector";
@onready var number_text = $"HBoxContainer/+ Number";

var current_value := 0;
var tween : Tween;

func _enter_tree() -> void:
	reset_self();
	
func start_anim() -> void:
	const ANIM_TIME := 0.6;
	tween = get_tree().create_tween();
	tween.tween_property(unprojector, "position:y", 1.0, ANIM_TIME );
	tween.tween_property(self, "modulate", Color.TRANSPARENT, ANIM_TIME);
	tween.finished.connect(remove_self);
	
func set_value(v : int) -> void:
	number_text.text = "+ %d" % v;
	current_value = v;
	visible = true;
	start_anim();
	
func add_to_value(v : int) -> void:
	set_value(current_value + v);
	
func reset_self() -> void:
	if unprojector != null:
		unprojector.position.y = 0.0;
	modulate = Color.WHITE;
	if tween != null:
		tween.stop();
	
func remove_self() -> void:
	get_parent().remove_child(self);
