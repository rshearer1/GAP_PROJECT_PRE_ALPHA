-- TestController.lua
-- A simple test controller to verify Knit is working

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local TestController = Knit.CreateController({
    Name = "TestController",
})

function TestController:KnitStart()
    print("[TestController] Controller started!")
    
    -- Get the TestService
    local TestService = Knit.GetService("TestService")
    
    -- Call a server method
    TestService:GetServerMessage():andThen(function(message)
        print("[TestController] Received from server:", message)
    end):catch(function(err)
        warn("[TestController] Error:", err)
    end)
end

function TestController:KnitInit()
    print("[TestController] Controller initialized!")
end

return TestController
