extends BarContainer
class_name QuotaContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	DayNightSystem.quota_changed.connect(on_quota_change);

func on_quota_change(new_quota : int) -> void:
	bar.max_value = new_quota;
	bar.value = 0;
