# ProyectilChakram.gd
extends Area2D
class_name ProyectilChakram

@export var speed: float = 600.0
@export var daño: int = 10
@export var max_rebotes: int = 3
@export var tiempo_rebote: float = 0.1

var creador: Node = null
var rebotes_realizados: int = 0
var enemigos_golpeados: Array[Node2D] = []
var objetivo_actual: Node2D = null

@onready var nav_agent: NavigationAgent2D = $NavAgent

signal destruido()

func _ready() -> void:
	$CollisionShape2D.disabled = false
	$AnimatedSprite2D.play("vuelo")
	
	nav_agent.target_desired_distance = 0.0
	nav_agent.max_speed = speed
	nav_agent.path_max_distance = 10000

func _physics_process(delta: float) -> void:
	if objetivo_actual:
		nav_agent.target_position = objetivo_actual.global_position
		var siguiente_punto = nav_agent.get_next_path_position()
		var dir = (siguiente_punto - global_position).normalized()
		position += dir * speed * delta
		rotation = dir.angle()
	else:
		position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body: Node) -> void:
	if body == creador or body in enemigos_golpeados:
		return
	if not body.is_in_group("enemigo"):
		return
	
	if body.has_method("take_damage"):
		body.take_damage(daño)
	enemigos_golpeados.append(body)
	rebotes_realizados += 1
	
	# CORREGIDO: Emitir destruido antes de return
	if rebotes_realizados >= max_rebotes:
		destruido.emit()  # ← ✅ AÑADIDO
		return
	
	objetivo_actual = get_siguiente_enemigo()
	if objetivo_actual:
		$CollisionShape2D.disabled = true
		await get_tree().create_timer(tiempo_rebote).timeout
		$CollisionShape2D.disabled = false
	else:
		destruido.emit()

func get_siguiente_enemigo() -> Node2D:
	var mejor: Node2D = null
	var dist_min := INF
	for e in get_tree().get_nodes_in_group("enemigo"):
		if e == creador or e in enemigos_golpeados:
			continue
		var d = global_position.distance_to(e.global_position)
		if d < dist_min:
			dist_min = d
			mejor = e
	return mejor
