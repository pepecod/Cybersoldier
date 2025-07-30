extends CharacterBody2D

# Configuración
@export var velocidad: float = 2000.0
@export var armas_disponibles: Array[PackedScene] = [
	preload("res://scenes/Armas/Holded/Escopeta/escopeta.tscn"),
	preload("res://scenes/Armas/Holded/Chakram/chakram.tscn"),
	preload("res://scenes/Armas/Holded/Sniper/sniper.tscn"),
	# agregar más armas aquí...
]
@export var arma_inicial: int        = 0
@export var retroceso_fuerza: float = 10.0
@export var duracion_retroceso: float = 0.15

# Nodos
@onready var weapon_holder: Node2D         = $WeaponHolder
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shot_effect: GPUParticles2D   = $WeaponHolder/ShotEffect
@onready var audio_player: AudioStreamPlayer2D = $WeaponHolder/AudioStreamPlayer2D

# Variables de estado
var arma_actual: Node = null
var esta_moviendose: bool = false
var escala_original: Vector2 = Vector2.ONE
var weapon_holder_pos_original: Vector2

func _ready() -> void:
	# 1) Determinar qué arma equipar según singleton
	var idx = GameState.selected_weapon_index
	if idx >= 0 and idx < armas_disponibles.size():
		cambiar_arma(idx)
	else:
		# fallback si hay un error en el índice
		cambiar_arma(arma_inicial)

	weapon_holder_pos_original = weapon_holder.position
	escala_original = anim_sprite.scale
	anim_sprite.play("idle")

	# Conectar señal de fin de animación
	anim_sprite.animation_finished.connect(_on_AnimatedSprite2D_animation_finished)

func cambiar_arma(indice_arma: int) -> void:
	# elimina la anterior
	if arma_actual:
		arma_actual.queue_free()
	# instancia la nueva
	arma_actual = armas_disponibles[indice_arma].instantiate()
	weapon_holder.add_child(arma_actual)
	arma_actual.position = Vector2.ZERO

	# conectar señal 'disparado' si la arma la emite
	if arma_actual.has_signal("disparado"):
		arma_actual.connect("disparado", _on_disparo_realizado)

func _physics_process(delta):
	procesar_movimiento()
	look_at(get_global_mouse_position())
	procesar_disparo()

func procesar_movimiento():
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	esta_moviendose = direccion.length() > 0
	velocity = direccion.normalized() * velocidad
	move_and_slide()

func procesar_disparo():
	if Input.is_action_pressed("ui_leftclick") and arma_actual and arma_actual.has_method("disparar"):
		var mouse_pos = get_global_mouse_position()
		var posicion = arma_actual.global_position
		var direccion = (mouse_pos - posicion).normalized()
		arma_actual.disparar(posicion, direccion)

func _on_disparo_realizado():
	# Animación del cuerpo
	anim_sprite.play("disparar")
	anim_sprite.frame = 0  # Empieza desde el primer frame

	# Retroceso visual del arma
	weapon_holder.position = weapon_holder_pos_original
	var retroceso_local = Vector2(-4, 0)

	var tween = create_tween()
	tween.tween_property(weapon_holder, "position", weapon_holder_pos_original + retroceso_local, 0.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(weapon_holder, "position", weapon_holder_pos_original, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	# Retroceso físico del cuerpo
	var direccion_retroceso = -transform.x * retroceso_fuerza
	var cuerpo_tween = create_tween()
	cuerpo_tween.tween_property(self, "position", position + direccion_retroceso, duracion_retroceso / 2)
	cuerpo_tween.tween_property(self, "position", position, duracion_retroceso / 2)

	# shot_effect.emitting = true
	# audio_player.play()

func _on_AnimatedSprite2D_animation_finished():
	if anim_sprite.animation == "disparar":
		print("Animación terminó, actualizando...")
		actualizar_animaciones()

func actualizar_animaciones():
	if anim_sprite.animation == "disparar":
		return  # Esperar a que termine

	if esta_moviendose:
		if anim_sprite.animation != "caminar":
			anim_sprite.play("caminar")
	else:
		if anim_sprite.animation != "idle":
			anim_sprite.play("idle")

	anim_sprite.frame = 0  # Reinicia la animación correctamente
	anim_sprite.scale = escala_original

func _animar_movimiento():
	if not anim_sprite:
		return
	var tiempo = Time.get_ticks_msec() / 200.0
	var factor_escala = 1.0 + sin(tiempo) * 0.05
	anim_sprite.scale = escala_original * factor_escala
