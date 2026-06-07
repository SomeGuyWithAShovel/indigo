extends NavigationRegion3D
class_name NavMesh

@onready var nav_region : NavigationRegion3D = $".";
var calc_finished := true;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DayNightSystem.on_night_start.connect(recalculate_navmesh);

func recalculate_navmesh() -> void:
	nav_region.bake_navigation_mesh();
	calc_finished = false;
	nav_region.bake_finished.connect(func (): calc_finished = true);
