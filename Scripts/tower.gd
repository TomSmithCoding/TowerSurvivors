extends Node3D

#Needs range, fire rate, damage, damage type, fire type, projectile
enum DamageType {NORMAL, MAGIC, SIEGE, PIERCE}
var Ranges = {
	"CLOSEST": 100, 
	"CLOSE": 300, 
	"FAR": 500, 
	"FURTHEST": 700
}

var tower_dir := "res://Resources/TowerResources"
var dir := DirAccess.open(tower_dir)
var tower_types = dir.get_files()
var tower

@onready var ray_cast = get_node("RayCast")
@onready var rangeArea = $"Area3D"
@onready var ranges
@onready var target = []
@onready var can_shoot = true
@onready var AttackCD = $"AttackCooldown"
@onready var current_target
@onready var target_id = 0

@export var tower_resource	:	Resource
@export var projectile		:	PackedScene			#Projectile for attack
@export var fire_speed 		:	int					#Projectile speed
@export var attack_cd 		:	float					#Time between attacks
@export var attack_damage 	:	int				#Damage of attacks
@export var damage_type 	: 	DamageType	#Attack type enum
@export var tower_range	 	:	int


func _enter_tree() -> void:
	#tower_resource = load("res://Resources/TowerResources/Bow.tres")	#get the resource for the tower the player has clicked
	if tower_types:
		var random_tower = tower_types[randi() % tower_types.size()]
		tower_resource = load(str("res://Resources/TowerResources/", random_tower))
	
	if tower_resource:
		#assign all those values, similar to what i do in preload
		fire_speed = tower_resource.fire_speed			#Projectile speed
		attack_cd = tower_resource.attack_cd			#Time between attacks
		attack_damage = tower_resource.attack_damage	#Damage of attacks
		damage_type = tower_resource.damage_type		#Attack type enum
		tower_range = Ranges[tower_resource.Ranges.find_key(tower_resource.tower_range)] #Tower range enum, gets the enum from the towerresource script and uses the Ranges dict to determine rnage.
	
func _ready() -> void:
	#Assign tower resource based on what is clicked on from the shop icon, so if click bow, on ready of this tower being created, assign the Bow resource, and then all the Bow resource values
	#Temporary random tower range generator
	#towerrange = Ranges[Ranges.keys().pick_random()]
	#Look in the range colliders available, find the right collider and enable it based on the tower.
	ranges = rangeArea.get_children()
	for rangecolliders in ranges:
		if rangecolliders.name.contains(str(tower_range)):
			rangecolliders.disabled = false
	AttackCD.wait_time = attack_cd

func _physics_process(_delta: float) -> void:
	#If have a target, aim at it. Kill until dead?
	if target:
		if current_target && is_instance_valid(current_target):
			aim(current_target)
			if can_shoot:
				fire(current_target)
		else:
			current_target = target.pick_random()

func _process(_delta: float) -> void:
	pass

func aim(enemy):
	ray_cast.set_target_position(enemy.global_position)
	
func fire(enemy):
	can_shoot = false
	AttackCD.start()
	var new_projectile = projectile.instantiate()
	new_projectile.forward_direction = enemy.global_position
	new_projectile.tower_resource = tower_resource
	var scene_root = get_tree().get_root().get_children()[0]
	scene_root.add_child(new_projectile)

func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
# If no target, aim at enemy that entered. How to handle targeting enemies already in? Add them to an array and then cycle through the array? Randomly choose after an enemy dies?
	target.append(body)
	#print("ENEMY SPOTTED")

func _on_attack_timer_timeout() -> void:
	can_shoot = true
