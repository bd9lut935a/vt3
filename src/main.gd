extends Node

var mouse_captured = false

func _ready():
	# Start mouse free and visible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func _unhandled_input(event):
	# --- Capture mouse on left click ---
	if not mouse_captured:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_captured = true
			return

	# --- Release with ESC ---
	if mouse_captured and event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = false
