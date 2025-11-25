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

var move_forward = false
var move_backward = false
var mouse_locked = false

onready var cam = $Camera
onready var shape = $CollisionShape
onready var forward_btn = $"/root/Main/MobileControls/Forward"
onready var reverse_btn = $"/root/Main/MobileControls/Reverse"
onready var flytoggle_btn = $"/root/Main/MobileControls/FlyToggle"

func _ready():
	# Player collision capsule
	var capsule = CapsuleShape.new()
	capsule.height = PLAYER_HEIGHT
	capsule.radius = PLAYER_RADIUS
	shape.shape = capsule
	cam.translation.y = CAMERA_HEIGHT

	# Connect signals for mobile buttons
	if forward_btn:
		forward_btn.connect("pressed", self, "_on_forward_pressed")
		forward_btn.connect("released", self, "_on_forward_released")
	if reverse_btn:
		reverse_btn.connect("pressed", self, "_on_reverse_pressed")
		reverse_btn.connect("released", self, "_on_reverse_released")
	if flytoggle_btn:
		flytoggle_btn.connect("pressed", self, "_on_flytoggle_pressed")


func _process(delta):
	# Poll button states to avoid sticky movement
	if forward_btn:
		move_forward = forward_btn.is_pressed()
	if reverse_btn:
		move_backward = reverse_btn.is_pressed()


func _input(event):
	# --- Fly toggle with F key ---
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_F:
		fly_mode = !fly_mode

	# --- Look input (mouse or touch) ---
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		_apply_look(event.relative)


func _apply_look(relative):
	if relative.length_squared() == 0:
		return
	rotate_y(deg2rad(-relative.x * mouse_sensitivity))
	cam.rotate_x(deg2rad(-relative.y * mouse_sensitivity))
	cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -85, 85)


func _physics_process(delta):
	var direction = Vector3.ZERO

	if fly_mode:
		# Full 3D camera-relative movement
		var cam_basis = cam.global_transform.basis
		if Input.is_action_pressed("ui_up") or move_forward:
			direction -= cam_basis.z
		if Input.is_action_pressed("ui_down") or move_backward:
			direction += cam_basis.z
		if Input.is_action_pressed("ui_left"):
			direction -= cam_basis.x
		if Input.is_action_pressed("ui_right"):
			direction += cam_basis.x

		direction = direction.normalized()
		velocity = direction * fly_speed

		# Optional vertical adjustment (E/Q)
		if Input.is_key_pressed(KEY_E):
			velocity.y += fly_speed
		elif Input.is_key_pressed(KEY_Q):
			velocity.y -= fly_speed

		velocity = move_and_slide(velocity, Vector3.UP)
	else:
		# Ground movement (parallel to floor)
		if Input.is_action_pressed("ui_up") or move_forward:
			direction -= transform.basis.z
		if Input.is_action_pressed("ui_down") or move_backward:
			direction += transform.basis.z
		if Input.is_action_pressed("ui_left"):
			direction -= transform.basis.x
		if Input.is_action_pressed("ui_right"):
			direction += transform.basis.x

		direction = direction.normalized()

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		velocity.y += gravity * delta

		if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_strength

		velocity = move_and_slide(velocity, Vector3.UP)


# --- Optional signal callbacks for mobile buttons ---
func _on_forward_pressed():
	pass
func _on_forward_released():
	pass
func _on_reverse_pressed():
	pass
func _on_reverse_released():
	pass
func _on_flytoggle_pressed():
	fly_mode = !fly_mode
