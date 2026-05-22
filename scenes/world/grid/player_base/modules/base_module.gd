class_name PlayerBaseModule
extends Node3D

signal removed();

func init_module() -> void :
	return;

func as_enum() -> PlayerBaseModules.Enum :
	return PlayerBaseModules.Enum.None;

func remove() -> void :
	# animation that takes time
	removed.emit();
	queue_free();
	return;
