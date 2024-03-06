class_name PlayerController
extends CharacterBody3D

@export_group("Movement")
@export var max_speed : float = 4.0
@export var acceleration : float = 20.0
@export var braking : float = 20.0
@export var gravity_modifier : float = 1.5
@export var max_run_speed: float = 6.0

@export_group("Camera")
@export var look_sensitivity : float = 0.005
var camera_look_input : Vector2

@onready var camera : Camera3D = get_node("Camera3D")
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var move_input = Input.get_vector("move_l", "move_r", "move_f", "move_b")
	var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	
	var target_speed = max_speed
	var current_smoothing = acceleration
	
	if not move_dir:
		current_smoothing = braking
		
	var target_velocity = move_dir * target_speed
	
	velocity.x = lerp(velocity.x, target_velocity.x, current_smoothing * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, current_smoothing * delta)
	
	move_and_slide()
	
	rotate_y(-camera_look_input.x * look_sensitivity)
	camera.rotate_x(-camera_look_input.y * look_sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	camera_look_input = Vector2.ZERO
	
	if Input.is_action_pressed("exit"):
		get_tree().quit()
		
func _unhandled_event(event):
	if event is InputEventMouseMotion:
		camera_look_input = event.relative
