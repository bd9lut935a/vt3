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

	# No more capture requirements
	print("FPV: Running in capture-free mode.")


func _input(event):
	# --- Toggle fly mode ---
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_F:
			fly_mode = !fly_mode

	# --- Desktop mouse motion ---
	if event is InputEventMouseMotion:
		_apply_look(event.relative)

	# --- Mobile touch drag (becomes look movement) ---
	if event is InputEventScreenDrag:
		_apply_look(event.relative)


func _apply_look(relative):
	if relative.length_squared() == 0:
		return

	# Horizontal look (yaw)
	rotate_y(deg2rad(-relative.x * mouse_sensitivity))

	# Vertical look (pitch)
	cam.rotate_x(deg2rad(-relative.y * mouse_sensitivity))
	cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -85, 85)


func _physics_process(delta):
	var direction = Vector3.ZERO

	# Desktop or onscreen button mappings
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
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = jump_strength

		velocity = move_and_slide(velocity, Vector3.UP)
