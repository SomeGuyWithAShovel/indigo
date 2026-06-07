extends BarContainer

func set_progress(value : int, max_value : int) -> void:
	super.set_progress(max_value - value, max_value);
	value_label.text = str(value);
	max_label.text = str(max_value);
