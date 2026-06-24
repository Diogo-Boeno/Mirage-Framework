local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Connection.new(signal, fn)
    return setmetatable({
        _signal = signal,
        _fn = fn,
        Connection = true,
    }, Connection)
end

function Connection:Disconnect()
    if not self.Connected then return end
    self.Connected = false
    local index = table.find(self._signal._connection, self)
    if index then
        table.remove(self._signal._connection, index)
    end
end

function Signal.new()
    return setmetatable({
        _connection = {},
    }, Signal)
end

function Signal:Connect(fn: (...any)->())
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        fn(...)
    end)
    return connection
end

function Signal:Fire(...)
    for _, connection in self._connection do
        if connection.Connected then
            task.spawn(connection._fn, ...)
        end
    end
end

function Signal:Wait()
    local thread = coroutine.running()
    self:Once(function(...)
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end

function Signal:Destroy()
    for _, connection in self._connections do
        connection.Connected = false
    end
    self._connection = {}
end

return Signal
