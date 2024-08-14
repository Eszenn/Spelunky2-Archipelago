local APSave = require "save"
local APClient = require "client"
local Data = require "data"

meta = {
    name = "Archipelago",
    description = "Adds Archipelago Multiworld Randomizer support!",
    author = "Eszenn",
    version = "0.1.0",
    unsafe = true
}

debugging = false

set_callback(function(save_ctx)
    if debugging then
        print("SAVE")
    end
    write_save()
end, ON.SAVE)


set_callback(function()
    if debugging then
        print("LOADING")
    end

    if state.screen_next == SCREEN.CHARACTER_SELECT then
        update_characters()
    end

    -- Prevents unlocking journal entries for characters you have been sent
    if state.screen_next == SCREEN.CAMP then
        ap_save.last_character = savegame.players[1]
        lock_characters()
    end

     --[[
    if state.screen_next == SCREEN.CAMP then
        if ap_save.permanent_upgrades.shortcuts == 0 then
            savegame.shortcuts = 0
        else
            savegame.shortcuts = ap_save.permanent_upgrades.shortcuts * 3 + 1
        end
    end]]
end, ON.LOADING)

-- This handles all of the permanent upgrades to give the player at the start of every run
set_callback(function()
    if debugging then
        prinspect("START")
    end
    
    --savegame.shortcuts = ap_save.shortcut_progress

    local player = get_player(1, false)
    player.health = player_options.starting_health + ap_save.permanent_upgrades.health
    player.inventory.bombs = player_options.starting_bombs + ap_save.permanent_upgrades.bombs
    player.inventory.ropes = player_options.starting_ropes + ap_save.permanent_upgrades.ropes

    if ap_save.permanent_upgrades.paste ~= 0 then
        player:give_powerup(ENT_TYPE.ITEM_POWERUP_PASTE)
    end

    if ap_save.permanent_upgrades.compass == 1 then
        player:give_powerup(ENT_TYPE.ITEM_POWERUP_COMPASS)
    elseif ap_save.permanent_upgrades.compass == 2 then
        player:give_powerup(ENT_TYPE.ITEM_POWERUP_SPECIALCOMPASS)
    end

    if ap_save.unlocked_key_items[8] then
        waddler_store_entity(ENT_TYPE.ITEM_HOUYIBOW)
    end

    if ap_save.permanent_upgrades.eggplant ~= 0 then
        waddler_store_entity(ENT_TYPE.ITEM_EGGPLANT)
    end

    -- if ap_save.permanent_upgrades.clover then
        -- set_ghost_spawn_times(18000, 16200)
    -- end
end, ON.START)


set_callback(function()
    if debugging then
        print("LEVEL")
    end

    if state.level >= 10 and state.level <= ap_save.permanent_upgrades.checkpoints * 10 then
        state.world_start = 7
        state.theme_start = THEME.COSMIC_OCEAN
        state.level_start = math.floor(state.level / 10) * 10
    end


    --[[
    if savegame.shortcuts > ap_save.shortcut_progress then
        ap_save.shortcut_progress = savegame.shortcuts
    end]]
end, ON.LEVEL)


set_callback(function()
    if debugging then
        print("PRE_LEVEL_GENERATION")
    end

    local coffin_uids = get_entities_by(ENT_TYPE.ITEM_COFFIN, MASK.ITEM, LAYER.BOTH)
    for _, uid in ipairs(coffin_uids) do
        local coffin = get_entity(uid)
        for character, is_unlocked in ipairs(ap_save.people) do
            if coffin.inside == character_data.types[character] and is_unlocked then
                set_contents(coffin.uid, ENT_TYPE.CHAR_HIREDHAND)
            end
        end
    end
end, ON.PRE_LEVEL_GENERATION)


set_callback(function()
    for _, chapter in ipairs(journal.chapters) do
        for index, entry in ipairs(savegame[chapter]) do
            if ap_save[chapter][index] ~= entry then
                update_journal(chapter, index)
            end
        end
    end
end, ON.GAMEFRAME)


set_callback(function(draw_ctx)
    if debugging then
        print("TRANSITION")
    end

    if player_options.progressive_worlds then
        if state.world_next > ap_save.max_world then
            toast("This world is not unlocked yet!")
            state.world_next = state.world_start
            state.level_next = state.level_start
            state.theme_next = state.theme_start

            for _, quest in ipairs(state.quests) do
                state.quests[quest] = 0
            end

            state.quest_flags = QUEST_FLAG.RESET
        end
    else
        if not ap_save.unlocked_worlds[theme_to_index[state.theme_next]] then
            toast("This world is not unlocked yet!")
            state.world_next = state.world_start
            state.level_next = state.level_start
            state.theme_next = state.theme_start

            for _, quest in ipairs(state.quests) do
                state.quests[quest] = 0
            end

            state.quest_flags = QUEST_FLAG.RESET
        end
    end
end, ON.TRANSITION)


set_post_entity_spawn(function(entity, spawn_flags)
    local entity_type = get_entity_type(entity.uid)
    if not ap_save.unlocked_key_items[key_item_to_index[entity_type]] then
        entity:destroy_recursive(MASK.ITEM, {ENT_TYPE.ITEM_METAL_ARROW}, RECURSIVE_MODE.INCLUSIVE)
    end
end, SPAWN_TYPE.ANY, MASK.ITEM, ENT_TYPE.ITEM_PICKUP_UDJATEYE, ENT_TYPE.ITEM_PICKUP_HEDJET, ENT_TYPE.ITEM_PICKUP_CROWN, ENT_TYPE.ITEM_PICKUP_ANKH, ENT_TYPE.ITEM_EXCALIBUR, ENT_TYPE.ITEM_SCEPTER, ENT_TYPE.ITEM_PICKUP_TABLETOFDESTINY, ENT_TYPE.ITEM_USHABTI, ENT_TYPE.ITEM_LIGHT_ARROW, ENT_TYPE.ITEM_HOUYIBOW)


function give_item(type)
    local player = get_player(1, false)
    if type == ENT_TYPE.ITEM_PICKUP_ROPEPILE then
        if player.inventory.ropes + 3 > 99 then
            player.inventory.ropes = 99
        else
            player.inventory.ropes = player.inventory.ropes + 3
        end

    elseif type == ENT_TYPE.ITEM_PICKUP_BOMBBAG then
        if player.inventory.bombs + 3 > 99 then
            player.inventory.bombs = 99
        else
            player.inventory.bombs = player.inventory.bombs + 3
        end

    elseif type == ENT_TYPE.ITEM_PICKUP_BOMBBOX then
        if player.inventory.bombs + 12 > 99 then
            player.inventory.bombs = 99
        else
            player.inventory.bombs = player.inventory.bombs + 12
        end

    elseif type == ENT_TYPE.ITEM_PICKUP_COOKEDTURKEY and not player:is_cursed() then
        player.health = player.health + 1

    elseif type == ENT_TYPE.ITEM_PICKUP_ROYALJELLY and not player:is_cursed() then
        player.health = player.health + 6

    elseif type == ENT_TYPE.ITEM_GOLDBAR then
        add_money_slot(375 + (125 * state.world), 1)

    end
end


function give_trap(type)
    local player = get_player(1, false)

    if type == "ghost" then
        set_ghost_spawn_times(0, 0)
        
        set_interval(function()
            set_ghost_spawn_times(10800, 9000)
            clear_callback()
        end, 1)

    elseif type == "poison" then
        poison_entity(player.uid)

    elseif type == "curse" then
        player:set_cursed(true, true)

    elseif type == "stun" then
        for _, uid in ipairs(get_entities_by(0, MASK.MOUNT, LAYER.PLAYER)) do
            local mount = get_entity(uid)
            if mount.rider_uid == player.uid then
                mount:remove_rider()
                break
            end
        end

        player:stun(60)

    elseif type == "loose bombs" then
        local count = 0
        set_interval(function()
            count = count + 1

            local x, y, layer = get_position(player.uid)
            spawn(ENT_TYPE.ITEM_BOMB, x, y, layer, 0, 0)
            
            if count >= 5 then
                clear_callback()
            end
            
        end, 60)

    elseif type == "blind" then
        set_interval(function()
            player.emitted_light.enabled = true
            state.illumination.enabled = false
        end, 1)

    elseif type == "amnesia" then
        player:set_position(state.level_gen.spawn_x, state.level_gen.spawn_y)

    elseif type == "angry" then
        for _, door in ipairs(state.level_gen.exit_doors) do
            local shoppie = get_entity(spawn(ENT_TYPE.MONS_SHOPKEEPER, door.x, door.y, LAYER.FRONT, 0, 0))
            shoppie.aggro_trigger = true
        end
        state.shoppie_aggro = 3

    elseif type == "punish" then
        local altars_destroyed_backup = state.kali_altars_destroyed
        attach_ball_and_chain(player.uid, 0, 0)
        local count = 0
        state.kali_altars_destroyed = 2

        set_callback(function()
            count = count + 1

            if count >= 2 then
                state.kali_altars_destroyed = altars_destroyed_backup
                clear_callback()
            end
        end, ON.LEVEL)
    end
end