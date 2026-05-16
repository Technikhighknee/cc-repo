local INVENTORY_SLOTS = 16

local function is_inventory_full()
    for slot = 1, INVENTORY_SLOTS do
        if turtle.getItemSpace(slot) > 0 then
            return false
        end
    end
    return true
end

while true do
    if not is_inventory_full() then
        turtle.dig()
    else
        sleep(10)
    end
end
