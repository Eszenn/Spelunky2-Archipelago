local json = require "lib.json"
local Data = require "data"

path = "saves/"
save_name = ""

ap_save = {
    last_character = 1,

    max_world = 1,
    shortcut_progress = 10, -- Change this when shortcuts are implemented
    last_index = -1, -- Stores AP item data sent from the server

    unlocked_key_items = {
        [1] = false,  -- Udjat Eye
        [2] = false, -- Hedjet
        [3] = false, -- Crown
        [4] = false, -- Ankh
        [5] = false, -- Tablet of Destiny
        [6] = false, -- Scepter
        [7] = false, -- Excalibur
        [8] = false, -- Hou Yi Bow
        [9] = false, -- Arrow of Light
        [10] = false -- Ushabti
    },

    starting_characters = {1, 2, 3, 4},

    unlocked_characters = {
        [1] = false,  -- Ana Spelunky
        [2] = false,  -- Margaret Tunnel
        [3] = false,  -- Colin Northward
        [4] = false,  -- Roffy D. Sloth
        [5] = false,  -- Alto Singh
        [6] = false,  -- Liz Mutton
        [7] = false,  -- Nekka the Eagle
        [8] = false,  -- LISE Project
        [9] = false,  -- Coco Von Diamonds
        [10] = false, -- Manfred Tunnel
        [11] = false, -- Little Jay
        [12] = false, -- Tina Flan
        [13] = false, -- Valerie Crump
        [14] = false, -- Au
        [15] = false, -- Demi Von Diamonds
        [16] = false, -- Pilot
        [17] = false, -- Princess Airyn
        [18] = false, -- Dirk Yamaoka
        [19] = false, -- Guy Spelunky
        [20] = false  -- Classic Guy
    },

    unlocked_worlds = {
        ["dwelling"] = true,
        ["jungle"] = false,
        ["volcana"] = false,
        ["olmec"] = false,
        ["tide_pool"] = false,
        ["temple"] = false,
        ["ice_caves"] = false,
        ["neo_babylon"] = false,
        ["sunken_city"] = false,
        ["cosmic_ocean"] = false
    },

    permanent_upgrades = {
        health = 0,
        bombs = 0,
        ropes = 0,
        paste = 0,
        clover = 0,
        compass = 0, -- 0 = no compass, 1 = compass, 2 = alien compass
        eggplant = 0, -- Places an eggplant in Waddler's shop if true
        shortcuts = 0,
        checkpoints = 0
    },

    places = {
        [1] = false,  -- Dwelling
        [2] = false,  -- Jungle
        [3] = false,  -- Volcana
        [4] = false,  -- Olmec's Lair
        [5] = false,  -- Tide Pool
        [6] = false,  -- Abzu
        [7] = false,  -- Temple of Anubis
        [8] = false,  -- City of Gold
        [9] = false,  -- Duat
        [10] = false, -- Ice Caves
        [11] = false, -- Neo Babylon
        [12] = false, -- Tiamat's Throne
        [13] = false, -- Sunken Cty
        [14] = false, -- Eggplant World
        [15] = false, -- Hundun's Hideaway
        [16] = false  -- Cosmic Ocean
    },

    people = {
        [1] = false,  -- Ana Spelunky
        [2] = false,  -- Margaret Tunnel
        [3] = false,  -- Colin Northward
        [4] = false,  -- Roffy D. Sloth
        [5] = false,  -- Alto Singh
        [6] = false,  -- Liz Mutton
        [7] = false,  -- Nekka the Eagle
        [8] = false,  -- LISE Project
        [9] = false,  -- Coco Von Diamonds
        [10] = false, -- Manfred Tunnel
        [11] = false, -- Little Jay
        [12] = false, -- Tina Flan
        [13] = false, -- Valerie Crump
        [14] = false, -- Au
        [15] = false, -- Demi Von Diamonds
        [16] = false, -- Pilot
        [17] = false, -- Princess Airyn
        [18] = false, -- Dirk Yamaoka
        [19] = false, -- Guy Spelunky
        [20] = false, -- Classic Guy
        [21] = false, -- Mama Tunnel
        [22] = false, -- Hired Hand
        [23] = false, -- Eggplant Child
        [24] = false, -- Shopkeeper
        [25] = false, -- Tun
        [26] = false, -- Yang
        [27] = false, -- Madame Tusk
        [28] = false, -- Tusk's Bodyguard
        [29] = false, -- Waddler
        [30] = false, -- Caveman Shopkeeper
        [31] = false, -- Ghist Shopkeeper
        [32] = false, -- Van Horsing
        [33] = false, -- Parsley
        [34] = false, -- Parsnip
        [35] = false, -- Parmesan
        [36] = false, -- Sparrow
        [37] = false, -- Beg
        [38] = false, -- Eggplant King
    },

    bestiary = {
        [1] = false,  -- Snake
        [2] = false,  -- Spider
        [3] = false,  -- Bat
        [4] = false,  -- Caveman
        [5] = false,  -- Skeleton
        [6] = false,  -- Horned Lizard
        [7] = false,  -- Cave Mole
        [8] = false,  -- Quillback
        [9] = false,  -- Mantrap
        [10] = false, -- Tikiman
        [11] = false, -- Witch Doctor
        [12] = false, -- Mosquito
        [13] = false, -- Monkey
        [14] = false, -- Hang Spider
        [15] = false, -- Giant Spider
        [16] = false, -- Magmar
        [17] = false, -- Robot
        [18] = false, -- Fire Bug
        [19] = false, -- Imp
        [20] = false, -- Lavamander
        [21] = false, -- Vampire
        [22] = false, -- Vlad
        [23] = false, -- Olmec
        [24] = false, -- Jiangshi
        [25] = false, -- Jiangshi Assassin
        [26] = false, -- Fish
        [27] = false, -- Octopy
        [28] = false, -- Hermit Crab
        [29] = false, -- Pangxie
        [30] = false, -- Great Humphead
        [31] = false, -- Kingu
        [32] = false, -- Crocman
        [33] = false, -- Cobra
        [34] = false, -- Mummy
        [35] = false, -- Sorceress
        [36] = false, -- Cat Mummy
        [37] = false, -- Necromancer
        [38] = false, -- Anubis
        [39] = false, -- Ammit
        [40] = false, -- Apep
        [41] = false, -- Anubis II
        [42] = false, -- Osiris
        [43] = false, -- UFO
        [44] = false, -- Alien
        [45] = false, -- Yeti
        [46] = false, -- Yeti King
        [47] = false, -- Yeti Queen
        [48] = false, -- Lahamu
        [49] = false, -- Proto Shopkeeper
        [50] = false, -- Olmite
        [51] = false, -- Lamassu
        [52] = false, -- Tiamat
        [53] = false, -- Tadpole
        [54] = false, -- Frog
        [55] = false, -- Fire Frog
        [56] = false, -- Goliath Frog
        [57] = false, -- Grub
        [58] = false, -- Giant Fly
        [59] = false, -- Hundun
        [60] = false, -- Eggplant Minister
        [61] = false, -- Eggplup
        [62] = false, -- Celestial Jelly
        [63] = false, -- Scorpion
        [64] = false, -- Bee
        [65] = false, -- Queen Bee
        [66] = false, -- Scarab
        [67] = false, -- Golden Monkey
        [68] = false, -- Leprechaun
        [69] = false, -- Monty
        [70] = false, -- Percy
        [71] = false, -- Poochi
        [72] = false, -- Ghist
        [73] = false, -- Ghost
        [74] = false, -- Cave Turkey
        [75] = false, -- Rock Dog
        [76] = false, -- Axolotl
        [77] = false, -- Qilin
        [78] = false  -- Mech Rider
    },

    items = {
        [1] = false, -- Rope Pile
        [2] = false, -- Bomb Bag
        [3] = false, -- Bomb Box
        [4] = false, -- Paste
        [5] = false, -- Spectacles
        [6] = false, -- Climbing Gloves
        [7] = false, -- Pitcher's Mitt
        [8] = false, -- Spring Shoes
        [9] = false, -- Spike Shoes
        [10] = false, -- Compass
        [11] = false, -- Alien Compass
        [12] = false, -- Parachute
        [13] = false, -- Udjat Eye
        [14] = false, -- Kapala
        [15] = false, -- Hedjet
        [16] = false, -- Crown
        [17] = false, -- Eggplant Crown
        [18] = false, -- True Crown
        [19] = false, -- Ankh
        [20] = false, -- Tablet of Destiny
        [21] = false, -- Skeleton Key
        [22] = false, -- Royal Jelly
        [23] = false, -- Cape
        [24] = false, -- Vlad's Cape
        [25] = false, -- Jetpack
        [26] = false, -- Telepack
        [27] = false, -- Hoverpack
        [28] = false, -- Powerpack
        [29] = false, -- Webgun
        [30] = false, -- Shotgun
        [31] = false, -- Freeze Ray
        [32] = false, -- Clone Gun
        [33] = false, -- Crossbow
        [34] = false, -- Camera
        [35] = false, -- Teleporter
        [36] = false, -- Mattock
        [37] = false, -- Boomerang
        [38] = false, -- Machete
        [39] = false, -- Excalibur
        [40] = false, -- Broken Sword
        [41] = false, -- Plasma Cannon
        [42] = false, -- Scepter
        [43] = false, -- Hou Yi's Bow
        [44] = false, -- Arrow of Light
        [45] = false, -- Wooden Shield
        [46] = false, -- Metal Shield
        [47] = false, -- Idol
        [48] = false, -- The Tusk Idol
        [49] = false, -- Curse Pot
        [50] = false, -- Ushabti
        [51] = false, -- Eggplant
        [52] = false, -- Cooked Turkey
        [53] = false, -- Elixir
        [54] = false, -- Four-Leaf Clover
    },

    traps = {
        [1] = false, -- Spikes
        [2] = false, -- Arrow Trap
        [3] = false, -- Totem Trap
        [4] = false, -- Log Trap
        [5] = false, -- Spear Trap
        [6] = false, -- Thorny Vine
        [7] = false, -- Bear Trap
        [8] = false, -- Powder Box
        [9] = false, -- Falling Platform
        [10] = false, -- Spikeball
        [11] = false, -- Lion Trap
        [12] = false, -- Giant Clam
        [13] = false, -- Sliding Wall
        [14] = false, -- Crush Trap
        [15] = false, -- Giant Crush Trap
        [16] = false, -- Boulder
        [17] = false, -- Spring Trap
        [18] = false, -- Landmine
        [19] = false, -- Laser Trap
        [20] = false, -- Spark Trap
        [21] = false, -- Frog Trap
        [22] = false, -- Sticky Trap
        [23] = false, -- Bone Drop
        [24] = false  -- Egg Sac
    }
}

function backup_save()
    local backup = {
        _places = savegame.places,
        _bestiary = savegame.bestiary,
        _people = savegame.people,
        _items = savegame.items,
        _traps = savegame.traps,
        _last_daily = savegame.last_daily,
        _characters = savegame.characters,
        _bestiary_killed = savegame.bestiary_killed,
        _bestiary_killed_by = savegame.bestiary_killed_by,
        _people_killed = savegame.people_killed,
        _people_killed_by = savegame.people_killed_by,
        _plays = savegame.plays,
        _deaths = savegame.deaths,
        _wins_normal = savegame.wins_normal,
        _wins_hard = savegame.wins_hard,
        _wins_special = savegame.wins_special,
        _score_total = savegame.score_total,
        _score_top = savegame.score_top,
        _deepest_area = savegame.deepest_area,
        _deepest_level = savegame.deepest_level,
        _time_best = savegame.time_best,
        _time_total = savegame.time_total,
        _time_tutorial = savegame.time_tutorial,
        _character_deaths = savegame.character_deaths,
        _pets_rescued = savegame.pets_rescued,
        _completed_normal = savegame.completed_normal,
        _completed_ironman = savegame.completed_ironman,
        _completed_hard = savegame.completed_hard,
        _profile_seen = savegame.profile_seen,
        _seeded_unlocked = savegame.seeded_unlocked,
        _world_last = savegame.world_last,
        _level_last = savegame.level_last,
        _theme_last = savegame.theme_last,
        _score_last = savegame.score_last,
        _time_last = savegame.time_last,
        _players = savegame.players,
        _constellation = savegame.constellation
    }

    local file = io.open_data("Savegame.json", "w+")

    if file ~= nil then
        file:write(json.encode(backup))
        file:close()
    end
end


function initialize_save()
    savegame.tutorial_state = 4
    savegame.shortcuts = ap_save.shortcut_progress
    savegame.places[1] = true
    ap_save.places[1] = true
    for index, character in ipairs(ap_save.starting_characters) do
        savegame.players[index] = character - 1
    end

    for _, chapter in ipairs(journal.chapters) do
        clear_journal(savegame[chapter])
    end

    set_starting_characters()
end


function update_game_save()
    for _, chapter in ipairs(journal.chapters) do
        copy_journal_data(chapter)
    end
end


function set_starting_characters()
    for _, index in ipairs(ap_save.starting_characters) do
        ap_save.unlocked_characters[index] = true
        savegame.people[index] = true
        ap_save.people[index] = true
    end
end


function update_characters()
    local character_sum = 0
    for character, is_unlocked in ipairs(ap_save.unlocked_characters) do
        if is_unlocked then
            character_sum = character_sum + character_data.binary_values[character]
            savegame.people[character] = true
        end
    end

    savegame.characters = character_sum
end

function lock_characters()
    local character_sum = 0
    for index, is_unlocked in ipairs(ap_save.people) do
        if is_unlocked and index <= 20 then
            character_sum = character_sum + character_data.binary_values[index]
        end
    end

    savegame.characters = character_sum
end


function update_journal(chapter, index)
    ap_save[chapter][index] = true

    if debugging then
        prinspect(F"Updated {chapter} entry {journal[chapter][index]}")
    end

    send_location(chapter, index)
end

function copy_journal_data(chapter)
    local array = ap_save[chapter]
    for index, value in ipairs(array) do
        savegame[chapter][index] = value
    end
end


function clear_journal(array)
    for i, _ in ipairs(array) do
        array[i] = false
    end
end


function write_save()
    local file = io.open_data(f"{path}AP_{game_info.username}_{player_options.seed}.json", "w+")

    if file ~= nil then
        file:write(json.encode(ap_save))
        file:close()

        if debugging then
            prinspect(f"Saved data to {path}AP_{game_info.username}_{player_options.seed}.json")
        end
    end
end


function read_save()
    local file = io.open_data(f"{path}AP_{game_info.username}_{player_options.seed}.json", "r")

    if file ~= nil then
        ap_save = json.decode(file:read("a"))
        file:close()
        update_game_save()

        if debugging then
            prinspect(f"Loaded data from {path}AP_{game_info.username}_{player_options.seed}.json")
        end
        
    end
end


function write_last_login()
    local login_info = {
        username = game_info.username,
        host = game_info.host
    }

    local file = io.open_data("login.json", "w+")

    if file ~= nil then
        file:write(json.encode(login_info))
        file:close()
    end
end


function read_last_login()
    local file = io.open_data("login.json")

    if file ~= nil then
        local login_info = json.decode(file:read("a"))
        file:close()

        game_info.username = login_info.username
        game_info.host = login_info.host
    end
end