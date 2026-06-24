--!strict

local Loader = require(script.Core.Loader)
local Net = require(script.Core.Net)
local Signal = require(script.Core.Signal)
local State = require(script.Core.State)

return {
    Loader = Loader,
    Net = Net,
    Signal = Signal,
    State = State,
}

