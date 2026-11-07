extends Node

var BackflipAction = "backflip"
var Action = InputEventKey.new()
var mp_client
var ismultiplayer = false
var hasmpmod = false
var client
var player_sync
var puppet_manager
var idk
var firstPass = false
var mpmodtimer = 5

var msg_connection

var rotating_nias = {}

var ownKey = 696969696969696969 #if its a string it blows up

var template_vars = {}
func _init() -> void:
    
    Action.physical_keycode = KEY_B
    InputMap.add_action(BackflipAction)
    InputMap.action_add_event("backflip",Action)

func _ready() -> void:
    
    
    process_priority = 6767
    process_physics_priority = 6767
    
    
    template_vars.rotating = false

    template_vars.db_timer = 0

    template_vars.windupHappened = false
    template_vars.offset = 0.66
    template_vars.progress = 0.0
    template_vars.timeToFlip = 0.62
    template_vars.FlipTimer = 0
    template_vars.flipDelay = 0.06
    
    template_vars.jumpTimer = 0
    template_vars.timeToJump = 0.7
    template_vars.jumpProg = 0.0
    
    
    
    template_vars.jumping = false
    
    template_vars.sx = 0.6
    template_vars.sy = 1.3
    template_vars.speed = 3
    template_vars.nia = null
    
    rotating_nias[ownKey] = template_vars.duplicate(true)
func check_mp():
    if ModLoaderMod.is_mod_active("com-multiplayer"):
        if not get_tree().get_first_node_in_group("mp").client:
            ismultiplayer = false
            return
        if ismultiplayer and is_instance_valid(puppet_manager):
            return
        
        ismultiplayer = true
        #thanks to BdE for helping me get all this
        player_sync = get_tree().get_first_node_in_group("player_sync")
        puppet_manager = get_tree().get_first_node_in_group("mp").client.get_node("PuppetManager")
        var new_client = get_tree().get_first_node_in_group("mp").network_client
        
        if not new_client.player_message.is_connected(thingthatrunswhenbackflipactionisrecievedfromsomebodyelseiduno):
            client = new_client
            client.player_message.connect(thingthatrunswhenbackflipactionisrecievedfromsomebodyelseiduno)
       


func _process(delta: float) -> void:
    if Input.is_action_just_pressed("backflip"):
        var nia = game.nia
        if not nia: return
        var unconscious = nia.unconscious
        var is_sitting = nia.is_sitting
        var is_paused = nia.is_paused
        if ( !unconscious and !is_sitting and !is_paused) and nia.is_on_floor():
            if not firstPass or not rotating_nias[ownKey].rotating:
                if ismultiplayer:
                    player_sync.send_action("BACKFLIP")
                add_nia(nia,ownKey)
                firstPass = true
    
    if mpmodtimer==100:
        mpmodtimer = 0
        check_mp()
    mpmodtimer+=1
func thingthatrunswhenbackflipactionisrecievedfromsomebodyelseiduno(id,message,plrname):
    
    if message == "DO:BACKFLIP":
        
        var target_nia = puppet_manager.puppets[id].get_node("nia")
        
        add_nia(target_nia,id)

func add_nia(target,id):
    
    var nia = target
    if not nia: return
    var entry = template_vars.duplicate(true)
    entry.nia = nia
    if not id:
        id = ownKey
    flip_a_nia(entry,id)
    
    
func flip_a_nia(entry,id):
    
    rotating_nias[id] = entry
    var nia = entry.nia
    
    
    entry.posSave = nia.chara.position
    nia.chara.scale = Vector3(1.3,0.7,1.3)
    
    
func _physics_process(delta: float) -> void:
    for key in rotating_nias:
        var entry = rotating_nias[key]
        var nia
        if entry.nia:
            nia = entry.nia
        
            nia.chara.scale.x = move_toward(nia.chara.scale.x,entry.sx,entry.speed*delta)
            nia.chara.scale.y = move_toward(nia.chara.scale.y,entry.sy,entry.speed*delta)
            nia.chara.scale.z = move_toward(nia.chara.scale.z,entry.sx,entry.speed*delta)
            if entry.jumpProg>=1 and entry.rotating:
                
                nia.chara.scale =Vector3(1.3,0.7,1.3)
                entry.rotating = false
                entry.jumping = false
                    
                nia.chara.position = Vector3.ZERO
                
                nia.chara.rotation.x = 0
                audio.play_snd_spatial(game.loadres("cloth_00"), nia.global_position, 8.0)
                var move_doer = nia.get_node("anim_player")
                var animtree = nia.get_node("anim_tree")
                animtree.active = true
                move_doer.stop()
                
            if nia.chara.scale.y >= 1 and not entry.windupHappened:
                entry.windupHappened=true
                
                entry.rotating = true
                entry.FlipTimer = 0.0
                entry.jumping = true
                entry.speed = 5
                var animtreetree = nia.get_node("anim_tree")
                var move_doer = nia.get_node("anim_player")
                animtreetree.active = false
                move_doer.play("jump")
            if nia.chara.scale.y >= 1.29  and entry.windupHappened:
                entry.speed = 1
                entry.sx = 1
                entry.sy = 1 
        
            
        
        
            if entry.rotating and entry.FlipTimer<=entry.timeToFlip+entry.flipDelay:
                entry.FlipTimer+=delta
                entry.progress=clamp((entry.FlipTimer-entry.flipDelay)/entry.timeToFlip,0.0,1.0)
                
            if entry.jumping and entry.jumpTimer<=entry.timeToJump:
                entry.jumpTimer+=delta
                entry.jumpProg=clamp((entry.jumpTimer)/entry.timeToJump,0.0,1.0)
                
                
                
            if entry.rotating:
            
        
                nia.chara.rotation.x = 2*PI*entry.progress
                var basis = nia.chara.basis
                nia.chara.position = Vector3(0,entry.offset+4.0 * 1.5 * entry.jumpProg * (1.0 - entry.jumpProg),0)-basis*Vector3(0,entry.offset,0.05)
    
            
    
