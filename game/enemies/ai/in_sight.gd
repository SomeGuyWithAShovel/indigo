# Cherche à savoir si un élément dans les couches précisées
# par layers_looking_for se trouve dans monster.in_sight
#
# Si un target a déjà été défini et qu'il est toujours visible,
# on garde le même, sinon on regarde parmi la liste des cibles
# et on prend le plus proche
#
# Renvoie SUCCESS si une cible a été trouvée 
# (dans quel cas, la variable "target" du blackboard contient la node cible)
# Sinon, renvoie FAILURE (et "target" est vide)
@tool
extends ConditionLeaf

@export_flags_3d_physics var layers_looking_for : int;

func tick(actor: Node, blackboard: Blackboard) -> int:
	var monster : Monster = actor;
	var next_target = null;
	# La valeur par défaut "actor" est parce qu'on veut pas que previous_target soit null
	# mais qu'on veut quand même une valeur pour laquelle element == previous_target soit 
	# toujours fausse.
	var previous_target : Node3D = blackboard.get_value("target", monster.character);
	for element in monster.in_sight:
		var colliders := element.find_children("*", "CollisionObject3D", false);
		if colliders.is_empty():
			continue;
		if colliders.all(func (c : CollisionObject3D) : return c.collision_layer & layers_looking_for == 0): 
			continue;
			
		if element == previous_target:
			next_target = previous_target;
			break;
		elif next_target == null or is_closer(element, next_target, actor):
			next_target = element;
	
	if next_target != null:
		blackboard.set_value("target", next_target);
		return SUCCESS;
	else:
		blackboard.erase_value("target");
		return FAILURE;
	
func is_closer(elem : Node3D, than : Node3D, to : Node3D) -> bool:
	var elem_dist := to.global_position.distance_squared_to(elem.global_position);
	var than_dist := to.global_position.distance_squared_to(than.global_position);
	return elem_dist < than_dist;
