extends BarContainer
class_name QuotaContainer

@onready var days_left_indication : Label = $"HBoxContainer2/Number Days Left";
@onready var accompanying_text : Label = $"HBoxContainer2/Days Left";
@export var text_singular : String = "day)"
@export var text_plural : String = "days)"

@export var regular_color : Color = Color.WHITE;
@export var urgent_color : Color = Color.CRIMSON;

var is_complete := false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	DayNightSystem.days_left_for_quota_changed.connect(update_days_left_indication);
	DayNightSystem.spent_on_quota_changed.connect(update_completeness);
	
func set_progress(value : int, max_value : int) -> void:
	super.set_progress(value, max_value);
	update_completeness(DayNightSystem.spent_on_quota, DayNightSystem.quota);
	update_days_left_indication(DayNightSystem.days_left_for_quota);
	
func update_completeness(current_crystals_in_quota : int, quota_total : int) -> void:
	is_complete = current_crystals_in_quota >= quota_total;
	
func update_days_left_indication(days_left : int) -> void:
	days_left_indication.text = str(days_left);
	days_left_indication.add_theme_color_override("font_color", regular_color);
	if days_left <= 1:
		accompanying_text.text = text_singular;
		if not is_complete:
			days_left_indication.add_theme_color_override("font_color", urgent_color);
	else:
		accompanying_text.text = text_plural;
