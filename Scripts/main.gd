extends Node3D

@export var enemy:PackedScene

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _on_mob_timer_timeout():
	#Comfortable ranges for X and Z in camera
	var X = 12.0
	var Z = 6.0

	#spawn array for along the vertical axis
	var verticalSpawn = random(X, -Z, Z)
	#spawn array for along the horizontal axis
	var horizontalSpawn = random(Z, -X, X)
	var enemy_amount = rng.randi_range(1, 3) #1
	var spawn_on_y:bool = randi() %2 == 0

	#Create enemy within camera range randomly generated, avoiding spawning on player
	if(spawn_on_y):
		for i in enemy_amount:
			inst_enemies(Vector3(verticalSpawn[0],0,verticalSpawn[1]))
			verticalSpawn[0] += (rng.randi_range(0,1)*2-1) * rng.randf_range(0.6, 0.9)
			verticalSpawn[1] += (rng.randi_range(0,1)*2-1) * rng.randf_range(0.6, 0.9)
	else:
		for i in enemy_amount:
			inst_enemies(Vector3(horizontalSpawn[0],0,horizontalSpawn[1]))
			horizontalSpawn[0] += (rng.randi_range(0,1)*2-1) * rng.randf_range(0.6, 0.9)
			horizontalSpawn[1] += (rng.randi_range(0,1)*2-1) * rng.randf_range(0.6, 0.9)

#instantiate function
func inst_enemies(pos):
	var instance = enemy.instantiate()
	instance.position = pos
	add_child(instance)

#random function to determine spawn point for both vert and horiz
func random(val, rangeMin, rangeMax):
	var valLeft = randi() %2 == 0
	if (valLeft == true):
		val *= -1
	var randomVal = rng.randf_range(rangeMin, rangeMax)
	return [val, randomVal]
