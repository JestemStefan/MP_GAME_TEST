extends CharacterBody3D
class_name Player

var peer_id: int

const SPEED = 20.0

var screen_center: Vector2 = Vector2.ZERO
var mouse_steering: Vector2 = Vector2.ZERO

var current_target = null

@onready var bullet_scene = preload("res://scenes/bullet/bullet.tscn")

@onready var chat_entry = $Control/LineEdit
@onready var chat_display =  $Chat


func _enter_tree():
	self.peer_id = self.name.to_int()
	set_multiplayer_authority(self.peer_id)
	
	

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
			self._shoot_weapon.rpc(current_target)

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_just_released("ui_accept"):
		self._handle_chat()
	
	if Input.is_action_just_released("ui_focus_next"):
		self._lock_and_load()
	
	var new_direction: Vector3 = Vector3.ZERO
	
	var input_dir = Input.get_vector("MOVE_LEFT", "MOVE_RIGHT",  "MOVE_BACKWARD", "MOVE_FORWARD")
	var roll = Input.get_axis("ROLL_LEFT", "ROLL_RIGHT")
	
	transform.basis = transform.basis.rotated(self.transform.basis.x, mouse_steering.y * 2 * delta)
	transform.basis = transform.basis.rotated(self.transform.basis.y, mouse_steering.x * 2 * delta)
	transform.basis = transform.basis.rotated(self.transform.basis.z, -roll * 1 * delta)
	self.transform.basis = self.transform.basis.orthonormalized()
	
	new_direction += -transform.basis.z * 50 * input_dir.y
	new_direction += transform.basis.x * input_dir.x * 50
	
	velocity =  lerp(velocity, new_direction, 0.01)
	
	self._spawn_particles.rpc(input_dir.y > 0)
	
	self.move_and_slide()

func _lock_and_load():
	self.set_current_target.rpc()
	

@rpc("call_local")
func set_current_target():
#	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
#		var players = get_tree().get_nodes_in_group("players")
#		print("Local state: " + str(players))
#
#
#	else:
#		var players = get_tree().get_nodes_in_group("players")
#		print("Remote state: " + str(players)) 
	
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		if player != self:
			current_target = player
			break
			
	
@rpc("call_local")
func _spawn_particles(on_off):
	$GPUParticles3D.set_emitting(on_off)


@rpc("call_local")
func _shoot_weapon(target):
	var new_bullet = bullet_scene.instantiate()
	new_bullet.position = self.position - self.transform.basis.z * 5
	new_bullet.transform.basis = self.transform.basis
	
	new_bullet.target = current_target
	
	get_tree().current_scene.add_child(new_bullet)


func _handle_chat():
	if chat_entry.is_visible():
		self.update_text.rpc(chat_entry.text)
		chat_entry.hide()
	else:
		chat_entry.text = ""
		chat_entry.show()
		chat_entry.grab_focus()


@rpc("call_local")
func update_text(new_text):
	chat_display.text = new_text
	

