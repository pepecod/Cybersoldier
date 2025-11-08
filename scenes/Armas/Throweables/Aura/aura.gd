extends Node2D

# Configuracion
@export var damage_amount: float = 5.0
@export var radius: float = 100.0
@export var damage_interval: float = 0.5
@export var pulse_speed: float = 2.0
@export var pulse_count: int = 3

# Nodos
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area2d: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/AreaEfecto
@onready var level_up_bd = get_node("/root/LevelUpBD")

# Estado
var jugador: CharacterBody2D
var time_passed: float = 0.0
var damage_timer: Timer
var enemies_in_area: Array = []

# Variables de mejora
var nivel: int = 1
var daño_adicional: float = 0.0
var area_adicional: float = 0.0
var tick_mejora: float = 0.0  # Reducción del intervalo (negativo = más rápido)

func _ready() -> void:
	print("aura ready iniciado")
	
	z_index = 10
	
	# Buscar jugador
	jugador = get_tree().get_first_node_in_group("player")
	print("jugador encontrado: ", jugador != null)
	
	# Configurar collision shape
	if not collision_shape:
		push_error("no se encontro collision shape")
		return
	
	if not collision_shape.shape:
		collision_shape.shape = CircleShape2D.new()
	
	_actualizar_radius()
	
	# Conectar señales
	area2d.body_entered.connect(_on_body_entered)
	area2d.body_exited.connect(_on_body_exited)
	
	# Timer para daño periódico
	damage_timer = Timer.new()
	_actualizar_tick()
	damage_timer.timeout.connect(_apply_damage)
	add_child(damage_timer)
	damage_timer.start()
	
	# Reproducir animación del escudo
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("default"):
		sprite.play("default")
		print("aura sprite animado")
	
	print("aura activa")

func _process(delta: float) -> void:
	time_passed += delta
	
	# Seguir al jugador
	if jugador:
		global_position = jugador.global_position
	
	queue_redraw()

func _draw() -> void:
	var radio_actual = radius + area_adicional
	
	# Circulo borde azul (limite del area)
	draw_arc(Vector2.ZERO, radio_actual, 0, TAU, 64, Color(0, 0.5, 1.0, 0.8), 2.0)
	
	# Ondas de pulso (desde el centro hacia afuera)
	for i in range(pulse_count):
		var offset = float(i) / float(pulse_count)
		var wave_progress = fmod(time_passed * pulse_speed + offset, 1.0) #fmod es el resto de una division con floats
		var current_radius = wave_progress * radio_actual
		var alpha = 1.0 - wave_progress
		
		var wave_color = Color(0, 0.7, 1.0, alpha * 0.4)
		draw_circle(Vector2.ZERO, current_radius, wave_color)
		
		if current_radius > 5:
			draw_arc(Vector2.ZERO, current_radius, 0, TAU, 32, Color(0, 0.8, 1.0, alpha * 0.8), 1.5)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigo") and not enemies_in_area.has(body):
		enemies_in_area.append(body)
		print("enemigo entro en aura: ", body.name)

func _on_body_exited(body: Node2D) -> void:
	if enemies_in_area.has(body):
		enemies_in_area.erase(body)
		print("enemigo salio del aura: ", body.name)

func _apply_damage() -> void:
	enemies_in_area = enemies_in_area.filter(func(e): return is_instance_valid(e))
	
	if enemies_in_area.size() > 0:
		print("aplicando dano a ", enemies_in_area.size(), " enemigos")
	
	var daño_total = damage_amount + daño_adicional
	
	for enemy in enemies_in_area:
		if enemy.has_method("take_damage"):
			enemy.take_damage(daño_total)
			print("aura dano a: ", enemy.name, " (", daño_total, ")")
		else:
			print("enemigo sin metodo take_damage: ", enemy.name)

func level_up() -> void:
	nivel += 1
	
	var upgrades = level_up_bd.get_upgrades("aura", nivel)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("daño"):
		daño_adicional += upgrades["daño"]
		print("✅ Aura nivel ", nivel, " | Daño +", upgrades["daño"])
	
	if upgrades.has("tick"):
		tick_mejora += upgrades["tick"]
		_actualizar_tick()
		print("✅ Aura nivel ", nivel, " | Tick ", upgrades["tick"], "s (más rápido)")
	
	if upgrades.has("area"):
		area_adicional += upgrades["area"]
		_actualizar_radius()
		print("✅ Aura nivel ", nivel, " | Área +", upgrades["area"], " píxeles")

func _actualizar_radius() -> void:
	var radio_total = radius + area_adicional
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radio_total

func _actualizar_tick() -> void:
	var intervalo_total = max(0.1, damage_interval + tick_mejora)  # Mínimo 0.1s
	damage_timer.wait_time = intervalo_total
