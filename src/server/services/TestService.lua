-- TestService.lua
-- A simple test service to verify Knit is working

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local TestService = Knit.CreateService({
    Name = "TestService",
    Client = {},
})

function TestService:KnitStart()
    print("[TestService] Service started!")
end

function TestService:KnitInit()
    print("[TestService] Service initialized!")
end

-- Server-side method
function TestService:GetMessage()
    return "Hello from TestService!"
end

-- Client-callable method
function TestService.Client:GetServerMessage(player)
    return self.Server:GetMessage()
end

return TestService
