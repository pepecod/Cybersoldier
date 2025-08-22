# Player.gd
extends CharacterBody2D

# ——— Configuración de movimiento y armas ————————————————————————
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


# ——— Señal de nivel (comentado temporalmente) ————————————————
signal level_up(new_level: int)

# ——— Sistema de XP / nivel (comentado mientras pruebas animaciones) ————
# var xp: int         = 0
# var level: int      = 1
# var xp_to_next: int = 10
# const PASSIVE_MENU_SCENE := preload("res://scenes/PassiveSelection.tscn")
@onready var game_state := get_node("/root/GameState")
@onready var weapon_db  := get_node("/root/WeaponDb")

# ——— Nodos internos —————————————————————————————————————————
@onready var weapon_holder:    Node2D             = $WeaponHolder
@onready var anim_sprite:      AnimatedSprite2D   = $AnimatedSprite2D
@onready var shot_effect:      GPUParticles2D     = $WeaponHolder/ShotEffect
@onready var audio_player:     AudioStreamPlayer2D = $WeaponHolder/AudioStreamPlayer2D
@onready var passive_holder = $PassiveHolder
@onready var debug_label: Label = $DebugLabel
# ——— Pasivas equipadas —————————————————————————————————————
var passive_list: Array[WeaponDB.WeaponData] = []
const MINA_SCENE := preload("res://scenes/Armas/Throweables/Minas/minas.tscn")
@export var mine_spawn_radius: float = 150.0
@export var mine_count: int         = 3

# ——— Estado interno ————————————————————————————————————————
var arma_actual: Node            = null
var esta_moviendose: bool        = false
var escala_original: Vector2     = Vector2.ONE
var weapon_holder_pos_original: Vector2

func _ready() -> void:
	# 1) Equipa el arma seleccionada en el menú principal 
	var idx = GameState.selected_weapon_index
	if idx >= 0 and idx < armas_disponibles.size():
		cambiar_arma(idx)
	else:
		cambiar_arma(arma_inicial)

	# Guarda posición y escala para retroceso/animaciones
	weapon_holder_pos_original = weapon_holder.position
	escala_original = anim_sprite.scale
	anim_sprite.play("idle")

	# 2) Conecta señal de fin de animación
	anim_sprite.animation_finished.connect(Callable(self, "_on_AnimatedSprite2D_animation_finished"))
	print("🌱 Spawneando minas…")
	for i in range(mine_count):
		var mina_inst = MINA_SCENE.instantiate()
		get_tree().current_scene.add_child(mina_inst)


	# game_state.connect("level_up", Callable(self, "_on_level_up"))

func cambiar_arma(indice_arma: int) -> void:
	# Elimina la anterior
	if arma_actual:
		arma_actual.queue_free()
	# Instancia la nueva
	arma_actual = armas_disponibles[indice_arma].instantiate()
	weapon_holder.add_child(arma_actual)
	arma_actual.position = Vector2.ZERO
	# Conecta señal de disparo si la emite
	if arma_actual.has_signal("disparado"):
		arma_actual.connect("disparado", Callable(self, "_on_disparo_realizado"))

func _physics_process(delta: float) -> void:
	GameState.player_position = global_position
	debug_label.text = "Player: " + str(global_position)
	procesar_movimiento()
	look_at(get_global_mouse_position())
	procesar_disparo()

func procesar_movimiento() -> void:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	esta_moviendose = dir.length() > 0
	velocity = dir.normalized() * velocidad
	move_and_slide()


func procesar_disparo() -> void:
	if Input.is_action_pressed("ui_leftclick") and arma_actual and arma_actual.has_method("disparar"):
		var mp = get_global_mouse_position()
		var pos = arma_actual.global_position
		var dir = (mp - pos).normalized()
		arma_actual.disparar(pos, dir)

func _on_disparo_realizado() -> void:
	# Animación del cuerpo
	anim_sprite.play("disparar")
	anim_sprite.frame = 0

	# Retroceso visual del arma
	weapon_holder.position = weapon_holder_pos_original
	var retroceso_local = Vector2(-4, 0)
	var tween = create_tween()
	tween.tween_property(weapon_holder, "position", weapon_holder_pos_original + retroceso_local, 0.05) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(weapon_holder, "position", weapon_holder_pos_original, 0.1) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	# Retroceso físico del cuerpo
	var dir_retro = -transform.x * retroceso_fuerza
	var cuerpo_tween = create_tween()
	cuerpo_tween.tween_property(self, "position", position + dir_retro, duracion_retroceso / 2)
	cuerpo_tween.tween_property(self, "position", position, duracion_retroceso / 2)

	# shot_effect.emitting = true
	# audio_player.play()

func _on_AnimatedSprite2D_animation_finished() -> void:
	if anim_sprite.animation == "disparar":
		actualizar_animaciones()

func actualizar_animaciones() -> void:
	if anim_sprite.animation == "disparar":
		return
	if esta_moviendose:
		if anim_sprite.animation != "caminar":
			anim_sprite.play("caminar")
	else:
		if anim_sprite.animation != "idle":
			anim_sprite.play("idle")
	anim_sprite.frame = 0
	anim_sprite.scale = escala_original

func _animar_movimiento() -> void:
	var tiempo = Time.get_ticks_msec() / 200.0
	var factor = 1.0 + sin(tiempo) * 0.05
	anim_sprite.scale = escala_original * factor

# ——— Sistema de nivel (comentado) ————————————————————————————
# func _on_level_up(new_level: int) -> void:
# 	print("¡Jugador subió al nivel %d!" % new_level)
# 	var pool: Array = []
# 	for w in weapon_db.all_weapons:
# 		if w.unlock_level <= new_level:
# 			pool.append(w)
# 	pool.shuffle()
# 	var choices = pool.slice(0, min(pool.size(), 3))
# 	var menu = PASSIVE_MENU_SCENE.instantiate() as PassiveSelection
# 	get_tree().current_scene.add_child(menu)
# 	menu.setup(choices)
# 	get_tree().paused = true
# 	menu.connect("choice_made", Callable(self, "_on_passive_chosen"))
#
# func _on_passive_chosen(data: WeaponDB.WeaponData) -> void:
# 	get_tree().paused = false
# 	if data.type == "active":
# 		var idx: int = weapon_db.all_weapons.find(data)
# 		if idx >= 0 and idx < armas_disponibles.size():
# 			cambiar_arma(idx)
# 		else:
# 			cambiar_arma(arma_inicial)
# 	else:
# 		var inst = load(data.scene_path).instantiate()
# 		passive_holder.add_child(inst)
# 	game_state.selected_passives.append(data.name)
