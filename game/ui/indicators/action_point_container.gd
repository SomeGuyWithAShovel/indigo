extends BarContainer

func set_progress(value : int, max_value : int) -> void:
	super.set_progress(max_value - value, max_value);
	text.text = "%d / %d" % [value, max_value];
