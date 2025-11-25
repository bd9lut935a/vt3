extends Node

var mouse_captured = false
var is_mobile = false

func _ready():
	# Detect mobile/touchscreen
	is_mobile = OS.has_touchscreen_ui_hint()

	if is_mobile:
		# Auto "capture" on mobile (since pointer lock isn't supported)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		mouse_captured = true
	else:
		# Desktop behavior
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = false


func _unhandled_input(event):
	if is_mobile:
		# Mobile: ignore capture logic entirely (taps ≠ mouse buttons)
		# Camera should already be in "look" mode automatically
		return

	# --- Desktop mouse click capture ---
	if not mouse_captured:
		if event is InputEventMouseButton \
		and event.button_index == BUTTON_LEFT \
		and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_captured = true
			return

	# --- Release with ESC ---
	if mouse_captured and event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = false
