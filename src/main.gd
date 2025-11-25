extends Node

var is_mobile = false
var mouse_locked = false

func _ready():
	is_mobile = OS.has_touchscreen_ui_hint()
	print("=== RAW INPUT TEST ACTIVE ===")
	print("MOBILE?: ", is_mobile)
	print("Mouse mode:", Input.get_mouse_mode())

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
			print("Mouse locked!")

	# --- Unlock on ESC ---
	if mouse_locked and event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_locked = false
		print("Mouse unlocked!")


	# --- Debug logs ---
	if event is InputEventMouseMotion:
		print("MOUSE MOTION:", event.relative)


func _handle_mobile_input(event):
	# Mobile: just log events
	if event is InputEventMouseMotion:
		print("MOUSE MOTION:", event.relative)
	if event is InputEventScreenDrag:
		print("SCREEN DRAG:", event.relative)
	if event is InputEventScreenTouch:
		print("TOUCH:", "pressed" if event.pressed else "released", "index:", event.index)
