extends CharacterBody2D

const speed = 30
var current_state = IDLE

var dir = Vector2.RIGHT
var start_pos

var is_roaming = true
var is_chatting = false
var can_interact = true  # Flag to manage interaction cooldown

var player
var player_in_chat_zone = false

@onready var dialogue_player = $"Dialogue"
@onready var cooldown_timer = $CooldownTimer  # Reference to Timer node

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

func _ready():
	randomize()
	start_pos = position


func _process(delta):
	if current_state == 0 or current_state == 1:
		$AnimatedSprite2D.play("idle")
	elif current_state == 2 and !is_chatting:
		if dir.x == -1:
			$AnimatedSprite2D.play("walk_w")
		if dir.x == 1:
			$AnimatedSprite2D.play("walk_e")    
		if dir.y == -1:
			$AnimatedSprite2D.play("walk_n")
		if dir.y == 1:
			$AnimatedSprite2D.play("walk_s")            

	if is_roaming:
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])
			MOVE:
				move(delta)
	
	if can_interact and Input.is_action_just_pressed("interact"):
		if is_chatting == false and not dialogue_player.d_active and dialogue_player.get_node("NinePatchRect").visible == false:
			print("chatting with npc")
			$Dialogue.start()
			is_roaming = false
			is_chatting = true
			can_interact = false  # Disable interaction
			$AnimatedSprite2D.play("idle")
		elif not dialogue_player.d_active:
			is_chatting = false
			is_roaming = true

	if not Input.is_action_pressed("interact") and not dialogue_player.d_active:
		is_chatting = false 

func choose(array):
	array.shuffle()
	return array.front()    
 
func move(delta):
	if !is_chatting:
		position += dir * speed * delta

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_in_chat_zone = true

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_chat_zone = false

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5, 1, 1.5])
	current_state = choose([IDLE, NEW_DIR, MOVE])

func _on_dialogue_dialogue_finished() -> void:
	is_chatting = false
	is_roaming = true
	start_cooldown()
	
func start_cooldown():
	cooldown_timer.start()  

func _on_cooldown_timer_timeout() -> void:
	print("timeout")
	can_interact = true
	cooldown_timer.stop()
