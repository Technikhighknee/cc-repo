local INVENTORY_SLOTS = 16

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

-- Position tracking (relative to start, facing +depth at start)
-- depth = how far down the main tunnel
-- offset = how far sideways (positive = right of start direction)
-- facing = 0:forward(+depth), 1:right(+offset), 2:back(-depth), 3:left(-offset)
local depth, offset, facing = 0, 0, 0

local function turn_right()
    turtle.turnRight()
    facing = (facing + 1) % 4
end

local function turn_left()
    turtle.turnLeft()
    facing = (facing - 1) % 4
end

local function face(target)
    -- Rotate the shortest way to the target facing.
    local diff = (target - facing) % 4
    if diff == 1 then
        turn_right()
    elseif diff == 2 then
        turn_right(); turn_right()
    elseif diff == 3 then
        turn_left()
    end
end

local function delta_for_facing(f)
    if f == 0 then return 1, 0 end
    if f == 1 then return 0, 1 end
    if f == 2 then return -1, 0 end
    return 0, -1
end

local function move_to(target_depth, target_offset, end_facing)
    if offset ~= target_offset then
        print("offset is ", offset, " and we want ", target_offset)
        local want = target_offset > offset and 1 or 3
        face(want)
        while offset ~= target_offset do
            turtle.forward()
            local dd, do_ = delta_for_facing(facing)
            depth = depth + dd
            offset = offset + do_
        end
    end

    if depth ~= target_depth then
        print("depth is ", depth, " and we want ", target_depth)
        local want = target_depth > depth and 0 or 2
        face(want)
        while depth ~= target_depth do
            turtle.forward()
            local dd, do_ = delta_for_facing(facing)
            depth = depth + dd
            offset = offset + do_
        end
    end
    print("Facing ", end_facing)
    face(end_facing)
end

local function return_home()
    move_to(0, 0, 2)
end

move_to(10, 0, 0)
return_home()
