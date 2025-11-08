extends Node2D

# Configuración
@export var damage: float = 50.0
@export var radio_explosion: float = 80.0
@export var tiempo_activacion: float = 1.0
@export var tiempo_vida: float = 30.0

# Nodos
@onready var mina_sprite: AnimatedSprite2D = $Mina
@onready var explosion_sprite: AnimatedSprite2D = $Explosion
@onready var area_deteccion: Area2D = $R_Deteccion
@onready var area_explosion: Area2D = $R_Explosion
@onready var timer_activacion: Timer = $LaunchTimer
@onready var timer_vida: Timer = $TiempoVida

# Estado
var activa: bool = false

func _ready() -> void:
	add_to_group("minas")
	z_index = 5
	
	# Configurar collision shapes
	$R_Deteccion/CollisionR_Deteccion.shape = CircleShape2D.new()
	$R_Deteccion/CollisionR_Deteccion.shape.radius = 20.0
	
	$R_Explosion/CollisionR_Explosion.shape = CircleShape2D.new()
	$R_Explosion/CollisionR_Explosion.shape.radius = radio_explosion
	
	# Configurar timers
	timer_activacion.wait_time = tiempo_activacion
	timer_activacion.timeout.connect(_activar)
	timer_activacion.start()
	
	timer_vida.wait_time = tiempo_vida
	timer_vida.timeout.connect(_expirar)
	timer_vida.start()
	
	# Configurar áreas
	area_deteccion.monitoring = false
	area_deteccion.body_entered.connect(_on_pisada)
	area_explosion.monitoring = false
	area_explosion.body_entered.connect(_on_explosion_toca)
	
	# Ocultar explosión
	explosion_sprite.visible = false
	
	# Reproducir animación de mina
	if mina_sprite.sprite_frames.has_animation("default"):
		mina_sprite.play("default")

func _activar() -> void:
	activa = true
	mina_sprite.modulate = Color.GREEN
	area_deteccion.monitoring = true

func _on_pisada(body: Node2D) -> void:
	if activa and body.is_in_group("enemigo"):
		_explotar()

func _explotar() -> void:
	activa = false
	mina_sprite.visible = false
	explosion_sprite.visible = true
	
	if explosion_sprite.sprite_frames.has_animation("default"):
		explosion_sprite.play("default")
	
	explosion_sprite.scale = Vector2.ONE * (radio_explosion / 40.0)
	area_explosion.monitoring = true
	
	# Esperar 1 frame para que el área detecte los cuerpos
	await get_tree().process_frame
	
	# Hacer daño a todos los enemigos en el área
	for body in area_explosion.get_overlapping_bodies():
		if body.is_in_group("enemigo") and body.has_method("take_damage"):
			body.take_damage(damage)
	
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_explosion_toca(body: Node2D) -> void:
	if body.is_in_group("enemigo") and body.has_method("take_damage"):
		body.take_damage(damage)

func _expirar() -> void:
	var tween = create_tween()
	tween.tween_property(mina_sprite, "modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()
