extends CharacterBody3D

enum DamageType {NORMAL, MAGIC, SIEGE, PIERCE}

@export var fire_speed = 1
@export var attack_damage = 5
@export var forward_direction = Vector3.ZERO

@onready var towermesh = $"MeshInstance3D"
@onready var tower_resource : Resource

const KILL_TIME = 2
var timer = 0

func _ready() -> void:
	fire_speed = tower_resource.fire_speed			#Projectile speed
	attack_damage = tower_resource.attack_damage	#Damage of attacks
	towermesh.mesh.material.albedo_color = tower_resource.projectile_color

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(forward_direction * fire_speed * delta)
	if collision:
		if collision.get_collider().name == "EnemyCharacterBody":
			var enemy = instance_from_id(collision.get_collider_id())
			enemy.damage(attack_damage)
			queue_free()
	
	timer += delta
	if timer >= KILL_TIME:
		queue_free()
