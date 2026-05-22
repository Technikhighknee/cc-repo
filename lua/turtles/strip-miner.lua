if not arg[1] or not arg[2] then
    print("Usage: strip-miner <length> <side_length>")
    return
end

local length = tonumber(arg[1])
local side_length = tonumber(arg[2])

if not length or not side_length or length < 1 or side_length < 1 then
    print("Both arguments must be positive numbers.")
    return
end

local INVENTORY_SLOTS = 16

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

local function inventory_can_take_forward()
    local present, data = turtle.inspect()
    if not present then return true end
    return has_room_for(data.name)
end

local function inventory_can_take_below()
    local present, data = turtle.inspectDown()
    if not present then return true end
    return has_room_for(data.name)
end

local function block_below_is_chest()
    local present, data = turtle.inspectDown()
    if not present then return false end
    return data.name:find("chest") ~= nil
end

local function dump_into_chest()
    for slot = 1, INVENTORY_SLOTS do
        if turtle.getItemCount(slot) > 0 then
            turtle.select(slot)
            turtle.dropDown()
        end
    end
    turtle.select(1)
end

local function dig_forward_if_any()
    while turtle.detect() do
        turtle.dig()
        sleep(0.4)
    end
end

local function dig_down_if_any()
    if turtle.detectDown() and not block_below_is_chest() then
        turtle.digDown()
    end
end

local depth = 0
local offset = 0
local facing = 0

local function delta_for_facing(f)
    if f == 0 then return 1, 0 end
    if f == 1 then return 0, 1 end
    if f == 2 then return -1, 0 end
    return 0, -1
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
    local depthDelta, offsetDelta = delta_for_facing(facing)
    depth = depth + depthDelta
    offset = offset + offsetDelta
end

local function move_to(target_depth, target_offset, end_facing)
    if offset ~= target_offset then
        local want = target_offset > offset and 1 or 3
        face(want)
        while offset ~= target_offset do
            step_forward()
        end
    end

    if depth ~= target_depth then
        local want = target_depth > depth and 0 or 2
        face(want)
        while depth ~= target_depth do
            step_forward()
        end
    end
    face(end_facing)
end

local function return_home()
    move_to(0, 0, 0)
end

local function return_dump_and_resume(resume_depth, resume_offset, resume_facing)
    return_home()
    dump_into_chest()
    move_to(resume_depth, 0, resume_facing)
    move_to(resume_depth, resume_offset, resume_facing)
end

local function mine_one_step()
    if not inventory_can_take_forward() then
        return_dump_and_resume(depth, offset, facing)
        return false
    end
    dig_forward_if_any()

    if not block_below_is_chest() then
        if not inventory_can_take_below() then
            return_dump_and_resume(depth, offset, facing)
            return false
        end
        dig_down_if_any()
    end

    step_forward()
    return true
end

local function dig_strip(direction)
    face(direction)
    local steps_done = 0
    while steps_done < side_length do
        if mine_one_step() then
            steps_done = steps_done + 1
        end
    end
    face((direction + 2) % 4)
    for _ = 1, side_length do
        step_forward()
    end
    face(0)
end

local function maybe_strip()
    if depth % 3 == 0 then
        dig_strip(1)
        dig_strip(3)
    end
end

face(0)
maybe_strip()

local steps_in_main = 0
while steps_in_main < length do
    if mine_one_step() then
        steps_in_main = steps_in_main + 1
        maybe_strip()
    end
end

return_home()
dump_into_chest()
print("Strip mining complete.")