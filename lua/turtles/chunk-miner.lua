local INVENTORY_SLOTS = 16
local CHUNK_SIZE = 16

local function has_room_for(block_name)
    for slot = 1, INVENTORY_SLOTS do
        local detail = turtle.getItemDetail(slot)
        if not detail then
            return true
        elseif detail.name == block_name and turtle.getItemSpace(slot) > 0 then
            return true
        end
    end
    return false
end

local function inventory_can_take_below()
    local present, data = turtle.inspectDown()
    if not present then return true end
    return has_room_for(data.name)
end

local function block_below_is_bedrock()
    local present, data = turtle.inspectDown()
    if not present then return false end
    return data.name:find("bedrock") ~= nil
end

local function dig_forward_if_any()
    while turtle.detect() do
        turtle.dig()
        sleep(0.4)
    end
end

local function dig_down_if_any()
    if turtle.detectDown() then
        turtle.digDown()
    end
end

local x = 0   -- east-west within the chunk (0..15)
local z = 0   -- north-south within the chunk (0..15)
local y = 0   -- vertical offset from start, negative = down
local facing = 0   -- 0:+z, 1:+x, 2:-z, 3:-x

local function delta_for_facing(f)
    if f == 0 then return 0, 1 end
    if f == 1 then return 1, 0 end
    if f == 2 then return 0, -1 end
    return -1, 0
end

local function turn_right()
    turtle.turnRight()
    facing = (facing + 1) % 4
end

local function turn_left()
    turtle.turnLeft()
    facing = (facing - 1) % 4
end

local function face(target)
    local diff = (target - facing) % 4
    if diff == 1 then
        turn_right()
    elseif diff == 2 then
        turn_right(); turn_right()
    elseif diff == 3 then
        turn_left()
    end
end

local function step_forward()
    while not turtle.forward() do
        dig_forward_if_any()
    end
    local dx, dz = delta_for_facing(facing)
    x = x + dx
    z = z + dz
end

local function step_up()
    while not turtle.up() do
        if turtle.detectUp() then turtle.digUp() end
    end
    y = y + 1
end

local function step_down()
    while not turtle.down() do
        if turtle.detectDown() then turtle.digDown() end
    end
    y = y - 1
end

local chest_facing = nil

local function find_chest()
    for f = 0, 3 do
        face(f)
        local present, data = turtle.inspect()
        if present and data.name:find("chest") then
            chest_facing = f
            return
        end
    end
    error("No chest found around starting position.")
end

local function move_to(target_x, target_z, end_facing)
    if x ~= target_x then
        local want = target_x > x and 1 or 3
        face(want)
        while x ~= target_x do
            step_forward()
        end
    end
    if z ~= target_z then
        local want = target_z > z and 0 or 2
        face(want)
        while z ~= target_z do
            step_forward()
        end
    end
    face(end_facing)
end

local function go_to_surface()
    while y < 0 do
        step_up()
    end
end

local function go_down_to(target_y)
    while y > target_y do
        if turtle.detectDown() then turtle.digDown() end
        step_down()
    end
end

local function dump_at_chest()
    local resume_x, resume_z, resume_y, resume_facing = x, z, y, facing
    go_to_surface()
    move_to(0, 0, chest_facing)
    -- chest is in front; drop forward
    for slot = 1, INVENTORY_SLOTS do
        if turtle.getItemCount(slot) > 0 then
            turtle.select(slot)
            turtle.drop()
        end
    end
    turtle.select(1)
    move_to(resume_x, resume_z, resume_facing)
    go_down_to(resume_y)
end

local function ensure_room_or_dump()
    -- forward check
    if turtle.detect() then
        local _, data = turtle.inspect()
        if not has_room_for(data.name) then
            dump_at_chest()
            return
        end
    end
    if turtle.detectDown() then
        local _, data = turtle.inspectDown()
        if not has_room_for(data.name) then
            dump_at_chest()
        end
    end
end

-- mine one layer at the current y, full 16x16 chunk, boustrophedon
local function mine_layer()
    -- starting at some (x, z); we want to cover the whole 16x16.
    -- simplest: go to (0,0) first, then sweep.
    move_to(0, 0, 0)
    for row = 0, CHUNK_SIZE - 1 do
        -- mine across this row
        local steps_remaining = CHUNK_SIZE - 1
        face(row % 2 == 0 and 0 or 2)
        -- dig the current block down first (we're on it)
        if not block_below_is_bedrock() then
            if not inventory_can_take_below() then dump_at_chest() end
            dig_down_if_any()
        end
        for _ = 1, steps_remaining do
            ensure_room_or_dump()
            dig_forward_if_any()
            step_forward()
            if not block_below_is_bedrock() then
                if not inventory_can_take_below() then dump_at_chest() end
                dig_down_if_any()
            end
        end
        if row < CHUNK_SIZE - 1 then
            -- step sideways into the next row
            face(1)
            ensure_room_or_dump()
            dig_forward_if_any()
            step_forward()
            if not block_below_is_bedrock() then
                if not inventory_can_take_below() then dump_at_chest() end
                dig_down_if_any()
            end
        end
    end
end

-- main
find_chest()
print("Chest found facing " .. chest_facing)

-- the start y is the turtle's actual world y. we mine downward until bedrock.
-- we use turtle.inspectDown to know when to stop:
-- if the block below is bedrock and we can't move down further, we're done.

while true do
    mine_layer()
    -- after mine_layer we're somewhere in the chunk. Try to go down one.
    if turtle.detectDown() then
        local _, data = turtle.inspectDown()
        if data.name:find("bedrock") then
            break
        end
        if not inventory_can_take_below() then dump_at_chest() end
        turtle.digDown()
    end
    if not turtle.down() then
        break
    end
    y = y - 1
end

dump_at_chest()
print("Chunk mining complete.")
