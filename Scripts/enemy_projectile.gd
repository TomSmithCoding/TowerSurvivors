extends CharacterBody3D

@onready var player = get_tree().current_scene.get_node("Player/PlayerCharacterBody")
@onready var enemy_resource : Resource
@onready var projectilemesh = $"MeshInstance3D"

@export var fire_speed = 0
@export var attack_damage = 0
@export var projectile_color: Color

const KILL_TIME = 2
var timer = 0

func _ready() -> void:
	fire_speed = enemy_resource.fire_speed
	attack_damage = enemy_resource.attack_damage
	projectilemesh.mesh.material.albedo_color = enemy_resource.projectile_color

func _physics_process(delta: float) -> void:
	var forward_direction = global_transform.basis.z.normalized()
	var collision = move_and_collide(forward_direction * fire_speed * delta)
	if collision:
		if collision.get_collider().name == player.name:
			player.damage(attack_damage)
			queue_free()
	
	timer += delta
	if timer >= KILL_TIME:
		queue_free()
