extends MarginContainer
class_name BuildingUIButton;

@onready var button : Button = $MarginContainer/Button;
@onready var crystal_price : Label = $MarginContainer/CrystalPrice;
@onready var action_point_price : Label = $MarginContainer/ActionPointPrice;

func set_prices(crystals : int, action_points : int) -> void:
	crystal_price.text = str(crystals);
	action_point_price.text = str(action_points);
