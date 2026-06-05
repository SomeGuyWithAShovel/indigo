extends Node3D
class_name Projectile

@export var damage := 5
@export var speed := 1

var direction:Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if direction != null:
		pass
		look_at(global_position + direction)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Pas de node terrain donc pas possible de passer par event
	#TODO l'ajouter
	global_translate(direction*speed*delta)
	if position.y <= -0.2:
		_explode()
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	var entity = body.owner
	#Au contact d'un monstre
	if entity is Monster:
		_explode()
		
	pass # Replace with function body.

func _explode():
	var entity_detected = $ExplosionRadius.get_overlapping_bodies()
	for entity in entity_detected:
		var entity_node = entity.owner
		if entity_node is Monster:
			entity_node.health_component.hurt(damage)
	queue_free()
	pass
