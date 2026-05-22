class_name PlayerBaseModuleDoor
extends PlayerBaseModule

var cell: PlayerBaseCell = null;

func init_module() -> void :
	cell = get_parent().get_parent() as PlayerBaseCell;
	assert(cell != null);
	return;
