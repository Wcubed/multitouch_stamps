extends CenterContainer

class_name MainScene

const INCH_TO_CM := 2.54
const POMPEBLED := Vector3(2.4, 2.9, 1.4)

# How far off are distances allowed to be to still be considered to match.
const MATCH_TOLERANCE_CM := 0.3

var touches = {}

# How many dots (for now we assume that is pixels) per centimeter on the screen.
# Is valid after the `_ready()` function of this node has run.
var dots_per_centimeter: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_id := DisplayServer.window_get_current_screen()
	var screen_dpi := DisplayServer.screen_get_dpi(screen_id)
	dots_per_centimeter = float(screen_dpi) / INCH_TO_CM
	
	print("dots per cm: %s" % dots_per_centimeter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
		$Label.text = "%s\n%s\n%s\n" % [values[0]/dots_per_centimeter, values[1]/dots_per_centimeter, values[2]/dots_per_centimeter]
		
		var distances := calculate_distances_clockwise(values[0], values[1], values[2])
		var distances_cm := distances / dots_per_centimeter
		$Label.text += "(%.1f, %.1f, %.1f)" % [distances_cm.x, distances_cm.y, distances_cm.z]
		
		if distances_match_template(distances_cm, POMPEBLED):
			$Label.text += "\nPompebled"

# Calculates the distances between three points in pixels, and returns them in
# clockwise order, regardless of the original order of the points.
static func calculate_distances_clockwise(p0: Vector2, p1: Vector2, p2: Vector2) -> Vector3:
	var dist := Vector3.ZERO
	
	# Not the shortest way of doing this, but it works.
	if p0.x < p1.x and p0.x < p2.x:
		# p0 is leftmost point
		if p1.y > p2.y:
			dist.x = p0.distance_to(p1)
			dist.y = p1.distance_to(p2)
			dist.z = p2.distance_to(p0)
		else:
			dist.x = p0.distance_to(p2)
			dist.y = p2.distance_to(p1)
			dist.z = p1.distance_to(p0)
	elif p1.x < p0.x and p1.x < p2.x:
		# p1 is leftmost point.
		if p0.y > p2.y:
			dist.x = p1.distance_to(p0)
			dist.y = p0.distance_to(p2)
			dist.z = p2.distance_to(p1)
		else:
			dist.x = p1.distance_to(p2)
			dist.y = p2.distance_to(p0)
			dist.z = p0.distance_to(p1)
	else:
		# p2 is leftmost point.
		if p0.y > p1.y:
			dist.x = p2.distance_to(p0)
			dist.y = p0.distance_to(p1)
			dist.z = p1.distance_to(p2)
		else:
			dist.x = p2.distance_to(p1)
			dist.y = p1.distance_to(p0)
			dist.z = p0.distance_to(p2)
	
	return dist


# Returns true if the given distances are within tolerances to the template
# and in the same order.
# Expects both distances and template to be listed clockwise.
func distances_match_template(distances: Vector3, template: Vector3) -> bool:
	if within_tolerance(distances.x, template.x) and within_tolerance(distances.y, template.y) and within_tolerance(distances.z, template.z):
		return true
	elif within_tolerance(distances.y, template.x) and within_tolerance(distances.z, template.y) and within_tolerance(distances.x, template.z):
		return true
	elif within_tolerance(distances.z, template.x) and within_tolerance(distances.x, template.y) and within_tolerance(distances.y, template.z):
		return true
	else:
		return false

# Checks if the value is within `MATCH_TOLERANCE` from the target.
func within_tolerance(value: float, target: float) -> bool:
	var lower := target - MATCH_TOLERANCE_CM
	var upper := target + MATCH_TOLERANCE_CM
	
	return value >= lower and value <= upper
