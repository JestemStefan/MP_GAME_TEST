extends CharacterBody3D


const SPEED = 200.0


func _ready():
	self.velocity = -self.transform.basis.z * SPEED

func _physics_process(delta):
	var collision = move_and_collide(self.velocity * delta)
	
	if collision:
		print("BOOM")
		self.call_deferred("queue_free")
		


func _on_timer_timeout():
	self.call_deferred("queue_free")
