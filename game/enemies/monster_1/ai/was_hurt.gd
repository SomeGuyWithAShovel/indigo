@tool
extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var monster : Monster = actor;
	if monster.animations.is_hurt_playing():
		return SUCCESS;
	else:
		return FAILURE;
