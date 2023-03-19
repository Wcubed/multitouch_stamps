extends HBoxContainer

@onready var stamp_label := %StampLabel
@onready var stamp_detector: StampDetector = %StampDetector
@onready var stamp_target := %StampTarget

func _ready():
	var small_stamp_size := stamp_detector.get_small_stamp_size()
	stamp_target.custom_minimum_size = small_stamp_size

func _on_stamp_detector_stamp_detected(stamp: String):
	if stamp == "pompebled":
		stamp_label.text = ""
	else:
		stamp_label.text += stamp
