-- When fed with an empty bucket
-- it fills the bucket from forward cauldron
-- and drops it to the chest below
--
-- Setup: 
-- Front -> Cauldron that is fed by Refined Storage exporter
-- Bottom -> Chest with RS importer
-- Back -> RS Autocrafter with processing recipe "1x Empty Bucket -> 1x Lava Bucket"

local INVENTORY_SLOTS = 16
local EMPTY_BUCKET_NAME = "minecraft:bucket"
local LAVA_BUCKET_NAME = "minecraft:lava_bucket"

local function is_empty_bucket(slot)
    local detail = turtle.getItemDetail(slot)
    return detail and detail.name == EMPTY_BUCKET_NAME
end

local function is_lava_bucket(slot)
    local detail = turtle.getItemDetail(slot)
    return detail and detail.name == LAVA_BUCKET_NAME
end

local function fill_bucket(slot)
    turtle.select(slot)
    turtle.place()
end

local function drop_bucket_into_chest(slot)
    turtle.select(slot)
    turtle.dropDown()
end

term.clear()
term.setCursorPos(1,1)
print("Bucket filling machine")

while true do
    for slot = 1, INVENTORY_SLOTS do
        if is_empty_bucket(slot) then
            fill_bucket(slot)
        end
        if is_lava_bucket(slot) then
            drop_bucket_into_chest(slot)
        end
    end
    os.sleep(0)
end
