-- Loops through inventory (fed by hopper)
-- drops whitelisted items to bottom chest
-- drops all other to front chest

local INVENTORY_SLOTS = 16

local ITEM_WHITELIST = {
    "minecraft:leather",
    "minecraft:gravel",
    "minecraft:nether_bricks",
    "minecraft:crying_obsidian",
    "minecraft:obsidian",
    "minecraft:soul_sand",
    "minecraft:fire_charge",
    "minecraft:iron_nugget",
    "minecraft:blackstone",
    "minecraft:quartz",
    "minecraft:spectral_arrow",
    "minecraft:string",
    "minecraft:ender_pearl"
}

local function is_in_whitelist(item_name)
    for _, name in ipairs(ITEM_WHITELIST) do
        if item_name == name then
            return true
        end
    end
    return false
end

local function get_item_name(slot)
    local detail = turtle.getItemDetail(slot)
    if not detail then return nil end
    return detail.name
end

local function keep_selected()
    turtle.dropDown()
end

local function discard_selected()
    turtle.drop()
end

term.clear()
term.setCursorPos(1, 1)
print("Sorting Machine")

while true do
    for slot = 1, INVENTORY_SLOTS do
        local name = get_item_name(slot)
        if not name then goto continue end
        turtle.select(slot)
        if is_in_whitelist(name) then
            keep_selected()
        else
            discard_selected()
        end
        ::continue::
    end
    os.sleep(0)
end
