extends Node2D

# Configuracion
@export var proyectil_scene: PackedScene
@export var damage: float = 10.0
@export var fire_rate: float = 1.0
@export var detection_radius: float = 200.0
@export var orbit_radius: float = 80.0
@export var orbit_speed: float = 1.5

@onready var level_up_bd = get_node("/root/LevelUpBD")

# Nodos
@onready var sprite: Sprite2D = $Sprite2D
@onready var area_detection: Area2D = $AreaDetection

# Estado
var jugador: CharacterBody2D
var angulo: float = 0.0
var objetivo_actual: Node2D = null
var fire_timer: Timer
var enemigos_detectados: Array = []

# Variables de mejora
var nivel_actual: int = 1
var velocidad_ataque_mejora: float = 0.0  # Reducción del cooldown (negativo = más rápido)
var velocidad_proyectil_adicional: float = 0.0

func _ready() -> void:
	z_index = 5
	
	jugador = get_tree().get_first_node_in_group("player")
	
	# Configurar area de deteccion
	if not $AreaDetection/CollisionShape2D.shape:
		$AreaDetection/CollisionShape2D.shape = CircleShape2D.new()
	$AreaDetection/CollisionShape2D.shape.radius = detection_radius
	
	# Conectar señales
	area_detection.body_entered.connect(_on_enemy_entered)
	area_detection.body_exited.connect(_on_enemy_exited)
	
	# Timer de disparo
	fire_timer = Timer.new()
	_actualizar_fire_rate()
	fire_timer.timeout.connect(_disparar)
	add_child(fire_timer)
	fire_timer.start()

func _process(delta: float) -> void:
	if not jugador:
		return
	
	# Orbitar alrededor del jugador
	angulo += orbit_speed * delta
	var offset = Vector2(cos(angulo), sin(angulo)) * orbit_radius
	global_position = jugador.global_position + offset
	
	# Buscar objetivo mas cercano
	_actualizar_objetivo()
	
	# Rotar sprite hacia el objetivo
	if objetivo_actual and is_instance_valid(objetivo_actual):
		var dir_to_enemy = (objetivo_actual.global_position - global_position).normalized()
		sprite.rotation = dir_to_enemy.angle()

func _actualizar_objetivo() -> void:
	# Limpiar enemigos invalidos
	enemigos_detectados = enemigos_detectados.filter(func(e): return is_instance_valid(e))
	
	if enemigos_detectados.is_empty():
		objetivo_actual = null
		return
	
	# Encontrar enemigo mas cercano
	var enemigo_cercano = null
	var distancia_minima = INF
	
	for enemigo in enemigos_detectados:
		var distancia = global_position.distance_to(enemigo.global_position)
		if distancia < distancia_minima:
			distancia_minima = distancia
			enemigo_cercano = enemigo
	
	objetivo_actual = enemigo_cercano

func _on_enemy_entered(body: Node2D) -> void:
	if body.is_in_group("enemigo") and not enemigos_detectados.has(body):
		enemigos_detectados.append(body)

func _on_enemy_exited(body: Node2D) -> void:
	if enemigos_detectados.has(body):
		enemigos_detectados.erase(body)

func _disparar() -> void:
	if not objetivo_actual or not is_instance_valid(objetivo_actual):
		return
	
	if not proyectil_scene:
		return
	
	var proyectil = proyectil_scene.instantiate()
	get_tree().current_scene.add_child(proyectil)
	
	var direccion = (objetivo_actual.global_position - global_position).normalized()
	
	# Aplicar velocidad adicional del proyectil
	proyectil.setup({
		"posicion": global_position,
		"direccion": direccion,
		"daño": damage,
		"velocidad_adicional": velocidad_proyectil_adicional,  # NUEVO
		"creador": self
	})

func level_up() -> void:
	nivel_actual += 1
	
	var upgrades = level_up_bd.get_upgrades("dron", nivel_actual)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("velocidad_ataque"):
		velocidad_ataque_mejora += upgrades["velocidad_ataque"]
		_actualizar_fire_rate()
		print("Dron nivel ", nivel_actual, " | Velocidad ataque ", upgrades["velocidad_ataque"], "s")
	
	if upgrades.has("velocidad_proyectil"):
		velocidad_proyectil_adicional += upgrades["velocidad_proyectil"]
		print("Dron nivel ", nivel_actual, " | Velocidad proyectil +", upgrades["velocidad_proyectil"])

func _actualizar_fire_rate() -> void:
	var fire_rate_total = max(0.1, fire_rate + velocidad_ataque_mejora)  # Mínimo 0.1s
	fire_timer.wait_time = fire_rate_total
