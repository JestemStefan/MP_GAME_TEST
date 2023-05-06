extends CharacterBody3D


const SPEED = 20.0

var screen_center: Vector2 = Vector2.ZERO

var mouse_steering: Vector2 = Vector2.ZERO

@onready var bullet_scene = preload("res://scenes/bullet/bullet.tscn")


func _enter_tree():
	set_multiplayer_authority(str(self.name).to_int())

func _ready():
	if not is_multiplayer_authority():
		return
		
	screen_center = get_viewport().size/2
	
	$Camera3D.current = true
	
func _input(event):
	if not is_multiplayer_authority():
		return
		
	if event is InputEventMouseMotion:
		mouse_steering = (screen_center - event.position).limit_length(200)/200
	
	elif event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == 1:
			self._shoot_weapon.rpc()
			
		


func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	var new_direction: Vector3 = Vector3.ZERO
	
	var input_dir = Input.get_vector("MOVE_LEFT", "MOVE_RIGHT",  "MOVE_BACKWARD", "MOVE_FORWARD")
	var roll = Input.get_axis("ROLL_LEFT", "ROLL_RIGHT")
	
	transform.basis = transform.basis.rotated(self.transform.basis.x, mouse_steering.y * 2 * delta)
	transform.basis = transform.basis.rotated(self.transform.basis.y, mouse_steering.x * 2 * delta)
	transform.basis = transform.basis.rotated(self.transform.basis.z, -roll * 1 * delta)
	
	new_direction += -transform.basis.z * 50 * input_dir.y
	new_direction += transform.basis.x * input_dir.x * 50
	
	velocity =  lerp(velocity, new_direction, 0.01)
	
	self._spawn_particles(input_dir.y > 0)
	
	move_and_slide()

func _spawn_particles(on_off):
	$GPUParticles3D.set_emitting(on_off)

@rpc("call_local")
func _shoot_weapon():
	var new_bullet = bullet_scene.instantiate()
	new_bullet.position = self.position - self.transform.basis.z * 5
	new_bullet.transform.basis = self.transform.basis
	get_tree().current_scene.add_child(new_bullet, true)
