local saveLib = require "save"

local AP = package.loadlib("lua-apclientpp.dll", "luaopen_apclientpp")()

---@type APClient
local ap = nil

-- Various variables to run the client
local password_censored = ""
local item_queue = {}
local items_in_queue = false
local ready_for_item = true
local caused_by_death_link = false
local goal_completed = false

game_info = {
    game = "Spelunky 2",
    username = "",
    host = "archipelago.gg:38281",
    password_hidden = "",
    items_handling = 7, -- full remote
    message_format = AP.RenderFormat.TEXT
}

player_options = {
    seed = "BACKUP",
    goal = 0,
    goal_level = 30,
    progressive_worlds = true,
    starting_health = 4,
    starting_bombs = 4,
    starting_ropes = 4,
    death_link = false,
    bypass_ankh = false
}

read_last_login()

local show_connect_button = true
set_callback(function(ctx)
    if state.screen == SCREEN.MENU then
        ctx:window("Spelunky 2 Archipelago", 0, 0, 0, 0, true, function(ctx, pos, size)
            ctx:win_text("Slot Name")
            game_info.username = ctx:win_input_text(" ##Slot Name", game_info.username)

            ctx:win_text("Server Address")
            game_info.host = ctx:win_input_text(" ##Host", game_info.host)

            ctx:win_text("Password")
            game_info.password_hidden = ctx:win_input_text(" ##Password", password_censored)

            ctx:win_separator()

            if show_connect_button then
                if ctx:win_button("Connect") then
                    prinspect("Connecting to the server...")
                    connect(game_info.host, game_info.username, game_info.password_hidden)
                end
            else
                if ctx:win_button("Disconnect") then
                    show_connect_button = true
                    prinspect("Disconnecting from the server...")
                    ap = nil
                    collectgarbage("collect")
                end
            end
        end)

        if state.screen == SCREEN.MENU then
            if #password_censored < #game_info.password_hidden then
                password_censored = password_censored .. "*"
            end
        end
    end

    if ap ~= nil then
        ap:poll()
    end
end, ON.GUIFRAME)


function connect(server, slot, password)
    function on_socket_connected()
        print("Socket connected")
    end

    function on_socket_error(msg)
        print("Socket error: " .. msg)
    end

    function on_socket_disconnected()
        print("Socket disconnected")

    end

    function on_room_info()
        ap:ConnectSlot(slot, password, game_info.items_handling, {"Lua-APClientPP"}, {0, 3, 9})
    end

    function on_slot_connected(slot_data)
        print("Slot connected")
        show_connect_button = false
        write_last_login()

        player_options.seed = ap:get_seed()
        player_options.goal = slot_data.goal
        player_options.goal_level = slot_data.goal_level
        player_options.progressive_worlds = slot_data.progressive_worlds
        player_options.starting_health = slot_data.starting_health
        player_options.starting_bombs = slot_data.starting_bombs
        player_options.starting_ropes = slot_data.starting_ropes
        player_options.death_link = slot_data.death_link
        
        
        if player_options.death_link then
            ap:ConnectUpdate(nil, {"Lua-APClientPP", "DeathLink"})

            player_options.bypass_ankh = slot_data.bypass_ankh

            set_callback(function()
                if not caused_by_death_link then
                    local data = {
                        time = ap:get_server_time(),
                        source = game_info.username
                    }
                    ap:Bounce(data, nil, nil, {"DeathLink"})
                end
            end, ON.DEATH)
        end

        -- Set ap_save.starting_characters in here 

        set_ap_callbacks()
        initialize_save()
        read_save()
    end

    function on_slot_refused(reasons)
        print("Slot refused: " .. table.concat(reasons, ", "))
    end

    function on_items_received(items)
        for _, data in ipairs(items) do
            if data.index > ap_save.last_index then
                table.insert(item_queue, #item_queue + 1, data.item)
                items_in_queue = true
            end
        end
    end

    function on_location_info(items)
        print("Locations scouted:")
        for _, item in ipairs(items) do
            print(item.item)
        end
    end

    function on_location_checked(locations)
        print("Locations checked:" .. table.concat(locations, ", "))
        print("Checked locations: " .. table.concat(ap.checked_locations, ", "))
    end

    function on_data_package_changed(data_package)
        print("Data package changed:")
        print(data_package)
    end

    function on_print(msg)
        print(msg)
    end

    function on_print_json(msg, extra)
        print(ap:render_json(msg, player_options.message_format))
        for key, value in pairs(extra) do
            print("  " .. key .. ": " .. tostring(value))
        end
    end

    function on_bounced(bounce)
        if bounce.tags ~= nil then
            for _, tag in ipairs(bounce.tags) do
                if tag == "DeathLink" and bounce.data.source ~= game_info.username then
                    queue_death_link()
                end
            end
        end
    end

    function on_retrieved(map, keys, extra)
        print("Retrieved:")
        -- since lua tables won't contain nil values, we can use keys array
        for _, key in ipairs(keys) do
            print("  " .. key .. ": " .. tostring(map[key]))
        end
        -- extra will include extra fields from Get
        print("Extra:")
        for key, value in pairs(extra) do
            print("  " .. key .. ": " .. tostring(value))
        end
        -- both keys and extra are optional
    end

    function on_set_reply(message)
        print("Set Reply:")
        for key, value in pairs(message) do
            print("  " .. key .. ": " .. tostring(value))
            if key == "value" and type(value) == "table" then
                for subkey, subvalue in pairs(value) do
                    print("    " .. subkey .. ": " .. tostring(subvalue))
                end
            end
        end
    end

    ap = AP(slot, game_info.game, server);

    --ap:set_socket_connected_handler(on_socket_connected)
    ap:set_socket_error_handler(on_socket_error)
    --ap:set_socket_disconnected_handler(on_socket_disconnected)
    ap:set_room_info_handler(on_room_info)
    ap:set_slot_connected_handler(on_slot_connected)
    ap:set_slot_refused_handler(on_slot_refused)
    ap:set_items_received_handler(on_items_received)
    ap:set_location_info_handler(on_location_info)
    --ap:set_location_checked_handler(on_location_checked)
    ap:set_data_package_changed_handler(on_data_package_changed)
    --ap:set_print_handler(on_print)
    --ap:set_print_json_handler(on_print_json)
    ap:set_bounced_handler(on_bounced)
    ap:set_retrieved_handler(on_retrieved)
    ap:set_set_reply_handler(on_set_reply)
end


function set_ap_callbacks()
    set_callback(function()
        if items_in_queue and state.screen == SCREEN.LEVEL and ready_for_item then
            local item = item_ids[item_queue[1]]
            ready_for_item = false

            if state.toast_timer ~= 0 then
                set_interval(function()
                    state.toast_timer = 0
                    ready_for_item = true
                    clear_callback()
                end, 195 - state.toast_timer)
                return
            end

            if state.speechbubble_timer ~= 0 then
                set_interval(function()
                    state.speechbubble_timer = 0
                    ready_for_item = true
                    clear_callback()
                end, 261 - state.speechbubble_timer)
                return
            end

            item_handler(item.type)

            toast(f"You received {item.name}!")

             set_interval(function()
                ready_for_item = true
                clear_callback()
            end, 195)

            table.remove(item_queue, 1)
            ap_save.last_index = ap_save.last_index + 1

            write_save()
            
            if #item_queue == 0 then
                items_in_queue = false
            end
        end
    end, ON.GAMEFRAME)

    set_callback(function()
        ready_for_item = true
    end, ON.POST_LEVEL_GENERATION)

    set_callback(function()
        caused_by_death_link = false
        state.toast_timer = 0
        state.speechbubble_timer = 0
    end, ON.START)

    set_callback(function()
        if player_options.goal == 2 and state.world == 7 and state.level == player_options.goal_level - 1 then
            state.win_state = 3
            state.level_next = 99
        end
    end, ON.LEVEL)

    set_callback(function()
        if (player_options.goal == 0 and state.win_state == 1) or (player_options.goal == 1 and state.win_state == 2) then
            complete_goal()
        end
    end, ON.WIN)

    set_callback(function()
        if player_options.goal == 2 and state.win_state == 3 then
            complete_goal()
        end
    end, ON.CONSTELLATION)
end


function send_location(chapter, index)
    local location_name = f"{journal[chapter][index]} Journal Entry"
    local location_id = location_name_to_id[location_name]
    ap:LocationChecks({location_id})
    write_save()
end


function item_handler(type)
    local was_item_processed = false
    
    if not goal_completed then
        for _, item_type in ipairs(item_categories.filler_items) do
            if type == item_type then
                give_item(type)
                was_item_processed = true
            end
        end


        for _, trap in ipairs(item_categories.traps) do
            if type == trap then
                give_trap(type)
                was_item_processed = true
            end
        end
    end

    for index, character_type in ipairs(character_data.types) do
        if type == character_type and not ap_save.unlocked_characters[index] then
            ap_save.unlocked_characters[index] = true
            was_item_processed = true
        end
    end

    for index, key_item_type in ipairs(item_categories.key_items) do
        if type == key_item_type then
            ap_save.unlocked_key_items[index] = true
            was_item_processed = true
        end
    end

    for _, upgrade in ipairs(item_categories.permanent_upgrades) do
        if type == upgrade then
            ap_save.permanent_upgrades[upgrade] = ap_save.permanent_upgrades[upgrade] + 1
            was_item_processed = true
        end
    end

    if type == "max_world" then
        ap_save.max_world = ap_save.max_world + 1
        was_item_processed = true
    end

    for _, world in ipairs(item_categories.worlds) do
        if type == world then
            ap_save.unlocked_worlds[world] = true
            was_item_processed = true
        end
    end

    return was_item_processed
end


function complete_goal()
    ap:StatusUpdate(ap.ClientStatus.GOAL)
    toast("You have completed your goal!")

    while #item_queue > 0 do
        local item = item_ids[item_queue[1]]
        item_handler(item.type)

        table.remove(item_queue, 1)
        ap_save.last_index = ap_save.last_index + 1

        write_save()
    end
end

function queue_death_link()
    set_global_interval(function()
        if state.screen == SCREEN.LEVEL then
            local player = get_player(1, false)

            if player_options.bypass_ankh and player:has_powerup(ENT_TYPE.ITEM_POWERUP_ANKH) then
                player:remove_powerup(ENT_TYPE.ITEM_POWERUP_ANKH)
            end

            player:kill(false, nil)

            caused_by_death_link = true

            clear_callback()
        end
    end, 1)
end
