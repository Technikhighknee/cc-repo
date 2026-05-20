-- When fed with an empty bucket
-- it fills the bucket from forward cauldron
-- and drops it to the chest below
--
-- Setup: 
-- Front -> Cauldron that is fed by Refined Storage exporter
-- Bottom -> Chest with RS importer
-- Back -> RS Autocrafter with processing recipe "1x Empty Bucket -> 1x Lava Bucket"
--
-- NOTE: Fill slot 2 - 16 with something other than buckets; like cobblestone

local EMPTY_BUCKET_NAME = "minecraft:bucket"
local function is_empty_bucket(slot)
    local detail = turtle.getItemDetail(slot)
    return detail and detail.name == EMPTY_BUCKET_NAME
end

local FIRST_SLOT = 1
local function is_first_slot_empty_bucket()
    return is_empty_bucket(FIRST_SLOT)
end

local function fill_bucket()
    return turtle.place()
end

local function drop_bucket_into_chest()
    turtle.dropDown()
end

term.clear()
term.setCursorPos(1,1)
print("Bucket filling machine")

while true do
    if is_first_slot_empty_bucket() then
        if fill_bucket() then
            drop_bucket_into_chest()
        end
    end
    os.sleep(0)
end
