extends Node

var is_mobile = false
var mouse_locked = false

func _ready():
	is_mobile = OS.has_touchscreen_ui_hint()


func _unhandled_input(event):
	# Mobile: ignore capture/lock entirely
	if is_mobile:
		_handle_mobile_input(event)
		return

	_handle_desktop_input(event)


func _handle_desktop_input(event):
	# --- Lock on left-click ---
	if not mouse_locked:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_locked = true

	# --- Unlock on ESC ---
	if mouse_locked and event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_locked = false


func _handle_mobile_input(event):
	# Mobile: no pointer lock, no prints
	pass
