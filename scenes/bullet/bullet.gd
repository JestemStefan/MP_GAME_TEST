extends CharacterBody3D

var target = null
const SPEED = 100.0


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
		self.call_deferred("queue_free")

func _on_timer_timeout():
	self.call_deferred("queue_free")
