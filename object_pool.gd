class_name ObjectPool
extends Node

@export var scene: PackedScene
@export var pool_size: int

var available_objects: Array[Node2D] = []
var all_objects: Array[Node2D] = []

func _ready() -> void:
	if not scene:
		push_error("ObjectPool: No PackedScene assigned.")
		return
		
	for i in range(pool_size):
		var obj = scene.instantiate() as Node2D
		all_objects.append(obj)
		add_child(obj)
		_deactivate_object(obj)
		available_objects.append(obj)

func get_from_pool() -> Node2D:
	if available_objects.is_empty():
		push_warning("ObjectPool: Pool exhausted.")
		return null
		
	var obj = available_objects.pop_back()
	_activate_object(obj)
	return obj

func return_to_pool(obj: Node2D) -> void:
	if available_objects.has(obj):
		return # Prevent returning the same object twice
		
	_deactivate_object(obj)
	available_objects.append(obj)

func return_on_signal(signal_name: StringName) -> void:
	for obj in all_objects:
		if obj.has_signal(signal_name):
			var callable = return_to_pool.bind(obj)
			if not obj.is_connected(signal_name, callable):
				obj.connect(signal_name, callable)

func _deactivate_object(obj: Node2D) -> void:
	pass
	#obj.hide()
	#obj.process_mode = Node.PROCESS_MODE_DISABLED
	#obj.set_process(false)
	#obj.set_physics_process(false)
	#_toggle_collisions_recursive(obj, true)

func _activate_object(obj: Node2D) -> void:
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	obj.show()
	obj.set_process(true)
	obj.set_physics_process(true)
	_toggle_collisions_recursive(obj, false)

func _toggle_collisions_recursive(node: Node, disable: bool) -> void:
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", disable)
	for child in node.get_children():
		_toggle_collisions_recursive(child, disable)

#class_name ObjectPool
#extends Node
#
#@export var scene: PackedScene
#@export var pool_size: int
#
#var objects: Array[Node2D]
#var available: int
#
#func _ready() -> void:
	#objects.resize(pool_size)
	#
	#for i in range(pool_size):
		#objects[i] = scene.instantiate()
		#objects[i].set_process(false)
		#objects[i].set_physics_process(false)
		#for child in objects[i].get_children():
			#if child is CollisionShape2D or child is CollisionPolygon2D:
				#child.set_deferred("disabled", true)
		#objects[i].hide()
		#objects[i].set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		#add_child(objects[i])
#
	#available = pool_size
#
#func get_from_pool() -> Node2D:
	#if available == 0:
		#return null
		#
	#var obj = objects[0]
	#objects[0] = objects[available-1]
	#objects[available-1] = null
	#available -= 1
	#
	#obj.set_process(true)
	#obj.set_physics_process(true)
	#for child in obj.get_children():
		#if child is CollisionShape2D or child is CollisionPolygon2D:
			#child.set_deferred("disabled", false)
	#obj.show()
	#obj.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	#
	#return obj
	#
#func return_to_pool(obj: Node2D) -> void:
	#if available >= pool_size:
		#return
	#objects[available] = obj
	#obj.set_process(false)
	#obj.set_physics_process(false)
	#for child in obj.get_children():
		#if child is CollisionShape2D or child is CollisionPolygon2D:
			#child.set_deferred("disabled", true)
	#obj.hide()
	#obj.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	#available += 1
#
#func return_on_signal(signal_name: StringName) -> void:
	#for i in range(pool_size):
		#objects[i].connect(signal_name, return_to_pool.bind(objects[i]))
