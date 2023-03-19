extends CenterContainer

const INCH_TO_CM := 2.54

var touches = {}

# How many dots (for now we assume that is pixels) per centimeter on the screen.
# Is valid after the `_ready()` function of this node has run.
var dots_per_centimeter := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_id := DisplayServer.window_get_current_screen()
	var screen_dpi := DisplayServer.screen_get_dpi(screen_id)
	dots_per_centimeter = screen_dpi / INCH_TO_CM
	
	print("dots per cm: %s" % dots_per_centimeter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
		
		process_touches()
	
	if event is InputEventScreenDrag:
		touches[event.index] = event.position
		process_touches()

func process_touches():
	if touches.size() == 3:
		var values := touches.values()
		var distances := calculate_distances_clockwise(values[0], values[1], values[2])
		$Label.text = str(distances)

# Calculates the distances between three points in cm, and returns them in
# clockwise order, regardless of the original order of the points.
func calculate_distances_clockwise(p0: Vector2, p1: Vector2, p2: Vector2) -> Vector3:
	var angle := p0.angle_to(p1)
	var distances := Vector3.ZERO
	
	if angle <= 0:
		# Points are in clockwise order
		distances.x = p0.distance_to(p1)
		distances.y = p1.distance_to(p2)
		distances.z = p2.distance_to(p0)
	else:
		# Points are in counterclockwise order
		distances.x = p0.distance_to(p2)
		distances.y = p2.distance_to(p1)
		distances.z = p1.distance_to(p0)
	
	# Scale so we return the distances in centimeters.
	distances /= dots_per_centimeter
	
	return distances
