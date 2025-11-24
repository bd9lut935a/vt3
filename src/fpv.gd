extends KinematicBody

# --- Player Body Settings ---
const PLAYER_HEIGHT = 1.8
const PLAYER_RADIUS = 0.4
const CAMERA_HEIGHT = 1.6

# --- Movement Settings ---
var mouse_sensitivity = 0.1
var speed = 6
var fly_speed = 10
var gravity = -20.0
var jump_strength = 8.0
var velocity = Vector3.ZERO
var fly_mode = false

onready var cam = $Camera
onready var shape = $CollisionShape


func _ready():
	var capsule = CapsuleShape.new()
	capsule.height = PLAYER_HEIGHT
	capsule.radius = PLAYER_RADIUS
	shape.shape = capsule
	cam.translation.y = CAMERA_HEIGHT


func _input(event):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	# Toggle fly mode
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_F:
			fly_mode = not fly_mode

	# Mouse look
	if event is InputEventMouseMotion and event.relative.length_squared() != 0:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		cam.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -85, 85)


func _physics_process(delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		velocity = move_and_slide(Vector3.ZERO, Vector3.UP)
		return

	var direction = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		direction -= transform.basis.z
	if Input.is_action_pressed("ui_down"):
		direction += transform.basis.z
	if Input.is_action_pressed("ui_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("ui_right"):
		direction += transform.basis.x

	direction = direction.normalized()

	if fly_mode:
		velocity = direction * fly_speed

		# Fly up/down directly with E/Q keys
		if Input.is_key_pressed(KEY_E):
			velocity.y = fly_speed
		elif Input.is_key_pressed(KEY_Q):
			velocity.y = -fly_speed
		else:
			velocity.y = 0

		velocity = move_and_slide(velocity, Vector3.UP)
	else:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		velocity.y += gravity * delta

		if is_on_floor():
			if Input.is_action_just_pressed("ui_accept"):  # Space
				velocity.y = jump_strength

		velocity = move_and_slide(velocity, Vector3.UP)
