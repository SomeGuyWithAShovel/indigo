@tool
extends ActionLeaf

@export var target_name := "target";

func tick(actor: Node, blackboard: Blackboard) -> int:
	var monster : Monster = actor;
	var target : Node3D = blackboard.get_value(target_name);
	var health_components := target.find_children("*", "HealthComponent", false);
	
	assert(len(health_components) == 1, "Cible de monstre sans HealthComponent ?");
	(health_components[0] as HealthComponent).hurt(monster.attack_damage);
	return SUCCESS;
