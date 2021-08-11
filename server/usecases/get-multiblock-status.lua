-- Import section

local states = require("entities.states")

local getMachine = require("usecases.get-machine")
local getNumberOfProblems = require("usecases.get-number-of-problems")
local getEnergyUsage = require("usecases.get-energy-usage")
local getEfficiencyPercentage = require("usecases.get-efficiency-percentage")

--

local function exec(address, name)
    local multiblock = getMachine(address, name)
    if string.len(multiblock.address) == 0 then
        return multiblock
    end

    local problems = getNumberOfProblems(multiblock)

    local state = {}
    if multiblock:isWorkAllowed() then
        if multiblock:hasWork() then
            state = states.ON
        else
            state = states.IDLE
        end
    else
        state = states.OFF
    end

    if (problems or 0) > 0 then
        state = states.BROKEN
    end

    local status = {
        progress = multiblock.getWorkProgress(),
        maxProgress = multiblock.getWorkMaxProgress(),
        problems = problems,
        probablyUses = getEnergyUsage(multiblock),
        efficiencyPercentage = getEfficiencyPercentage(multiblock),
        state = state
    }
    return status
end

return exec