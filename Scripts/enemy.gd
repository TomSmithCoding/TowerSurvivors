extends CharacterBody3D

var rng = RandomNumberGenerator.new()
var can_shoot = true
var can_hit = true
var ranged = true
var enemy_dir := "res://Resources/EnemyResources"
var dir := DirAccess.open(enemy_dir)
var enemy_types = dir.get_files()
var enemy

enum AttackType {MELEE, RANGED, MAGIC, SIEGE}

@onready var player = get_tree().current_scene.get_node("Player/PlayerCharacterBody")
@onready var marker = get_node("Marker3D")
@onready var ray_cast = get_node("RayCast3D")
@onready var healthbar = $"../SubViewport/EnemyHealth"
@onready var enemyhealthlabel = $"../SubViewport/EnemyHealth/EnemyHealthValue"
@onready var enemymesh = $"MeshInstance3D"
@onready var meleeAttackCD = $"AttackCooldown"
@onready var rangedAttackCD = $"RangedAttackCooldown"

@export var projectile:PackedScene			#Projectile for attack
@export var speed = 1						#Movement speed
@export var fire_speed = 0					#Projectile speed
@export var attack_cd = 1					#Time between attacks
@export var attack_damage = 5				#Damage of attacks
@export var attack_type = AttackType.RANGED	#Attack type enum
@export var enemymaxhealth = 100			#Maximum health
@export var enemycurrenthealth = 100		#Current health

func _enter_tree() -> void:
	if enemy_types:
		var random_enemy = enemy_types[randi() % enemy_types.size()]
		#print(random_enemy)
		enemy = load(str("res://Resources/EnemyResources/", random_enemy))
		set_class_preload(enemy)

func _ready() -> void:
	set_class_postload(enemy)
		 
	enemycurrenthealth = enemymaxhealth
	healthbar.value = enemymaxhealth
	
	if(enemycurrenthealth > enemymaxhealth):
		enemycurrenthealth = enemymaxhealth

func _process(_delta:float) -> void:
	#damage(10)
	pass

func _physics_process(_delta:float) -> void:
	# Look and move towards player
	look_at(player.global_position)
	self.rotate_object_local(Vector3.UP, PI)
	var target_position: Vector3 = Vector3(0,0,0)
	var direction = global_position.direction_to(target_position)
	velocity = direction * speed
	
	# If ranged attack type and in range to attack, attack.
	if ranged:
		range_checks()
	move_and_slide()
	
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		
		if attack_type == AttackType.MELEE:
			if(body.name == player.name) && can_hit:
				velocity = Vector3.ZERO
				can_hit = false
				meleeAttackCD.start()
				attack(attack_damage, body)

func set_class_preload(type):
	attack_type = type.attack_type#AttackType.MELEE #AttackType.RANGED #AttackType.MAGIC #AttackType.SIEGE
	speed = type.speed
	fire_speed = type.fire_speed
	attack_damage = type.attack_damage
	enemymaxhealth = type.enemymaxhealth

func set_class_postload(type):
	enemymesh.mesh.material.albedo_color = type.enemy_colour
	enemycurrenthealth = type.enemycurrenthealth
	if attack_type == AttackType.MELEE:
		ray_cast.enabled = false
		meleeAttackCD.wait_time = type.attack_cd
		ranged = false
	else:
		rangedAttackCD.wait_time = type.attack_cd

func _aim():
	ray_cast.target_position = player.position

func fire():
	var new_projectile = projectile.instantiate()
	new_projectile.global_transform = $Marker3D.global_transform
	
	#new_projectile.fire_speed = fire_speed
	#new_projectile.attack_damage = attack_damage
	#new_projectile.projectile_color = enemy.projectile_color
	new_projectile.enemy_resource = enemy
	var scene_root = get_tree().get_root().get_children()[0]
	scene_root.add_child(new_projectile)

func attack(damageval:int, playerparam):
	playerparam.damage(damageval)

func damage(value: int) -> void:
	if enemycurrenthealth > 0:
		enemycurrenthealth -= value
		healthbar.value -= value
	if enemycurrenthealth <= 0:
		queue_free()

func range_checks():
	var in_range = false
	if ray_cast.is_colliding():
		velocity = Vector3.ZERO
		in_range = true
	if in_range and can_shoot:#
		can_shoot = false
		rangedAttackCD.start()
		fire()

func _on_ranged_attack_cooldown_timeout() -> void:
	can_shoot = true

func _on_attack_cooldown_timeout() -> void:
	can_hit = true
