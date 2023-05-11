extends CharacterBody3D

var target = null
const SPEED = 100.0

@onready var explosion_scene = preload("res://scenes/bullet/rocket_explosion.tscn")

func _ready():
	self.velocity = -self.transform.basis.z * SPEED

func _physics_process(delta):
	self.velocity = -self.transform.basis.z * SPEED
	
	if target:
		var direction = self.target.position - self.position
		self.velocity = direction.normalized() * SPEED
	
	
	self.look_at(self.position + self.velocity)
	
	var collision = move_and_collide(self.velocity * delta)
	
	if collision:
		self._explode()
		

func _on_timer_timeout():
	self._explode()
	

func _explode():
	var explosion: GPUParticles3D = explosion_scene.instantiate()
	explosion.position = self.position
	explosion.emitting = true
	get_tree().current_scene.add_child(explosion)
	self.call_deferred("queue_free")
