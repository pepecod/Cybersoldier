extends "res://scenes/Enemigos/enemigobase.gd"
class_name Volador

@export var daño_ataque: float = 10.0
@export var xp: float = 10.0
@export var tiempo_entre_ataques: float = 1.0

@onready var detector: Area2D = $Detector
@onready var hitbox: Area2D = $Hitbox

var puede_atacar := true
var jugador_en_rango := false

func _ready():
	super._ready()

	if detector == null or hitbox == null:
		push_error("Detector o Hitbox no encontrados.")
		return

	detector.body_entered.connect(_on_detector_body_entered)
	detector.body_exited.connect(_on_detector_body_exited)
	hitbox.area_entered.connect(_on_hitbox_area_entered)

	anim_sprite.play("volar")

func _physics_process(delta):
	if objetivo and not jugador_en_rango:
		# Movimiento hacia el jugador
		nav_agent.target_position = objetivo.global_position

		if not nav_agent.is_navigation_finished():
			var siguiente = nav_agent.get_next_path_position()
			var dir = (siguiente - global_position).normalized()
			velocity = dir * velocidad
			move_and_slide()

		# Flip horizontal según dirección del jugador
		anim_sprite.flip_h = objetivo.global_position.x < global_position.x
	else:
		velocity = Vector2.ZERO
		move_and_slide()

	# Ataca si puede
	if puede_atacar and jugador_en_rango:
		atacar()

func atacar():
	puede_atacar = false
	anim_sprite.play("atacar")

	if objetivo and objetivo.has_method("take_damage"):
		objetivo.take_damage(daño_ataque)

	await get_tree().create_timer(tiempo_entre_ataques).timeout
	puede_atacar = true

	# Volver a animación de vuelo si sigue en combate
	if jugador_en_rango:
		anim_sprite.play("volar")

func take_damage(cantidad: float) -> void:
	anim_sprite.play("recibir")
	velocity = Vector2.ZERO
	await anim_sprite.animation_finished

	super.take_damage(cantidad)

	if vida_actual > 0:
		anim_sprite.play("volar")

func morir():
	# Detener movimiento y pathfinding
	GameState.add_xp(xp)
	velocity = Vector2.ZERO
	nav_agent.set_velocity(Vector2.ZERO)
	nav_agent.target_position = global_position  # Detener navegación
	set_physics_process(false)  # Opcional: detener física

	anim_sprite.play("morir")

	await anim_sprite.animation_finished
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("get_daño"):
		var daño = area.get_daño()
		take_damage(daño)
		area.queue_free()

func _on_detector_body_entered(body: Node) -> void:
	if body.is_in_group("jugador"):
		jugador_en_rango = true

func _on_detector_body_exited(body: Node) -> void:
	if body.is_in_group("jugador"):
		jugador_en_rango = false
