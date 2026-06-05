class_name PlayerBaseCell
extends Node3D

# base class for all cells, so we have a fixed type (like a typedef, not really a class).
# if you want to add something to all cells of any type, 
# prefer adding a Dictionary[Vector2i, YourNewData] into player_base.gd

@onready var health : HealthComponent = $HealthComponent;
