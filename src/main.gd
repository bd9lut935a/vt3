extends Node

var mouse_captured = false
var start_overlay

# Reference to the player and camera
onready var player = $FPV       # adjust path to your KinematicBody
onready var cam = player.get_node("Camera")

func _ready():
	# Start with mouse visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

	# --- Create a fullscreen overlay ---
	start_overlay = ColorRect.new()
	start_overlay.color = Color(0,0,0,0.5)   # semi-transparent black
	start_overlay.anchor_left = 0
	start_overlay.anchor_top = 0
	start_overlay.anchor_right = 1
	start_overlay.anchor_bottom = 1
	start_overlay.margin_left = 0
	start_overlay.margin_top = 0
	start_overlay.margin_right = 0
	start_overlay.margin_bottom = 0
	start_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(start_overlay)

	# Add a centered label
	var label = Label.new()
	label.text = "Tap / Click to Start"
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.rect_min_size = get_viewport().size
	start_overlay.add_child(label)

	# Connect gui_input so taps/clicks are captured
	start_overlay.connect("gui_input", self, "_on_overlay_gui_input")


func _on_overlay_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_captured = true
		start_overlay.visible = false
