extends HBoxContainer

class_name MainScene

const INCH_TO_CM := 2.54

const STAMPS := {
	"pompebled": Vector3(2.4, 2.9, 1.4),
	"a": Vector3(1.969314, 2.469305, 2.372725),
	"b": Vector3(1.937385, 2.934361, 2.406385),
	"c": Vector3(1.565544, 3.834364, 3.297796),
	"d": Vector3(1.962911, 3.419257, 2.87974),
	"e": Vector3(2.416332, 2.91253, 2.842146),
	"f": Vector3(1.644731, 2.494588, 1.93429),
	"g": Vector3(1.470986, 3.403781, 3.372168),
	"h": Vector3(1.453483, 2.923801, 2.398501),
	"i": Vector3(1.965146, 2.927614, 2.831296),
	"j": Vector3(1.498162, 2.479017, 2.39091),
	"k": Vector3(1.506153, 3.412493, 2.874923),
	"l": Vector3(1.567059, 2.929137, 2.849347),
	"m": Vector3(2.421995, 4.353142, 4.348523),
	"n": Vector3(1.921992, 3.878833, 3.835371),
	"o": Vector3(2.514679, 3.472353, 3.300535),
	"p": Vector3(2.512779, 3.439055, 2.871323),
	"q": Vector3(1.552657, 4.409062, 3.853091),
	"r": Vector3(2.477543, 3.89338, 3.338841),
	"s": Vector3(2.460307, 3.822031, 3.712632),
	"t": Vector3(1.926067, 4.381492, 4.329115),
	"u": Vector3(1.917859, 3.376089, 3.353231),
	"v": Vector3(2.429095, 4.37894, 3.833152),
	"w": Vector3(1.959587, 3.887854, 3.358193),
	"x": Vector3(1.435212, 3.895373, 3.848233),
	"y": Vector3(1.971067, 4.372471, 3.810109),
	"z": Vector3(1.502065, 1.920141, 1.901693),
	"â": Vector3(1.962067, 2.385168, 2.933474),
	"ê": Vector3(1.949737, 2.870292, 3.377526),
	"ô": Vector3(1.957021, 3.375432, 3.875288),
	"û": Vector3(2.422755, 2.870753, 3.394945),
	"ú": Vector3(2.424266, 3.376692, 3.880038),
	"aa": Vector3(2.910386, 3.364624, 3.411157),
	"au": Vector3(2.973768, 4.802044, 4.442061),
	"ch": Vector3(5.373574, 5.259558, 3.471039),
	"ea": Vector3(4.283, 4.311345, 3.173153),
	"ee": Vector3(2.939046, 3.820182, 3.901917),
	"ei": Vector3(4.841149, 4.274446, 3.39358),
	"ie": Vector3(4.82165, 4.804228, 3.395809),
	"ii": Vector3(3.049665, 5.776886, 5.402436),
	"ij": Vector3(2.958445, 4.332687, 3.891875),
	"iuw": Vector3(5.278875, 4.78138, 2.327282),
	"oa": Vector3(2.952196, 4.322946, 4.382193),
	"oe": Vector3(3.893542, 3.85098, 3.390139),
	"ou": Vector3(5.339694, 4.807897, 3.392943),
	"sj": Vector3(2.907375, 4.793912, 4.844143),
	"sk": Vector3(2.458856, 4.813676, 4.352488),
	"stj": Vector3(3.884907, 3.340483, 2.916674),
	"tsj": Vector3(2.917713, 5.267601, 4.821241),
	"ue": Vector3(2.907375, 5.292469, 5.311097),
	"ui": Vector3(4.342922, 3.816896, 3.380627),
	"uo": Vector3(4.846851, 4.832982, 3.835526),
}

# How far off are distances allowed to be to still be considered to match.
const MATCH_TOLERANCE_CM := 0.25

var touches = {}
var last_detected_distances: Vector3

# How many dots (for now we assume that is pixels) per centimeter on the screen.
# Is valid after the `_ready()` function of this node has run.
var dots_per_centimeter: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_id := DisplayServer.window_get_current_screen()
	var screen_dpi := DisplayServer.screen_get_dpi(screen_id)
	dots_per_centimeter = float(screen_dpi) / INCH_TO_CM


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
		%LetterLabel.text = ""
		var values := touches.values()
		%Label.text = "%s\n%s\n%s\n" % [values[0]/dots_per_centimeter, values[1]/dots_per_centimeter, values[2]/dots_per_centimeter]
		
		var distances := calculate_distances_clockwise(values[0], values[1], values[2])
		var distances_cm := distances / dots_per_centimeter
		%Label.text += "(%.1f, %.1f, %.1f)" % [distances_cm.x, distances_cm.y, distances_cm.z]
		
		for stamp in STAMPS:
			if distances_match_template(distances_cm, STAMPS[stamp]):
				%LetterLabel.text = stamp
		
		last_detected_distances = distances_cm

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
# TODO (2023-03-19): Return _how much_ they are within tolerances. because some stamps are very close to each other.
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


func _on_record_button_pressed():
	print(last_detected_distances)
