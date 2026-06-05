class_name PlayerBaseModules
extends Node3D

enum Enum {
	None = 0,
	Door = 1,
};

static var scene_array : Array[PackedScene] = [
	null,
	preload("res://game/construction/modules/door_module/door_module.tscn")
];
