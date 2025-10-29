--[[
    PlotService.lua
    Server-side plot management for players
    
    Responsibilities:
    - Assign players to one of 8 pre-existing plots
    - Track which plots are occupied
    - Position planets above assigned plots
    - Handle plot cleanup when players leave
    
    GAP Compliance:
    - Uses Janitor for cleanup
    - References Constants.PLOT for all configuration values
    - JSDoc comments on all public methods
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Constants = require(ReplicatedStorage.Shared.Constants)

local PlotService = Knit.CreateService({
    Name = "PlotService",
    Client = {},
})

-- Store player plot assignments
PlotService._playerPlots = {} -- [userId] = plotNumber
PlotService._availablePlots = {} -- Array of available plot numbers (1-8)
PlotService._plotsFolder = nil
PlotService._janitor = Janitor.new()

local MAX_PLOTS = 8 -- Server capacity

--[[ Service Lifecycle ]]--

---
-- Initialize PlotService
--
function PlotService:KnitInit()
    print("[PlotService] Initializing...")
    
    -- Initialize available plots (all 8 are available at start)
    for i = 1, MAX_PLOTS do
        table.insert(self._availablePlots, i)
    end
    print(`[PlotService] Initialized {MAX_PLOTS} available plots`)
    
    -- Load plots from assets and place in Workspace
    local assetsFolder = ReplicatedStorage:FindFirstChild("Assets")
    print("[PlotService] Assets folder:", assetsFolder)
    
    if assetsFolder then
        local modelsFolder = assetsFolder:FindFirstChild("models")
        print("[PlotService] Models folder:", modelsFolder)
        
        if modelsFolder then
            local plotsModel = modelsFolder:FindFirstChild("Plots")
            print("[PlotService] Plots model:", plotsModel)
            
            if plotsModel then
                -- Clone the Plots folder to Workspace
                local plotsFolder = plotsModel:Clone()
                plotsFolder.Name = "PlayerPlots"
                plotsFolder.Parent = Workspace
                
                self._plotsFolder = plotsFolder
                print(`[PlotService] Loaded {#plotsFolder:GetChildren()} plots from assets`)
                
                -- List all plots
                for _, plot in ipairs(plotsFolder:GetChildren()) do
                    print(`[PlotService]   - {plot.Name}`)
                end
            else
                warn("[PlotService] Plots model not found in assets/models")
            end
        else
            warn("[PlotService] models folder not found in assets")
        end
    else
        warn("[PlotService] Assets folder not found in ReplicatedStorage")
    end
end

---
-- Start PlotService
-- Sets up player join/leave handlers
--
function PlotService:KnitStart()
    print("[PlotService] Starting...")
    
    -- Handle player joining
    self._janitor:Add(Players.PlayerAdded:Connect(function(player)
        self:_assignPlot(player)
    end), "Disconnect")
    
    -- Handle player leaving
    self._janitor:Add(Players.PlayerRemoving:Connect(function(player)
        self:_releasePlot(player.UserId)
    end), "Disconnect")
    
    -- Assign plots to existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:_assignPlot(player)
    end
    
    print("[PlotService] Started successfully!")
end

--[[ Private Methods ]]--

---
-- Assign a plot to a player
-- @param player Player - The player to assign a plot to
--
function PlotService:_assignPlot(player: Player)
    local userId = player.UserId
    
    -- Check if player already has a plot
    if self._playerPlots[userId] then
        warn(`[PlotService] Player {player.Name} already has plot {self._playerPlots[userId]}`)
        return
    end
    
    -- Check if there are available plots
    if #self._availablePlots == 0 then
        warn(`[PlotService] No available plots for {player.Name} - server is full!`)
        return
    end
    
    -- Get the first available plot number
    local plotNumber = table.remove(self._availablePlots, 1)
    
    -- Assign plot to player
    self._playerPlots[userId] = plotNumber
    
    -- Update plot label
    self:_updatePlotLabel(plotNumber, player.Name)
    
    -- Get plot position for planet spawning
    local plotPosition = self:_getPlotPosition(plotNumber)
    
    if plotPosition then
        -- Notify PlanetVisualsService to position planet on plot
        task.spawn(function()
            task.wait(0.5) -- Wait for planet to be created
            local PlanetVisualsService = Knit.GetService("PlanetVisualsService")
            if PlanetVisualsService then
                local planetHeight = Constants.PLOT.PLANET_HEIGHT or 20
                PlanetVisualsService:UpdatePlanetPosition(userId, plotPosition + Vector3.new(0, planetHeight, 0))
            end
        end)
    end
    
    print(`[PlotService] Assigned Plot{plotNumber} to {player.Name} ({#self._availablePlots} plots remaining)`)
end

---
-- Get the position of a plot's BasePart
-- @param plotNumber number - The plot number (1-8)
-- @return Vector3? - The position of the plot's BasePart
--
function PlotService:_getPlotPosition(plotNumber: number): Vector3?
    if not self._plotsFolder then
        warn("[PlotService] Plots folder not found")
        return nil
    end
    
    local plotName = `Plot{plotNumber}`
    local plot = self._plotsFolder:FindFirstChild(plotName)
    
    if not plot then
        warn(`[PlotService] {plotName} not found in plots folder`)
        return nil
    end
    
    -- Find the BasePart in the plot
    local basePart = plot:FindFirstChildWhichIsA("BasePart", true) -- Recursive search
    
    if basePart then
        return basePart.Position
    else
        warn(`[PlotService] No BasePart found in {plotName}`)
        return nil
    end
end

---
-- Update the label on a plot to show player name
-- @param plotNumber number - The plot number (1-8)
-- @param playerName string - The player's name
--
function PlotService:_updatePlotLabel(plotNumber: number, playerName: string)
    if not self._plotsFolder then return end
    
    local plotName = `Plot{plotNumber}`
    local plot = self._plotsFolder:FindFirstChild(plotName)
    
    if not plot then
        warn(`[PlotService] {plotName} not found for label update`)
        return
    end
    
    -- Find BasePart to attach label to
    local basePart = plot:FindFirstChildWhichIsA("BasePart", true)
    
    if not basePart then
        warn(`[PlotService] No BasePart found in {plotName} for label`)
        return
    end
    
    -- Remove existing label if any
    local existingLabel = basePart:FindFirstChild("PlayerNameLabel")
    if existingLabel then
        existingLabel:Destroy()
    end
    
    -- Create BillboardGui for player name
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerNameLabel"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = basePart
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = `{playerName}'s Plot`
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextSize = 24
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = billboard
    
    print(`[PlotService] Updated {plotName} label for {playerName}`)
end

---
-- Release a player's plot when they leave
-- @param userId number - The player's UserId
--
function PlotService:_releasePlot(userId: number)
    local plotNumber = self._playerPlots[userId]
    
    if not plotNumber then
        return
    end
    
    print(`[PlotService] Releasing Plot{plotNumber} from user {userId}`)
    
    -- Remove the player name label
    if self._plotsFolder then
        local plotName = `Plot{plotNumber}`
        local plot = self._plotsFolder:FindFirstChild(plotName)
        
        if plot then
            local basePart = plot:FindFirstChildWhichIsA("BasePart", true)
            if basePart then
                local label = basePart:FindFirstChild("PlayerNameLabel")
                if label then
                    label:Destroy()
                end
            end
        end
    end
    
    -- Add plot back to available pool
    table.insert(self._availablePlots, plotNumber)
    
    -- Remove from assignments
    self._playerPlots[userId] = nil
    
    print(`[PlotService] Plot{plotNumber} is now available ({#self._availablePlots} plots available)`)
end

--[[ Public Methods ]]--

---
-- Get a player's assigned plot number
-- @param userId number - The player's UserId
-- @return number? - The plot number (1-8) or nil
--
function PlotService:GetPlotNumber(userId: number): number?
    return self._playerPlots[userId]
end

---
-- Get the position for a player's plot
-- @param userId number - The player's UserId
-- @return Vector3? - The plot position
--
function PlotService:GetPlotPosition(userId: number): Vector3?
    local plotNumber = self._playerPlots[userId]
    
    if not plotNumber then
        return nil
    end
    
    return self:_getPlotPosition(plotNumber)
end

---
-- Get number of available plots
-- @return number - Number of available plots
--
function PlotService:GetAvailablePlotsCount(): number
    return #self._availablePlots
end

return PlotService
