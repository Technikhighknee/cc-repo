local INVENTORY_SLOTS = 16
local function empty_inventory()
    for slot = 1, INVENTORY_SLOTS do
        turtle.select(slot)
        turtle.drop()
    end
end

while true do
    turtle.attack()
    empty_inventory()
    os.sleep(0)
end
