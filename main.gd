extends Node

@onready var lava: Area2D = $Lava
@onready var player: CharacterBody2D = $Player
#@onready var enemies: ObjectPool = $Enemies
@export var enemy_scene: PackedScene

@export var enemy_spawn_1: Vector2
@export var enemy_spawn_2: Vector2

var spawn_1_time: float = 0
var spawn_2_time: float = 0
var spawn_delay: float = 2

var score: int = 0
var lives: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lava.connect("lava_hit", on_lava_hit)
	#enemies.return_on_signal("off_screen_limits")
	player.connect("defeated", on_player_defeated)
	player.connect("enemy_defeated", on_enemy_defeated)
	
func on_enemy_off_screen(enemy: Node) -> void:
	enemy.queue_free()

func on_lava_hit() -> void:
	lives -= 1
	if lives == 0:
		call_deferred("game_over")
		return
	player.call_deferred("respawn")
	
func on_player_defeated(enemy: Node) -> void:
	lives -= 1
	if lives == 0:
		call_deferred("game_over")
		return
	player.call_deferred("respawn")
	call_deferred("update_enemy", enemy)
	
func game_over() -> void:
	get_tree().change_scene_to_file("res://game_over_screen.tscn")
	
func update_enemy(enemy: Node) -> void:
	# Enemy was moving with player after
	# player's respawn function changed its position
	# Maybe was something with the collisions
	# so creating a new enemy and replacing it with
	# the enemy solved the problem
	var new_enemy = enemy_scene.instantiate()
	add_child(new_enemy)
	new_enemy.sense = enemy.sense
	new_enemy.position = enemy.position
	enemy.queue_free()	
			
func on_enemy_defeated(enemy: Node) -> void:
	#enemies.return_to_pool(enemy)
	enemy.queue_free()
	score += 1
	if score == 10:
		get_tree().change_scene_to_file("res://win_screen.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var vsize = get_viewport().get_visible_rect().size
	
	spawn_1_time += delta
	if spawn_1_time > spawn_delay:
		spawn_1_time = 0
		#var enemy = enemies.get_from_pool()
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		if enemy:
			enemy.position = enemy_spawn_1
			if enemy.position.x > vsize.x / 2:
				enemy.sense = enemy.Sense.left
			else: 
				enemy.sense = enemy.Sense.right
		
	spawn_2_time += delta
	if spawn_2_time > spawn_delay:
		spawn_2_time = 0
		#var enemy = enemies.get_from_pool()
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		if enemy:
			enemy.position = enemy_spawn_2
			if enemy.position.x < vsize.x / 2:
				enemy.sense = enemy.Sense.right
			else:
				enemy.sense = enemy.Sense.left
