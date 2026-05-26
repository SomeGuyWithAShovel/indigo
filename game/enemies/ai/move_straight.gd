@tool
extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var monster : Monster = actor;
	var target : Node3D = blackboard.get_value("target");
	assert(target != null, "Aucune cible à approcher");
	var direction := (target.global_position - monster.character.global_position).normalized();
	monster.character.velocity = monster.speed * direction;
	return SUCCESS;
