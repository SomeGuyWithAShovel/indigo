@tool
extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var monster : Monster = actor;
	var target : Node3D = blackboard.get_value("target");
	if target in monster.in_attack_range:
		return SUCCESS;
	else:
		return FAILURE;
