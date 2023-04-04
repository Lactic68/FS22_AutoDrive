ADFruitSensor = ADInheritsFrom(ADSensor)

function ADFruitSensor:new(vehicle, sensorParameters)
    local o = ADFruitSensor:create()
    o:init(vehicle, ADSensor.TYPE_FRUIT, sensorParameters)
    o.fruitType = 0

    if sensorParameters.fruitType ~= nil then
        o.fruitType = sensorParameters.fruitType
    end

    return o
end

function ADFruitSensor:onUpdate(dt)
    local box = self:getBoxShape()
    local corners = self:getCorners(box)

    local foundFruit = false
    if not foundFruit then
        if self.fruitType == nil or self.fruitType == 0 then
            foundFruit, _ = AutoDrive.checkForUnknownFruitInArea(corners)
        else
            foundFruit = AutoDrive.checkForFruitTypeInArea(corners, self.fruitType)
        end
    end

    self:setTriggered(foundFruit)

    self:onDrawDebug(box)
end

function AutoDrive.checkForUnknownFruitInArea(corners)
    for _, fruitType in pairs(g_fruitTypeManager:getFruitTypes()) do
        if not (fruitType == g_fruitTypeManager:getFruitTypeByName("MEADOW")) then
            local fruitTypeIndex = fruitType.index
            if AutoDrive.checkForFruitTypeInArea(corners, fruitTypeIndex) then
                return true, fruitTypeIndex
            end
        end
    end
    return false
end

function AutoDrive.checkForFruitTypeInArea(corners, fruitTypeIndex)
    local fruitValue = 0
    fruitValue, _, _, _ = FSDensityMapUtil.getFruitArea(fruitTypeIndex, corners[1].x, corners[1].z, corners[2].x, corners[2].z, corners[3].x, corners[3].z, true, true)
    return (fruitValue > 10)
end
