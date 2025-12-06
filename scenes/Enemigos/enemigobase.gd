extends CharacterBody2D
class_name EnemigoBase

@export var velocidad_base: float = 100.0
@export var vida_base: int = 30
@export var daño_base: float = 10.0
@export var cooldown_ataque: float = 1.0

var velocidad: float
var vida_max: int
var vida_actual: int
var daño: float
var objetivo: Node2D = null
var puede_atacar: bool = true
var jugador_en_rango: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer_ataque: Timer = Timer.new()

# Detector opcional (si existe en la escena)
@onready var detector: Area2D = get_node_or_null("Detector")
@onready var hitbox: Area2D = get_node_or_null("Hitbox")

func _ready():
	_escalar_stats()
	
	vida_actual = vida_max
	anim_sprite.play("default")
	add_to_group("enemigo")
	
	# Configurar NavigationAgent
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 5.0
	
	# Timer de ataque
	timer_ataque.one_shot = true
	timer_ataque.timeout.connect(_on_ataque_cooldown)
	add_child(timer_ataque)
	
	# Conectar Detector si existe
	if detector:
		detector.body_entered.connect(_on_detector_body_entered)
		detector.body_exited.connect(_on_detector_body_exited)
	
	# Conectar Hitbox si existe
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)
	
	# Conectar animación
	anim_sprite.animation_finished.connect(_on_animation_finished)
	
	# Buscar jugador
	await get_tree().create_timer(0.1).timeout
	objetivo = get_tree().get_first_node_in_group("player")
	
	if objetivo:
		nav_agent.set_navigation_map(get_world_2d().navigation_map)
		nav_agent.target_position = objetivo.global_position

func _escalar_stats() -> void:
	var nivel_jugador = GameState.level if GameState else 1
	var multiplicador = 1.0 + (nivel_jugador - 1) * 0.1
	
	velocidad = velocidad_base * multiplicador
	vida_max = int(vida_base * multiplicador)
	daño = daño_base * multiplicador
	
	if nav_agent:
		nav_agent.max_speed = velocidad

func _physics_process(delta):
	if not objetivo or not is_instance_valid(objetivo):
		return
	
	if jugador_en_rango:
		# Detenerse y atacar
		velocity = Vector2.ZERO
		_intentar_atacar()
	else:
		# Perseguir
		_perseguir()
	
	move_and_slide()

func _perseguir() -> void:
	nav_agent.target_position = objetivo.global_position
	
	if not nav_agent.is_navigation_finished():
		var siguiente_punto = nav_agent.get_next_path_position()
		var direccion = (siguiente_punto - global_position).normalized()
		velocity = direccion * velocidad

func _intentar_atacar() -> void:
	if not puede_atacar:
		return
	
	puede_atacar = false
	
	# Hacer daño
	if objetivo and objetivo.has_method("take_damage"):
		objetivo.take_damage(daño)
	
	# Animación de ataque (si existe)
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("atacar"):
		anim_sprite.play("atacar")
	else:
		anim_sprite.play("default")
	
	# Cooldown
	timer_ataque.start(cooldown_ataque)

func _on_ataque_cooldown() -> void:
	puede_atacar = true

func _on_detector_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_en_rango = true

func _on_detector_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		jugador_en_rango = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("get_daño"):
		take_damage(area.get_daño())

func _on_animation_finished() -> void:
	if anim_sprite.animation == "atacar" or anim_sprite.animation == "recibir":
		anim_sprite.play("default")

func take_damage(cantidad: float) -> void:
	vida_actual -= cantidad
	
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("recibir"):
		anim_sprite.play("recibir")
	
	if vida_actual <= 0:
		morir()

func morir():
	set_physics_process(false)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("morir"):
		anim_sprite.play("morir")
		await anim_sprite.animation_finished
	
	queue_free()
