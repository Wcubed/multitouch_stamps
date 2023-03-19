extends CenterContainer

var presses = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			presses[event.index] = event.position
		else:
			presses.erase(event.index)
		
		update_label_text()
	
	if event is InputEventScreenDrag:
		presses[event.index] = event.position
		update_label_text()

func update_label_text():
	# TODO (2023-03-19): put somewhere else.
	if presses.size() == 3:
		var values := presses.values()
		var distances := calculate_distances_clockwise(values[0], values[1], values[2])
		$Label.text = str(distances)

# Calculates the distances between three points, and returns them in
# clockwise order, regardless of the original order of the points.
func calculate_distances_clockwise(p0: Vector2, p1: Vector2, p2: Vector2) -> Vector3:
	var angle := p0.angle_to(p1)
	
	if angle <= 0:
		# Points are in clockwise order
		var d0 = p0.distance_to(p1)
		var d1 = p1.distance_to(p2)
		var d2 = p2.distance_to(p0)
		return Vector3(d0, d1, d2)
	else:
		# Points are in counterclockwise order
		var d0 = p0.distance_to(p2)
		var d1 = p2.distance_to(p1)
		var d2 = p1.distance_to(p0)
		return Vector3(d0, d1, d2)
	
