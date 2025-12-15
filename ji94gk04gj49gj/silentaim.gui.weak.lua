local UIS = game:GetService("UserInputService")

if not game:IsLoaded() then 
    game.Loaded:Wait()
end

if not syn or not protectgui then
    getgenv().protectgui = function() end
end

if bypass_adonis then
    task.spawn(function()
        local g = getinfo or debug.getinfo
        local d = false
        local h = {}

        local x, y

        setthreadidentity(2)

        for i, v in getgc(true) do
            if typeof(v) == "table" then
                local a = rawget(v, "Detected")
                local b = rawget(v, "Kill")
            
                if typeof(a) == "function" and not x then
                    x = a
                    local o; o = hookfunction(x, function(c, f, n)
                        if c ~= "_" then
                            if d then
                            end
                        end
                        
                        return true
                    end)
                    table.insert(h, x)
                end

                if rawget(v, "Variables") and rawget(v, "Process") and typeof(b) == "function" and not y then
                    y = b
                    local o; o = hookfunction(y, function(f)
                        if d then
                        end
                    end)
                    table.insert(h, y)
                end
            end
        end

        local o; o = hookfunction(getrenv().debug.info, newcclosure(function(...)
            local a, f = ...

            if x and a == x then
                if d then
                    warn("zins | adonis bypassed")
                end

                return coroutine.yield(coroutine.running())
            end
            
            return o(...)
        end))

        setthreadidentity(7)
    end)
end

if not getgenv().ScriptState then
    getgenv().ScriptState = {
        targetPlayer = nil,
        previousHighlight = nil,
        lockedTime = 12,
        reverseResolveIntensity = 5,
        Desync = false,
        DesyncEnabled = false,
        fovEnabled = false,
        nebulaEnabled = false,
        fovValue = 70,
        SelfChamsEnabled = false,
        RainbowChamsEnabled = false,
        SelfChamsColor = Color3.fromRGB(255, 255, 255),
        ChamsEnabled = false,
        isSpeedActive = false,
        isFlyActive = false,
        isNoClipActive = false,
        isFunctionalityEnabled = true,
        flySpeed = 1,
        Cmultiplier = 1,
        strafeEnabled = false,
        strafeAllowed = true,
        strafeSpeed = 50,
        strafeRadius = 5,
        strafeMode = "Horizontal",
        originalCameraMode = nil
    }
end

local SilentAimSettings = {
    Enabled = false,
    ClassName = "PasteWare  |  github.com/FakeAngles",
    MenuKey = Enum.KeyCode.End,
    TeamCheck = false,
    TargetPart = "HumanoidRootPart",
    SilentAimMethod = "Auto",
    FOVRadius = 130,
    FOVVisible = false,
    ShowSilentAimTarget = false,
    HitChance = 100,
    BulletTP = false,
    CheckForFireFunc = false,
    BlockedMethods = {},
    Include = {},
    Origin = {"Camera"},
    MultiplyUnitBy = 1,
    FOVColor = Color3.fromRGB(100, 140, 255),
    TargetHighlightColor = Color3.fromRGB(100, 180, 255),
    IgnoredPlayers = {},
    HitSound = "Neverlose",
    HitSoundEnabled = true,
    ClosestPlayerMode = false
}

getgenv().SilentAimSettings = SilentAimSettings

local Options, Toggles = {}, {}

local function getToggleValue(name)
    local toggle = Toggles[name]
    return toggle and toggle.Value or false
end

local function setToggleValue(name, value)
    local toggle = Toggles[name]
    if toggle and toggle.SetValue then
        toggle:SetValue(value)
    end
end

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function logStage(stage, ...)
    warn(string.format("[PasteWare][%s]", stage), ...)
end

logStage("Init", "environment ready")

local GetChildren = game.GetChildren
local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local FindFirstChild = game.FindFirstChild
local RenderStepped = RunService.RenderStepped
local GuiInset = GuiService.GetGuiInset
local GetMouseLocation = UserInputService.GetMouseLocation

local resume = coroutine.resume 
local create = coroutine.create

local ValidTargetParts = {"Head", "HumanoidRootPart"}
local PredictionAmount = 0.165

local NPCConfig = {
    Enabled = false,
    OneFolderOnly = false,
    Path = "",
    ScanInterval = 4,
}

local NPCTargets = {}

local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 2
fov_circle.NumSides = 120
fov_circle.Radius = 180
fov_circle.Filled = false
fov_circle.Visible = false
fov_circle.ZIndex = 999
fov_circle.Transparency = 0.4
fov_circle.Color = Color3.fromRGB(100, 140, 255)

local ExpectedArguments = {
    ViewportPointToRay = {
        ArgCountRequired = 2,
        Args = { "number", "number" }
    },
    ScreenPointToRay = {
        ArgCountRequired = 2,
        Args = { "number", "number" }
    },
    Raycast = {
        ArgCountRequired = 3,
        Args = { "Instance", "Vector3", "Vector3", "RaycastParams" }
    },
    FindPartOnRay = {
        ArgCountRequired = 2,
        Args = { "Ray", "Instance?", "boolean?", "boolean?" }
    },
    FindPartOnRayWithIgnoreList = {
        ArgCountRequired = 2,
        Args = { "Ray", "table", "boolean?", "boolean?" }
    },
    FindPartOnRayWithWhitelist = { 
        ArgCountRequired = 2,
        Args = { "Ray", "table", "boolean?" }
    }
}

function CalculateChance(Percentage)

    Percentage = math.floor(Percentage)


    local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100


    return chance <= Percentage / 100
end


local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then
        return false
    end

    for Pos, Argument in next, Args do
        local Expected = RayMethod.Args[Pos]
        if not Expected then
            break
        end

        local IsOptional = Expected:sub(-1) == "?"
        local BaseType = IsOptional and Expected:sub(1, -2) or Expected

        if typeof(Argument) == BaseType then
            Matches = Matches + 1
        elseif IsOptional and Argument == nil then
            Matches = Matches + 1
        end
    end

    return Matches >= RayMethod.ArgCountRequired
end

local function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

local function getMousePosition()
    return GetMouseLocation(UserInputService)
end

local function IsPlayerVisible(Player)
    local PlayerCharacter = Player.Character
    local LocalPlayerCharacter = LocalPlayer.Character
    if not (PlayerCharacter or LocalPlayerCharacter) then return end

    local desiredPart = SilentAimSettings.TargetPart == "Random" and "HumanoidRootPart" or SilentAimSettings.TargetPart
    local PlayerRoot = FindFirstChild(PlayerCharacter, desiredPart) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    if not PlayerRoot then return end

    local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
    local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)
    return ObscuringObjects == 0
end

local function isNPCModel(model)
    if not model or not model:IsA("Model") then
        return false
    end
    if Players:GetPlayerFromCharacter(model) then
        return false
    end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    local rootPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return false
    end
    return true, humanoid, rootPart
end

local function scanNPCsFromRoot(root)
    local targets = {}
    if root then
        -- 先检查根本身是不是 NPC Model（例如 workspace.NPCSPAWN.NPC1）
        if root:IsA("Model") then
            local okRoot, humanoidRoot, rootPartRoot = isNPCModel(root)
            if okRoot then
                targets[root] = {
                    Model = root,
                    Humanoid = humanoidRoot,
                    Root = rootPartRoot
                }
            end
        end

        local stack = {root}
        while #stack > 0 do
            local current = table.remove(stack)
            for _, child in ipairs(current:GetChildren()) do
                table.insert(stack, child)
                if child:IsA("Model") then
                    local ok, humanoid, rootPart = isNPCModel(child)
                    if ok then
                        targets[child] = {
                            Model = child,
                            Humanoid = humanoid,
                            Root = rootPart
                        }
                    end
                end
            end
        end
    end
    NPCTargets = targets
end

local function resolvePath(path)
    if not path or path == "" then
        return workspace
    end
    path = tostring(path)
    path = path:gsub("^%s+", ""):gsub("%s+$", "")
    if path == "" then
        return workspace
    end
    local current
    for token in string.gmatch(path, "[^%.]+") do
        if not current then
            if token == "workspace" or token == "Workspace" then
                current = workspace
            elseif token == "game" then
                current = game
            else
                current = workspace:FindFirstChild(token)
            end
        else
            current = current:FindFirstChild(token)
        end
        if not current then
            break
        end
    end
    return current
end

task.spawn(function()
    while true do
        if NPCConfig.Enabled then
            if NPCConfig.OneFolderOnly then
                local root = resolvePath(NPCConfig.Path)
                if root then
                    scanNPCsFromRoot(root)
                else
                    NPCTargets = {}
                end
            else
                scanNPCsFromRoot(workspace)
            end
        else
            NPCTargets = {}
        end
        task.wait(NPCConfig.ScanInterval)
    end
end)

local function getClosestPlayerNoFOV()
    if not SilentAimSettings.TargetPart then return end
    local Closest
    local ClosestDistance = math.huge
    local ignoredPlayers = SilentAimSettings.IgnoredPlayers or {}
    local LocalCharacter = LocalPlayer.Character
    if not LocalCharacter then return end
    local LocalRoot = LocalCharacter:FindFirstChild("HumanoidRootPart")
    if not LocalRoot then return end
    local LocalPosition = LocalRoot.Position

    local function considerPartByDistance(part)
        if not part then return end
        local distance = (part.Position - LocalPosition).Magnitude
        if distance < ClosestDistance then
            Closest = part
            ClosestDistance = distance
        end
    end

    if NPCConfig.Enabled then
        for model, info in pairs(NPCTargets) do
            local humanoid = info.Humanoid
            local rootPart = info.Root
            if model and humanoid and rootPart and humanoid.Health > 0 and model.Parent then
                local desiredPartName = SilentAimSettings.TargetPart == "Random" and "HumanoidRootPart" or SilentAimSettings.TargetPart
                local targetPart = model:FindFirstChild(desiredPartName) or rootPart
                considerPartByDistance(targetPart)
            end
        end
    else
        for _, Player in next, GetPlayers(Players) do
            if Player == LocalPlayer then continue end
            if ignoredPlayers[Player.Name] then continue end
            if SilentAimSettings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
            local Character = Player.Character
            if not Character then continue end
            local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
            local Humanoid = FindFirstChild(Character, "Humanoid")
            if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then continue end

            local partToUse
            if SilentAimSettings.TargetPart == "Random" then
                partToUse = Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]
            else
                partToUse = Character[SilentAimSettings.TargetPart]
            end
            partToUse = partToUse or HumanoidRootPart
            considerPartByDistance(partToUse)
        end
    end
    return Closest
end

local function getClosestPlayer()
    if SilentAimSettings.ClosestPlayerMode and SilentAimSettings.Enabled then
        return getClosestPlayerNoFOV()
    end
    
    if not SilentAimSettings.TargetPart then return end
    local Closest
    local DistanceToMouse
    local ignoredPlayers = SilentAimSettings.IgnoredPlayers or {}
    local radius = SilentAimSettings.FOVRadius or 2000

    local function considerPart(part)
        if not part then
            return
        end
        local ScreenPosition, OnScreen = getPositionOnScreen(part.Position)
        if not OnScreen then
            return
        end
        local Distance = (getMousePosition() - ScreenPosition).Magnitude
        if Distance <= (DistanceToMouse or radius) then
            Closest = part
            DistanceToMouse = Distance
        end
    end

    if NPCConfig.Enabled then
        for model, info in pairs(NPCTargets) do
            local humanoid = info.Humanoid
            local rootPart = info.Root
            if model and humanoid and rootPart and humanoid.Health > 0 and model.Parent then
                local desiredPartName = SilentAimSettings.TargetPart == "Random" and "HumanoidRootPart" or SilentAimSettings.TargetPart
                local targetPart = model:FindFirstChild(desiredPartName) or rootPart
                considerPart(targetPart)
            end
        end
    else
        for _, Player in next, GetPlayers(Players) do
            if Player == LocalPlayer then continue end
            if ignoredPlayers[Player.Name] then continue end
            if SilentAimSettings.TeamCheck and Player.Team == LocalPlayer.Team then continue end
            local Character = Player.Character
            if not Character then continue end
            local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
            local Humanoid = FindFirstChild(Character, "Humanoid")
            if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then continue end

            local partToUse
            if SilentAimSettings.TargetPart == "Random" then
                partToUse = Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]
            else
                partToUse = Character[SilentAimSettings.TargetPart]
            end
            partToUse = partToUse or HumanoidRootPart

            considerPart(partToUse)
        end
    end
    return Closest
end

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local function isMobileDevice()
    local touchEnabled = UserInputService.TouchEnabled
    local keyboardEnabled = UserInputService.KeyboardEnabled
    local mouseEnabled = UserInputService.MouseEnabled
    return touchEnabled and not keyboardEnabled and not mouseEnabled
end

local IsMobile = isMobileDevice()

local GUI_SCALE = IsMobile and 0.7 or 1.0
local GUI_WIDTH = IsMobile and 600 or 860
local GUI_HEIGHT = IsMobile and 420 or 560

local function createScreenGui()
    logStage("CreateScreenGui", "start")
    local gui = Instance.new("ScreenGui")
    gui.Name = "PasteWareModernUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 100
    protectgui(gui)
    local success = pcall(function()
        gui.Parent = CoreGui
    end)
    if not success then
        local parent = nil
        if typeof(gethui) == "function" then
            parent = gethui()
        end
        if not parent then
            parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        end
        gui.Parent = parent or CoreGui
    end
    logStage("CreateScreenGui", "parent", gui.Parent)
    return gui
end

local function makeDraggable(dragHandle, target)
    local dragging = false
    local dragStart, startPos
    local activeTouchId = nil
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            if input.UserInputType == Enum.UserInputType.Touch then
                activeTouchId = input
            end
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    activeTouchId = nil
                    if conn then
                        conn:Disconnect()
                    end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if input.UserInputType == Enum.UserInputType.Touch and activeTouchId and input ~= activeTouchId then
                    return
                end
                local delta = input.Position - dragStart
                target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

local openDropdowns, activeColorPicker = {}, nil

local function normalizeKey(value)
    if typeof(value) == "EnumItem" then
        local enumTypeStr = tostring(value.EnumType)
        if enumTypeStr == "Enum.KeyCode" then
            return value
        elseif enumTypeStr == "Enum.UserInputType" then
            local ok, key = pcall(function()
                return Enum.KeyCode[value.Name]
            end)
            if ok and key then
                return key
            end
        end
    elseif type(value) == "string" then
        local str = value
        str = str:gsub("^%s+", ""):gsub("%s+$", "")
        str = str:gsub("^Enum%.KeyCode%.", "")
        str = str:gsub("^KeyCode%.", "")
        local ok, key = pcall(function()
            return Enum.KeyCode[str]
        end)
        if ok and key then
            return key
        end
        ok, key = pcall(function()
            return Enum.KeyCode[str:upper()]
        end)
        if ok and key then
            return key
        end
        local formatted = str:sub(1, 1):upper() .. str:sub(2):lower()
        ok, key = pcall(function()
            return Enum.KeyCode[formatted]
        end)
        if ok and key then
            return key
        end
    end
    return Enum.KeyCode.Unknown
end

local function keyToText(key)
    if typeof(key) == "EnumItem" and tostring(key.EnumType) == "Enum.KeyCode" then
        if key.Name == "Unknown" then
            return "None"
        end
        return key.Name
    end
    return tostring(key)
end

-- 统一关闭所有主要功能，供删除 GUI 按钮调用
local function disableAllFeatures()
    local ids = {
        "Master_SilentAim", "aim_Enabled",
        "Master_FOVCircle", "Visible",
        "desyncMasterEnabled", "desyncEnabled",
        "functionalityEnabled", "speedEnabled", "flyEnabled", "noClipEnabled",
        "strafeControlToggle", "strafeToggle",
        "fov_toggle", "nebula_theme",
        "MousePosition",
        "NPC_Enabled", "NPC_OneFolderOnly",
    }
    for _, id in ipairs(ids) do
        pcall(setToggleValue, id, false)
    end

    -- 再直接写状态，确保全部关闭
    SilentAimSettings.Enabled = false
    SilentAimSettings.FOVVisible = false
    SilentAimSettings.ShowSilentAimTarget = false
    if fov_circle then
        fov_circle.Visible = false
    end

    if ScriptState then
        ScriptState.Desync = false
        ScriptState.DesyncEnabled = false
        ScriptState.isSpeedActive = false
        ScriptState.isFlyActive = false
        ScriptState.isNoClipActive = false
        ScriptState.isFunctionalityEnabled = false
        ScriptState.strafeEnabled = false
        ScriptState.strafeAllowed = false
        ScriptState.fovEnabled = false
        ScriptState.nebulaEnabled = false
    end

    -- 尽量还原部分世界效果（移除 Nebula 特效）
    local lighting = game:GetService("Lighting")
    for _, v in pairs({"NebulaBloom", "NebulaColorCorrection", "NebulaAtmosphere"}) do
        local obj = lighting:FindFirstChild(v)
        if obj then obj:Destroy() end
    end
    NPCConfig.Enabled = false
    NPCTargets = {}
end

local function closeDropdowns()
    for dropdown, frame in pairs(openDropdowns) do
        frame.Visible = false
        openDropdowns[dropdown] = nil
    end
    activeColorPicker = nil
end

-- 只在鼠标左键点击空白区域时关闭下拉框/颜色选择器，不再处理任何键盘热键
UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gpe then
        if not activeColorPicker then
            closeDropdowns()
        end
    end
end)

local function createSliderUI(parent, min, max, rounding)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.38, 0, 0, 8)
    sliderFrame.Position = UDim2.new(0.58, 0, 0.5, -4)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = parent

    local corner = Instance.new("UICorner", sliderFrame)
    corner.CornerRadius = UDim.new(0.5, 0)

    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = Color3.fromRGB(100, 140, 255)
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(0, 0, 1, 0)
    bar.ZIndex = 2
    bar.Parent = sliderFrame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0.5, 0)
    
    -- 圆形手柄
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, 8, 0.5, -10)
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 13
    valueLabel.TextColor3 = Color3.fromRGB(180, 190, 255)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = sliderFrame

    local slider = {Frame = sliderFrame, Bar = bar, Knob = knob, ValueLabel = valueLabel, Min = min, Max = max, Rounding = rounding or 0}
    return slider
end

local function formatNumber(value, rounding)
    local mult = 10 ^ (rounding or 0)
    return math.floor(value * mult + 0.5) / mult
end

local function createDropdownMenu(button)
    local holder = Instance.new("ScrollingFrame")
    holder.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
    holder.BorderSizePixel = 0
    holder.Visible = false
    holder.ZIndex = 100
    holder.Position = UDim2.new(0, 0, 1, 8)
    holder.Size = UDim2.new(1, 0, 0, 150)
    holder.CanvasSize = UDim2.new(0, 0, 0, 0)
    pcall(function()
        holder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    end)
    holder.ScrollBarThickness = 3
    holder.ScrollBarImageColor3 = Color3.fromRGB(100, 120, 200)
    holder.ScrollingDirection = Enum.ScrollingDirection.Y
    holder.Parent = button

    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)
    
    local holderPadding = Instance.new("UIPadding", holder)
    holderPadding.PaddingTop = UDim.new(0, 6)
    holderPadding.PaddingBottom = UDim.new(0, 6)
    holderPadding.PaddingLeft = UDim.new(0, 6)
    holderPadding.PaddingRight = UDim.new(0, 6)

    local list = Instance.new("UIListLayout", holder)
    list.Padding = UDim.new(0, 4)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    return holder
end

local Library = {}
Library.__index = Library

function Library:SetVisible(state)
    self.Visible = state
    if self.Gui then
        self.Gui.Enabled = state ~= false
    end
    if self.MainFrame then
        self.MainFrame.Visible = state ~= false
    end
end

function Library:ToggleVisibility()
    self:SetVisible(not self.Visible)
end

function Library:SetToggleKey(key)
    self.ToggleKey = normalizeKey(key or Enum.KeyCode.End)
end

function Library:SetCollapsed(state)
    self.Collapsed = state and true or false
    local showContent = not self.Collapsed
    if self.TabContainer then
        self.TabContainer.Visible = showContent
    end
    if self.ContentHolder then
        self.ContentHolder.Visible = showContent
    end
    if self.CollapseButton then
        self.CollapseButton.Text = self.Collapsed and "+" or "-"
    end
    if self.MainFrame then
        local targetSize
        if self.Collapsed then
            targetSize = self.CollapsedSize or self.MainFrame.Size
        else
            targetSize = self.ExpandedSize or self.MainFrame.Size
        end
        if targetSize then
            self.MainFrame.Size = targetSize
        end
    end
end

function Library:ToggleCollapse()
    self:SetCollapsed(not self.Collapsed)
end

function Library:Unload()
    if self.Connections then
        for _, conn in ipairs(self.Connections) do
            if conn.Disconnect then
                conn:Disconnect()
            end
        end
        self.Connections = {}
    end
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
        self.MainFrame = nil
    end
end

function Library:CreateWindow(config)
    local window = setmetatable({}, Library)
    window.Gui = createScreenGui()
    window.Connections = {}
    window:SetToggleKey(config.ToggleKey or Enum.KeyCode.End)

    table.insert(window.Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if window.ToggleKey and input.KeyCode == window.ToggleKey then
            window:ToggleVisibility()
        end
    end))

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
    main.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    main.BackgroundTransparency = 0.08
    main.BorderSizePixel = 0
    main.Parent = window.Gui
    window.MainFrame = main
    window.ExpandedSize = main.Size
    window.CollapsedSize = UDim2.new(0, GUI_WIDTH, 0, 60)
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 52)
    topbar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    topbar.BackgroundTransparency = 0.1
    topbar.BorderSizePixel = 0
    topbar.Parent = main
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 14)
    
    -- 顶部渐变装饰线
    local topAccent = Instance.new("Frame")
    topAccent.Size = UDim2.new(1, -40, 0, 2)
    topAccent.Position = UDim2.new(0, 20, 1, -2)
    topAccent.BackgroundColor3 = Color3.fromRGB(100, 130, 255)
    topAccent.BackgroundTransparency = 0.5
    topAccent.BorderSizePixel = 0
    topAccent.Parent = topbar
    Instance.new("UICorner", topAccent).CornerRadius = UDim.new(0, 1)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 20, 0, 0)
    title.Size = UDim2.new(0.5, 0, 1, -2)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = config.Title or "PasteWare"
    title.Parent = topbar

    local collapseButton = Instance.new("TextButton")
    collapseButton.Size = UDim2.new(0, 36, 0, 36)
    collapseButton.Position = UDim2.new(1, -90, 0.5, -18)
    collapseButton.BackgroundColor3 = Color3.fromRGB(50, 55, 80)
    collapseButton.BackgroundTransparency = 0
    collapseButton.TextColor3 = Color3.fromRGB(200, 210, 255)
    collapseButton.Font = Enum.Font.GothamBold
    collapseButton.TextSize = 20
    collapseButton.Text = "−"
    collapseButton.BorderSizePixel = 0
    collapseButton.Parent = topbar
    Instance.new("UICorner", collapseButton).CornerRadius = UDim.new(0, 10)
    
    -- 折叠按钮悬停效果（简化）
    collapseButton.MouseEnter:Connect(function()
        collapseButton.BackgroundColor3 = Color3.fromRGB(70, 80, 120)
    end)
    collapseButton.MouseLeave:Connect(function()
        collapseButton.BackgroundColor3 = Color3.fromRGB(50, 55, 80)
    end)

    local deleteButton = Instance.new("TextButton")
    deleteButton.Size = UDim2.new(0, 36, 0, 36)
    deleteButton.Position = UDim2.new(1, -46, 0.5, -18)
    deleteButton.BackgroundColor3 = Color3.fromRGB(120, 45, 60)
    deleteButton.BackgroundTransparency = 0
    deleteButton.TextColor3 = Color3.fromRGB(255, 200, 210)
    deleteButton.Font = Enum.Font.GothamBold
    deleteButton.TextSize = 18
    deleteButton.Text = "✕"
    deleteButton.BorderSizePixel = 0
    deleteButton.Parent = topbar
    Instance.new("UICorner", deleteButton).CornerRadius = UDim.new(0, 10)
    
    -- 关闭按钮悬停效果（简化）
    deleteButton.MouseEnter:Connect(function()
        deleteButton.BackgroundColor3 = Color3.fromRGB(180, 60, 80)
    end)
    deleteButton.MouseLeave:Connect(function()
        deleteButton.BackgroundColor3 = Color3.fromRGB(120, 45, 60)
    end)

    window.CollapseButton = collapseButton

    collapseButton.MouseButton1Click:Connect(function()
        window:ToggleCollapse()
    end)

    deleteButton.MouseButton1Click:Connect(function()
        pcall(disableAllFeatures)
        window:Unload()
    end)

    makeDraggable(topbar, main)

    local tabButtons = Instance.new("Frame")
    tabButtons.Size = UDim2.new(0, 160, 1, -52)
    tabButtons.Position = UDim2.new(0, 0, 0, 52)
    tabButtons.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    tabButtons.BackgroundTransparency = 0.15
    tabButtons.BorderSizePixel = 0
    tabButtons.ClipsDescendants = true
    tabButtons.Parent = main
    Instance.new("UICorner", tabButtons).CornerRadius = UDim.new(0, 14)
    window.TabContainer = tabButtons
    
    -- 侧边栏右侧分割线（放在main下，避免UIListLayout影响）
    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Size = UDim2.new(0, 1, 1, -72)
    sidebarDivider.Position = UDim2.new(0, 160, 0, 62)
    sidebarDivider.BackgroundColor3 = Color3.fromRGB(60, 70, 120)
    sidebarDivider.BackgroundTransparency = 0.7
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.Parent = main

    local buttonLayout = Instance.new("UIListLayout", tabButtons)
    buttonLayout.Padding = UDim.new(0, 6)
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local tabPadding = Instance.new("UIPadding", tabButtons)
    tabPadding.PaddingTop = UDim.new(0, 10)
    tabPadding.PaddingLeft = UDim.new(0, 10)
    tabPadding.PaddingRight = UDim.new(0, 10)

    local contentHolder = Instance.new("Frame")
    contentHolder.Size = UDim2.new(1, -165, 1, -56)
    contentHolder.Position = UDim2.new(0, 163, 0, 54)
    contentHolder.BackgroundTransparency = 1
    contentHolder.Parent = main
    window.ContentHolder = contentHolder

    window.Tabs = {}
    window.ActiveTab = nil
    window.Collapsed = false

    function window:SelectTab(tab)
        if self.ActiveTab == tab then return end
        if self.ActiveTab then
            local oldBtn = self.ActiveTab.Button
            oldBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
            oldBtn.TextTransparency = 0.3
            if oldBtn:FindFirstChild("TabIndicator") then
                oldBtn.TabIndicator.BackgroundTransparency = 1
            end
            self.ActiveTab.Content.Visible = false
        end
        self.ActiveTab = tab
        tab.Content.Visible = true
        tab.Button.BackgroundColor3 = Color3.fromRGB(70, 90, 180)
        tab.Button.TextTransparency = 0
        if tab.Button:FindFirstChild("TabIndicator") then
            tab.Button.TabIndicator.BackgroundTransparency = 0
        end
    end

    function window:AddTab(name)
        local tab = {}
        tab.Button = Instance.new("TextButton")
        tab.Button.Size = UDim2.new(1, -4, 0, 42)
        tab.Button.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
        tab.Button.TextColor3 = Color3.fromRGB(220, 225, 255)
        tab.Button.Font = Enum.Font.GothamSemibold
        tab.Button.TextSize = 15
        tab.Button.Text = name
        tab.Button.TextTransparency = 0.3
        tab.Button.Parent = tabButtons
        Instance.new("UICorner", tab.Button).CornerRadius = UDim.new(0, 10)
        
        -- 标签按钮左侧指示器
        local tabIndicator = Instance.new("Frame")
        tabIndicator.Name = "TabIndicator"
        tabIndicator.Size = UDim2.new(0, 3, 0.6, 0)
        tabIndicator.Position = UDim2.new(0, 0, 0.2, 0)
        tabIndicator.BackgroundColor3 = Color3.fromRGB(120, 140, 255)
        tabIndicator.BackgroundTransparency = 1
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Parent = tab.Button
        Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(0, 2)
        
        -- 悬停效果（简化）
        tab.Button.MouseEnter:Connect(function()
            if window.ActiveTab ~= tab then
                tab.Button.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
            end
        end)
        tab.Button.MouseLeave:Connect(function()
            if window.ActiveTab ~= tab then
                tab.Button.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
            end
        end)

        tab.Content = Instance.new("ScrollingFrame")
        tab.Content.BackgroundTransparency = 1
        tab.Content.BorderSizePixel = 0
        tab.Content.Visible = false
        tab.Content.Size = UDim2.new(1, 0, 1, 0)
        tab.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
        pcall(function()
            tab.Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        end)
        tab.Content.ScrollBarThickness = 5
        tab.Content.ScrollingDirection = Enum.ScrollingDirection.Y
        tab.Content.Parent = contentHolder

        local leftColumn = Instance.new("Frame")
        leftColumn.BackgroundTransparency = 1
        leftColumn.AutomaticSize = Enum.AutomaticSize.Y
        leftColumn.Size = UDim2.new(0.5, -8, 0, 0)
        leftColumn.Position = UDim2.new(0, 0, 0, 0)
        leftColumn.Parent = tab.Content
        local leftLayout = Instance.new("UIListLayout", leftColumn)
        leftLayout.Padding = UDim.new(0, 10)
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local rightColumn = Instance.new("Frame")
        rightColumn.BackgroundTransparency = 1
        rightColumn.AutomaticSize = Enum.AutomaticSize.Y
        rightColumn.Size = UDim2.new(0.5, -8, 0, 0)
        rightColumn.Position = UDim2.new(0.5, 8, 0, 0)
        rightColumn.Parent = tab.Content
        local rightLayout = Instance.new("UIListLayout", rightColumn)
        rightLayout.Padding = UDim.new(0, 10)
        rightLayout.SortOrder = Enum.SortOrder.LayoutOrder

        tab.LeftColumn = leftColumn
        tab.RightColumn = rightColumn

        tab.Button.MouseButton1Click:Connect(function()
            window:SelectTab(tab)
        end)

        table.insert(window.Tabs, tab)
        if not window.ActiveTab then
            window:SelectTab(tab)
        end

        local function createGroupbox(parent, title)
            local box = {}
            box.Frame = Instance.new("Frame")
            box.Frame.BackgroundColor3 = Color3.fromRGB(22, 24, 35)
            box.Frame.BackgroundTransparency = 0.15
            box.Frame.BorderSizePixel = 0
            box.Frame.AutomaticSize = Enum.AutomaticSize.Y
            box.Frame.Size = UDim2.new(1, 0, 0, 0)
            box.Frame.Parent = parent
            Instance.new("UICorner", box.Frame).CornerRadius = UDim.new(0, 12)
            
            -- 分组框内边距
            local boxPadding = Instance.new("UIPadding", box.Frame)
            boxPadding.PaddingBottom = UDim.new(0, 12)

            local header = Instance.new("TextLabel")
            header.BackgroundTransparency = 1
            header.Font = Enum.Font.GothamBold
            header.TextSize = 14
            header.TextColor3 = Color3.fromRGB(180, 190, 255)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Text = title
            header.Size = UDim2.new(1, -24, 0, 28)
            header.Position = UDim2.new(0, 12, 0, 8)
            header.Parent = box.Frame
            
            -- 标题下划线
            local headerLine = Instance.new("Frame")
            headerLine.Size = UDim2.new(1, -24, 0, 1)
            headerLine.Position = UDim2.new(0, 12, 0, 34)
            headerLine.BackgroundColor3 = Color3.fromRGB(60, 70, 120)
            headerLine.BackgroundTransparency = 0.6
            headerLine.BorderSizePixel = 0
            headerLine.Parent = box.Frame

            local content = Instance.new("Frame")
            content.BackgroundTransparency = 1
            content.AutomaticSize = Enum.AutomaticSize.Y
            content.Position = UDim2.new(0, 12, 0, 42)
            content.Size = UDim2.new(1, -24, 0, 0)
            content.Parent = box.Frame

            local layout = Instance.new("UIListLayout", content)
            layout.Padding = UDim.new(0, 8)
            layout.SortOrder = Enum.SortOrder.LayoutOrder

            local function createRow(height)
                local row = Instance.new("Frame")
                row.BackgroundColor3 = Color3.fromRGB(32, 36, 52)
                row.BackgroundTransparency = 0.2
                row.BorderSizePixel = 0
                row.Size = UDim2.new(1, 0, 0, height or 40)
                row.Parent = content
                local corner = Instance.new("UICorner", row)
                corner.CornerRadius = UDim.new(0, 10)
                
                -- 行悬停效果（简化）
                row.MouseEnter:Connect(function()
                    row.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
                end)
                row.MouseLeave:Connect(function()
                    row.BackgroundColor3 = Color3.fromRGB(32, 36, 52)
                end)
                return row
            end

            function box:AddToggle(id, data)
                local row = createRow()
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextColor3 = Color3.fromRGB(210, 215, 235)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Text = data.Text or id
                label.Size = UDim2.new(0.65, 0, 1, 0)
                label.Position = UDim2.new(0, 14, 0, 0)
                label.Parent = row

                -- 现代滑动开关容器
                local switchContainer = Instance.new("Frame")
                switchContainer.Size = UDim2.new(0, 52, 0, 26)
                switchContainer.Position = UDim2.new(1, -66, 0.5, -13)
                switchContainer.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
                switchContainer.BorderSizePixel = 0
                switchContainer.Parent = row
                Instance.new("UICorner", switchContainer).CornerRadius = UDim.new(0.5, 0)
                
                -- 滑块圆圈
                local switchKnob = Instance.new("Frame")
                switchKnob.Size = UDim2.new(0, 20, 0, 20)
                switchKnob.Position = UDim2.new(0, 3, 0.5, -10)
                switchKnob.BackgroundColor3 = Color3.fromRGB(180, 185, 200)
                switchKnob.BorderSizePixel = 0
                switchKnob.Parent = switchContainer
                Instance.new("UICorner", switchKnob).CornerRadius = UDim.new(0.5, 0)
                
                -- 隐藏的点击按钮（支持触摸）
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 1, 0)
                button.BackgroundTransparency = 1
                button.Text = ""
                button.Active = true
                button.Parent = switchContainer

                local toggle = {Value = data.Default or false, Button = button, Label = label, Callback = data.Callback, Container = switchContainer, Knob = switchKnob}

                function toggle:SetValue(val)
                    self.Value = val
                    local targetPos = val and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
                    local targetBg = val and Color3.fromRGB(80, 160, 120) or Color3.fromRGB(50, 55, 75)
                    local targetKnob = val and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 185, 200)
                    
                    switchKnob.Position = targetPos
                    switchKnob.BackgroundColor3 = targetKnob
                    switchContainer.BackgroundColor3 = targetBg
                    
                    if self.Callback then
                        self.Callback(val)
                    end
                    if self.Changed then
                        self.Changed(val)
                    end
                end

                function toggle:OnChanged(callback)
                    self.Changed = callback
                    if callback then
                        callback(self.Value)
                    end
                    return self
                end

                -- 添加键位绑定
                -- 热键绑定 UI 已移除：保持接口但不再创建任何按钮或响应键盘
                function toggle:AddKeyPicker(id, cfg)
                    local dummy = {}
                    function dummy:SetValue(...) end
                    function dummy:OnClick(callback) return self end
                    function dummy:OnChanged(callback) return self end
                    return dummy
                end

                -- 添加颜色选择器
                function toggle:AddColorPicker(id, cfg)
                    -- 为带颜色的开关重新调整布局：颜色按钮在开关左边
                    switchContainer.Position = UDim2.new(1, -66, 0.5, -13)

                    local colorButton = Instance.new("TextButton")
                    colorButton.Size = UDim2.new(0, 28, 0, 28)
                    colorButton.Position = UDim2.new(1, -100, 0.5, -14)
                    colorButton.BorderSizePixel = 0
                    colorButton.Parent = row
                    colorButton.Text = ""
                    colorButton.BackgroundColor3 = (cfg and cfg.Default) or Color3.new(1, 1, 1)
                    Instance.new("UICorner", colorButton).CornerRadius = UDim.new(0, 8)

                    local pickerFrame = Instance.new("Frame")
                    pickerFrame.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
                    pickerFrame.Size = UDim2.new(0, 140, 0, 100)
                    pickerFrame.Position = UDim2.new(1, 8, 0, -20)
                    pickerFrame.Visible = false
                    pickerFrame.ZIndex = 15
                    pickerFrame.Parent = colorButton
                    Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 12)

                    local colorInput = Instance.new("TextBox")
                    colorInput.Size = UDim2.new(1, -16, 0, 32)
                    colorInput.Position = UDim2.new(0, 8, 0, 10)
                    colorInput.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
                    colorInput.BorderSizePixel = 0
                    colorInput.Text = "255, 255, 255"
                    colorInput.TextColor3 = Color3.fromRGB(220, 230, 255)
                    colorInput.PlaceholderColor3 = Color3.fromRGB(120, 130, 160)
                    colorInput.PlaceholderText = "R, G, B"
                    colorInput.Font = Enum.Font.GothamSemibold
                    colorInput.TextSize = 13
                    colorInput.ZIndex = 16
                    colorInput.Parent = pickerFrame
                    Instance.new("UICorner", colorInput).CornerRadius = UDim.new(0, 8)

                    local confirm = Instance.new("TextButton")
                    confirm.Size = UDim2.new(1, -16, 0, 34)
                    confirm.Position = UDim2.new(0, 8, 0, 52)
                    confirm.Text = "✔ Apply"
                    confirm.Font = Enum.Font.GothamBold
                    confirm.TextSize = 13
                    confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
                    confirm.BackgroundColor3 = Color3.fromRGB(70, 100, 180)
                    confirm.BorderSizePixel = 0
                    confirm.ZIndex = 16
                    confirm.Parent = pickerFrame
                    Instance.new("UICorner", confirm).CornerRadius = UDim.new(0, 8)
                    
                    -- 确认按钮悬停效果（简化）
                    confirm.MouseEnter:Connect(function()
                        confirm.BackgroundColor3 = Color3.fromRGB(90, 130, 220)
                    end)
                    confirm.MouseLeave:Connect(function()
                        confirm.BackgroundColor3 = Color3.fromRGB(70, 100, 180)
                    end)

                    local picker = {Value = (cfg and cfg.Default) or Color3.new(1, 1, 1)}

                    local function applyColor(color, silent)
                        picker.Value = color
                        colorButton.BackgroundColor3 = color
                        if not silent and picker.Changed then
                            picker.Changed(color)
                        end
                    end

                    confirm.MouseButton1Click:Connect(function()
                        local r, g, b = colorInput.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
                        r, g, b = tonumber(r), tonumber(g), tonumber(b)
                        if r and g and b then
                            r = math.clamp(r, 0, 255)
                            g = math.clamp(g, 0, 255)
                            b = math.clamp(b, 0, 255)
                            applyColor(Color3.fromRGB(r, g, b))
                            pickerFrame.Visible = false
                            openDropdowns[colorButton] = nil
                            activeColorPicker = nil
                        end
                    end)

                    colorButton.MouseButton1Click:Connect(function()
                        local visible = not pickerFrame.Visible
                        closeDropdowns()
                        pickerFrame.Visible = visible
                        if visible then
                            openDropdowns[colorButton] = pickerFrame
                            activeColorPicker = pickerFrame
                        else
                            openDropdowns[colorButton] = nil
                            activeColorPicker = nil
                        end
                    end)

                    function picker:SetValue(color)
                        applyColor(color, true)
                    end

                    function picker:OnChanged(callback)
                        picker.Changed = callback
                        callback(picker.Value)
                        return picker
                    end

                    applyColor(picker.Value, true)
                    Options[id] = picker
                    return picker
                end

                button.MouseButton1Click:Connect(function()
                    toggle:SetValue(not toggle.Value)
                end)

                toggle:SetValue(toggle.Value)
                Toggles[id] = toggle
                return toggle
            end

            function box:AddButton(text, callback)
                local row = createRow(44)
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, -20, 0, 34)
                button.Position = UDim2.new(0, 10, 0.5, -17)
                button.BackgroundColor3 = Color3.fromRGB(70, 95, 180)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.Font = Enum.Font.GothamBold
                button.TextSize = 14
                button.Text = text
                button.BorderSizePixel = 0
                button.Parent = row
                Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)
                
                -- 按钮悬停和点击效果（简化）
                button.MouseEnter:Connect(function()
                    button.BackgroundColor3 = Color3.fromRGB(90, 120, 220)
                end)
                button.MouseLeave:Connect(function()
                    button.BackgroundColor3 = Color3.fromRGB(70, 95, 180)
                end)
                button.MouseButton1Down:Connect(function()
                    button.BackgroundColor3 = Color3.fromRGB(50, 70, 140)
                end)
                button.MouseButton1Up:Connect(function()
                    button.BackgroundColor3 = Color3.fromRGB(90, 120, 220)
                end)
                
                button.MouseButton1Click:Connect(callback or function() end)
                return button
            end

            function box:AddInput(id, data)
                local row = createRow()
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextColor3 = Color3.fromRGB(210, 215, 235)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Text = data.Text or id
                label.Size = UDim2.new(0.55, 0, 1, 0)
                label.Position = UDim2.new(0, 14, 0, 0)
                label.Parent = row

                local boxInput = Instance.new("TextBox")
                boxInput.Size = UDim2.new(0.4, -10, 0, 28)
                boxInput.Position = UDim2.new(0.58, 0, 0.5, -14)
                boxInput.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
                boxInput.BorderSizePixel = 0
                boxInput.TextColor3 = Color3.fromRGB(220, 230, 255)
                boxInput.PlaceholderColor3 = Color3.fromRGB(120, 130, 160)
                boxInput.Font = Enum.Font.Gotham
                boxInput.TextSize = 13
                boxInput.Text = data.Default or ""
                boxInput.PlaceholderText = data.Placeholder or ""
                boxInput.Parent = row
                Instance.new("UICorner", boxInput).CornerRadius = UDim.new(0, 8)

                local input = {Value = boxInput.Text}

                function input:SetValue(val)
                    self.Value = val
                    boxInput.Text = tostring(val)
                end

                function input:OnChanged(callback)
                    input.Changed = callback
                    callback(self.Value)
                    return input
                end

                boxInput.FocusLost:Connect(function()
                    local value = boxInput.Text
                    if data.Numeric then
                        local num = tonumber(value)
                        if num then value = tostring(num) else value = input.Value end
                    end
                    input.Value = value
                    if input.Changed then input.Changed(value) end
                end)

                Options[id] = input
                return input
            end

            function box:AddSlider(id, data)
                local row = createRow(46)
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextColor3 = Color3.fromRGB(210, 215, 235)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Text = data.Text or id
                label.Size = UDim2.new(0.55, 0, 1, 0)
                label.Position = UDim2.new(0, 14, 0, 0)
                label.Parent = row

                local sliderUI = createSliderUI(row, data.Min, data.Max, data.Rounding)
                local slider = {Value = data.Default or data.Min, Min = data.Min, Max = data.Max, Rounding = data.Rounding, UI = sliderUI, Callback = data.Callback}

                local function updateSlider(value)
                    local percent = (value - slider.Min) / (slider.Max - slider.Min)
                    sliderUI.Bar.Size = UDim2.new(percent, 0, 1, 0)
                    sliderUI.ValueLabel.Text = tostring(formatNumber(value, slider.Rounding))
                end

                function slider:SetValue(val)
                    val = math.clamp(val, slider.Min, slider.Max)
                    val = formatNumber(val, slider.Rounding)
                    slider.Value = val
                    updateSlider(val)
                    if slider.Callback then slider.Callback(val) end
                    if slider.Changed then slider.Changed(val) end
                end

                function slider:OnChanged(callback)
                    slider.Changed = callback
                    callback(slider.Value)
                    return slider
                end

                sliderUI.Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local activeInput = input
                        local connection
                        connection = UserInputService.InputChanged:Connect(function(delta)
                            if delta.UserInputType == Enum.UserInputType.MouseMovement or delta.UserInputType == Enum.UserInputType.Touch then
                                if delta.UserInputType == Enum.UserInputType.Touch and delta ~= activeInput then
                                    return
                                end
                                local relativeX = math.clamp(delta.Position.X - sliderUI.Frame.AbsolutePosition.X, 0, sliderUI.Frame.AbsoluteSize.X)
                                local percent = relativeX / sliderUI.Frame.AbsoluteSize.X
                                local value = slider.Min + (slider.Max - slider.Min) * percent
                                slider:SetValue(value)
                            end
                        end)
                        input.Changed:Connect(function(property)
                            if property == "UserInputState" then
                                local state = input.UserInputState
                                if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                                    if connection then
                                        connection:Disconnect()
                                        connection = nil
                                    end
                                end
                            end
                        end)
                    end
                end)

                slider:SetValue(slider.Value)
                Options[id] = slider
                return slider
            end

            function box:AddDropdown(id, data)
                local row = createRow()
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextColor3 = Color3.fromRGB(210, 215, 235)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Text = data.Text or id
                label.Size = UDim2.new(0.55, 0, 1, 0)
                label.Position = UDim2.new(0, 14, 0, 0)
                label.Parent = row

                local button = Instance.new("TextButton")
                button.Size = UDim2.new(0.4, -10, 0, 28)
                button.Position = UDim2.new(0.58, 0, 0.5, -14)
                button.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
                button.TextColor3 = Color3.fromRGB(200, 210, 255)
                button.Font = Enum.Font.GothamSemibold
                button.TextSize = 13
                button.Text = "Select ▼"
                button.BorderSizePixel = 0
                button.ZIndex = 50
                button.Parent = row
                Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
                
                -- 下拉按钮悬停效果（简化）
                button.MouseEnter:Connect(function()
                    button.BackgroundColor3 = Color3.fromRGB(60, 70, 100)
                end)
                button.MouseLeave:Connect(function()
                    button.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
                end)

                local menu = createDropdownMenu(button)
                local dropdown = {Value = data.Default, Values = data.Values or {}, Multi = data.Multi, Holder = menu, Button = button, Callback = data.Callback}

                local function updateButtonText()
                    if dropdown.Multi then
                        local selected = {}
                        for value, state in pairs(dropdown.Selected or {}) do
                            if state then table.insert(selected, value) end
                        end
                        button.Text = (#selected > 0 and table.concat(selected, ", ") or "None")
                    else
                        button.Text = tostring(dropdown.Value or "Select")
                    end
                end

                local function rebuildMenu()
                    -- 保留 UIListLayout，只删除旧的选项按钮，避免选项堆叠
                    for _, child in ipairs(menu:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    local values = dropdown.Values
                    for _, value in ipairs(values) do
                        local option = Instance.new("TextButton")
                        option.Size = UDim2.new(1, 0, 0, 30)
                        option.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
                        option.TextColor3 = Color3.fromRGB(200, 210, 240)
                        option.Font = Enum.Font.Gotham
                        option.TextSize = 13
                        option.Text = tostring(value)
                        option.BorderSizePixel = 0
                        option.ZIndex = 101
                        option.Parent = menu
                        Instance.new("UICorner", option).CornerRadius = UDim.new(0, 8)
                        
                        -- 选项悬停效果（简化）
                        option.MouseEnter:Connect(function()
                            option.BackgroundColor3 = Color3.fromRGB(70, 90, 150)
                        end)
                        option.MouseLeave:Connect(function()
                            option.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
                        end)

                        option.MouseButton1Click:Connect(function()
                            if dropdown.Multi then
                                dropdown.Selected = dropdown.Selected or {}
                                dropdown.Selected[value] = not dropdown.Selected[value]
                                local list = {}
                                for key, state in pairs(dropdown.Selected) do
                                    if state then table.insert(list, key) end
                                end
                                dropdown.Value = list
                                updateButtonText()
                                if dropdown.Callback then dropdown.Callback(list) end
                                if dropdown.Changed then dropdown.Changed(list) end
                            else
                                dropdown.Value = value
                                updateButtonText()
                                menu.Visible = false
                                openDropdowns[button] = nil
                                if dropdown.Callback then dropdown.Callback(value) end
                                if dropdown.Changed then dropdown.Changed(value) end
                            end
                        end)
                    end
                end

                if data.SpecialType == "Player" then
                    local function refreshPlayers()
                        local playerNames = {}
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer then
                                table.insert(playerNames, plr.Name)
                            end
                        end
                        dropdown.Values = playerNames
                        rebuildMenu()
                    end
                    Players.PlayerAdded:Connect(refreshPlayers)
                    Players.PlayerRemoving:Connect(refreshPlayers)
                    refreshPlayers()
                else
                    rebuildMenu()
                end

                button.MouseButton1Click:Connect(function()
                    local visible = not menu.Visible
                    closeDropdowns()
                    menu.Visible = visible
                    if visible then
                        openDropdowns[button] = menu
                    end
                end)

                function dropdown:SetValue(val)
                    if dropdown.Multi then
                        dropdown.Selected = {}
                        dropdown.Value = {}
                        if type(val) == "table" then
                            for _, item in ipairs(val) do
                                dropdown.Selected[item] = true
                                table.insert(dropdown.Value, item)
                            end
                        end
                    else
                        dropdown.Value = val
                    end
                    updateButtonText()
                    if dropdown.Callback then dropdown.Callback(dropdown.Value) end
                    if dropdown.Changed then dropdown.Changed(dropdown.Value) end
                end

                function dropdown:OnChanged(callback)
                    dropdown.Changed = callback
                    if dropdown.Value ~= nil then
                        callback(dropdown.Value)
                    end
                    return dropdown
                end

                updateButtonText()
                Options[id] = dropdown
                return dropdown
            end

            function box:AddLabel(text)
                local row = createRow(36)
                local label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.Gotham
                label.TextSize = 14
                label.TextColor3 = Color3.fromRGB(180, 190, 220)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Text = text
                label.Size = UDim2.new(1, -28, 1, 0)
                label.Position = UDim2.new(0, 14, 0, 0)
                label.Parent = row

                local labelControl = {}

                function labelControl:AddColorPicker(id, cfg)
                    return box:AddToggle("colorpicker_" .. id, {Text = text, Default = true}):AddColorPicker(id, cfg)
                end

                -- Label 现在不再支持在 GUI 中添加 KeyPicker，只保留颜色选择等功能
                return labelControl
            end

            return box
        end

        local function createTabbox(parent, title)
            local holder = Instance.new("Frame")
            holder.BackgroundColor3 = Color3.fromRGB(22, 24, 35)
            holder.BorderSizePixel = 0
            holder.AutomaticSize = Enum.AutomaticSize.Y
            holder.Size = UDim2.new(1, 0, 0, 0)
            holder.Parent = parent
            Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 12)
            
            local tabboxPadding = Instance.new("UIPadding", holder)
            tabboxPadding.PaddingBottom = UDim.new(0, 12)

            local header = Instance.new("TextLabel")
            header.BackgroundTransparency = 1
            header.Font = Enum.Font.GothamBold
            header.TextSize = 14
            header.TextColor3 = Color3.fromRGB(180, 190, 255)
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Text = title or "Tabbox"
            header.Size = UDim2.new(1, -24, 0, 28)
            header.Position = UDim2.new(0, 12, 0, 8)
            header.Parent = holder

            local buttonBar = Instance.new("Frame")
            buttonBar.BackgroundColor3 = Color3.fromRGB(28, 32, 45)
            buttonBar.BackgroundTransparency = 0.3
            buttonBar.Size = UDim2.new(1, -24, 0, 36)
            buttonBar.Position = UDim2.new(0, 12, 0, 38)
            buttonBar.Parent = holder
            Instance.new("UICorner", buttonBar).CornerRadius = UDim.new(0, 8)

            local buttonLayout = Instance.new("UIListLayout", buttonBar)
            buttonLayout.FillDirection = Enum.FillDirection.Horizontal
            buttonLayout.Padding = UDim.new(0, 4)
            buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local barPadding = Instance.new("UIPadding", buttonBar)
            barPadding.PaddingLeft = UDim.new(0, 4)
            barPadding.PaddingTop = UDim.new(0, 4)
            barPadding.PaddingBottom = UDim.new(0, 4)

            local content = Instance.new("Frame")
            content.BackgroundTransparency = 1
            content.AutomaticSize = Enum.AutomaticSize.Y
            content.Position = UDim2.new(0, 12, 0, 82)
            content.Size = UDim2.new(1, -24, 0, 0)
            content.Parent = holder

            local tabbox = {Tabs = {}, Active = nil}

            function tabbox:Select(entry)
                if self.Active == entry then return end
                if self.Active then
                    self.Active.Button.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
                    self.Active.Button.TextTransparency = 0.3
                    self.Active.Group.Frame.Visible = false
                end
                self.Active = entry
                entry.Button.BackgroundColor3 = Color3.fromRGB(70, 95, 180)
                entry.Button.TextTransparency = 0
                entry.Group.Frame.Visible = true
            end

            function tabbox:AddTab(tabName)
                local button = Instance.new("TextButton")
                button.AutomaticSize = Enum.AutomaticSize.X
                button.Size = UDim2.new(0, math.max(90, tabName:len() * 9), 1, -8)
                button.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
                button.TextColor3 = Color3.fromRGB(200, 210, 255)
                button.TextTransparency = 0.3
                button.Font = Enum.Font.GothamSemibold
                button.TextSize = 13
                button.Text = tabName
                button.BorderSizePixel = 0
                button.Parent = buttonBar
                Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
                
                -- Tabbox子标签悬停效果（简化）
                button.MouseEnter:Connect(function()
                    if tabbox.Active and tabbox.Active.Button == button then return end
                    button.BackgroundColor3 = Color3.fromRGB(50, 58, 80)
                end)
                button.MouseLeave:Connect(function()
                    if tabbox.Active and tabbox.Active.Button == button then return end
                    button.BackgroundColor3 = Color3.fromRGB(38, 42, 58)
                end)

                local group = createGroupbox(content, tabName)
                group.Frame.Visible = false

                local entry = {Button = button, Group = group}
                table.insert(tabbox.Tabs, entry)

                button.MouseButton1Click:Connect(function()
                    tabbox:Select(entry)
                end)

                if not tabbox.Active then
                    tabbox:Select(entry)
                end

                return group
            end

            return tabbox
        end

        function tab:AddLeftGroupbox(title)
            return createGroupbox(tab.LeftColumn, title)
        end

        function tab:AddRightGroupbox(title)
            return createGroupbox(tab.RightColumn, title)
        end

        function tab:AddLeftTabbox(title)
            return createTabbox(tab.LeftColumn, title)
        end

        function tab:AddRightTabbox(title)
            return createTabbox(tab.RightColumn, title)
        end

        return tab
    end

    return window
end

Library.__call = Library.CreateWindow

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Window = Library:CreateWindow({
    Title = '✨ PasteWare  |  Modern Edition',
    Center = true,
    AutoShow = true,  
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local GeneralTab = Window:AddTab("Main")

-- 顶部总开关分组：让 Silent Aim 与 FOV 圈开关一眼就能看到
local mainSwitches = GeneralTab:AddLeftGroupbox("Main Switches")

mainSwitches:AddToggle("Master_SilentAim", {
    Text = "Silent Aim Enabled",
    Default = SilentAimSettings.Enabled
}):OnChanged(function(state)
    SilentAimSettings.Enabled = state
    -- 同步左侧 silent aim Tab 里的 Enabled 开关
    setToggleValue("aim_Enabled", state)
end)

mainSwitches:AddToggle("Master_FOVCircle", {
    Text = "Show FOV Circle",
    Default = SilentAimSettings.FOVVisible
}):OnChanged(function(state)
    SilentAimSettings.FOVVisible = state
    fov_circle.Visible = state
    -- 同步 Field Of View Tab 里的 Visible 开关
    setToggleValue("Visible", state)
end)

mainSwitches:AddToggle("ClosestPlayerMode", {
    Text = "Closest Player Mode (Ignore FOV)",
    Default = SilentAimSettings.ClosestPlayerMode
}):OnChanged(function(state)
    SilentAimSettings.ClosestPlayerMode = state
end)

local velbox = GeneralTab:AddRightGroupbox("Anti Lock")
local frabox = GeneralTab:AddRightGroupbox("Movement")
local npcBox = GeneralTab:AddRightGroupbox("NPC Targets")

npcBox:AddToggle("NPC_Enabled", {
    Text = "Enable NPC Mode",
    Default = NPCConfig.Enabled
}):OnChanged(function(state)
    NPCConfig.Enabled = state
end)

npcBox:AddToggle("NPC_OneFolderOnly", {
    Text = "One Folder Only",
    Default = NPCConfig.OneFolderOnly
}):OnChanged(function(state)
    NPCConfig.OneFolderOnly = state
end)

npcBox:AddInput("NPC_Path", {
    Text = "NPC Root Path",
    Default = NPCConfig.Path or "",
    Placeholder = "workspace.NPCSPAWN or workspace.NPCSPAWN.NPC1"
}):OnChanged(function(value)
    NPCConfig.Path = tostring(value or "")
end)

local ExploitTab = {
    AddRightGroupbox = function()
        return {
            AddToggle = function() return { AddKeyPicker = function() end } end,
            AddDropdown = function() return { OnChanged = function() end } end,
            AddButton = function() end,
            AddInput = function() return { Value = "" } end,
        }
    end
}
local ACSEngineBox = ExploitTab:AddRightGroupbox("weapon settings")
local VisualsTab = Window:AddTab("Visuals")
local settingsTab = Window:AddTab("Settings")
local MenuGroup = settingsTab:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function()
    Window:Unload()
end)
MenuGroup:AddButton("Toggle Collapse", function()
    Window:ToggleCollapse()
end)

-- 仅展示当前菜单键，不再在 GUI 中修改绑定
MenuGroup:AddLabel("Menu key: " .. (SilentAimSettings.MenuKey.Name or "End"))
Window:SetToggleKey(SilentAimSettings.MenuKey)
Window:SetVisible(true)
Window:SetCollapsed(false)

getgenv().ScriptState.Desync = false
getgenv().ScriptState.DesyncEnabled = false  


game:GetService("RunService").Heartbeat:Connect(function()
    if getgenv().ScriptState.DesyncEnabled then  
        if getgenv().ScriptState.Desync then
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end 

            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end

            local originalVelocity = humanoidRootPart.Velocity

            local randomOffset = Vector3.new(
                math.random(-1, 1) * ScriptState.reverseResolveIntensity * 1000,
                math.random(-1, 1) * ScriptState.reverseResolveIntensity * 1000,
                math.random(-1, 1) * ScriptState.reverseResolveIntensity * 1000
            )

            humanoidRootPart.Velocity = randomOffset
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(
                0,
                math.random(-1, 1) * ScriptState.reverseResolveIntensity * 0.001,
                0
            )

            game:GetService("RunService").RenderStepped:Wait()
        end
    end
end)

velbox:AddToggle("desyncMasterEnabled", {
    Text = "Enable ScriptState.Desync",
    Default = false,
    Tooltip = "Enable or disable the entire ScriptState.desync system.",
    Callback = function(value)
        getgenv().ScriptState.DesyncEnabled = value  
    end
})

velbox:AddToggle("desyncEnabled", {
    Text = "ScriptState.Desync keybind",
    Default = false,
    Tooltip = "Enable or disable reverse resolve ScriptState.desync.",
    Callback = function(value)
        getgenv().ScriptState.Desync = value
    end
}):AddKeyPicker("desyncToggleKey", {
    Default = "V", 
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "ScriptState.Desync Toggle Key",
    Tooltip = "Toggle to enable/disable velocity ScriptState.desync.",
    Callback = function(value)
        getgenv().ScriptState.Desync = value
    end
})

velbox:AddSlider("ReverseResolveIntensity", {
    Text = "velocity intensity",
    Default = 5,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Tooltip = "Adjust the intensity of the reverse resolve effect.",
    Callback = function(value)
        ScriptState.reverseResolveIntensity = value
    end
})

local MainBOX = GeneralTab:AddLeftTabbox("silent aim")
local Main = MainBOX:AddTab("silent aim")

SilentAimSettings.BulletTP = false

local aimToggle = Main:AddToggle("aim_Enabled", {
    Text = "Enabled",
    Default = SilentAimSettings.Enabled
})

local aimKeyPicker = aimToggle:AddKeyPicker("aim_Enabled_KeyPicker", {
    Default = "U",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Enabled",
    NoUI = false
})

aimToggle:OnChanged(function(state)
    SilentAimSettings.Enabled = state
end)

aimKeyPicker:OnClick(function()
    setToggleValue("aim_Enabled", not SilentAimSettings.Enabled)
end)

Main:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = SilentAimSettings.TeamCheck
}):OnChanged(function(state)
    SilentAimSettings.TeamCheck = state
end)

Main:AddToggle("BulletTP", {
    Text = "Bullet Teleport",
    Default = SilentAimSettings.BulletTP,
    Tooltip = "Teleports bullet origin to target"
}):OnChanged(function(state)
    SilentAimSettings.BulletTP = state
end)

Main:AddToggle("CheckForFireFunc", {
    Text = "Check For Fire Function",
    Default = SilentAimSettings.CheckForFireFunc,
    Tooltip = "Checks if the method is called from a fire function"
}):OnChanged(function(state)
    SilentAimSettings.CheckForFireFunc = state
end)

Main:AddToggle("MouseHitHook", {
    Text = "Mouse.Hit Hook",
    Default = false,
    Tooltip = "拦截 Mouse.Hit/Target，用于读取鼠标位置的游戏"
}):OnChanged(function(state)
    SilentAimSettings.MouseHitHook = state
end)

Main:AddToggle("RemoteHook", {
    Text = "Remote Hook (实验性)",
    Default = false,
    Tooltip = "拦截 RemoteEvent 参数，尝试修改常见射击数据格式"
}):OnChanged(function(state)
    SilentAimSettings.RemoteHook = state
end)

Main:AddToggle("BulletRedirect", {
    Text = "Bullet Redirect (物理子弹)",
    Default = false,
    Tooltip = "重定向物理子弹(BasePart)飞向目标，用于 Touched 碰撞判定的游戏"
}):OnChanged(function(state)
    SilentAimSettings.BulletRedirect = state
end)

Main:AddSlider("BulletRedirectSpeed", {
    Text = "Bullet Redirect Speed",
    Default = 500,
    Min = 100,
    Max = 2000,
    Rounding = 0,
    Tooltip = "子弹重定向速度"
}):OnChanged(function(value)
    SilentAimSettings.BulletRedirectSpeed = value
end)

Main:AddDropdown("TargetPart", {
    AllowNull = true,
    Text = "Target Part",
    Default = SilentAimSettings.TargetPart,
    Values = {"Head", "HumanoidRootPart", "Random"}
}):OnChanged(function(value)
    SilentAimSettings.TargetPart = value
end)

Main:AddDropdown("Method", {
    AllowNull = true,
    Text = "Silent Aim Method",
    Default = SilentAimSettings.SilentAimMethod,
    Values = {
        "Auto",
        "ViewportPointToRay",
        "ScreenPointToRay",
        "Raycast",
        "FindPartOnRay",
        "FindPartOnRayWithIgnoreList",
        "FindPartOnRayWithWhitelist",
        "CounterBlox"
    }
}):OnChanged(function(value)
    SilentAimSettings.SilentAimMethod = value
end)

if not SilentAimSettings.BlockedMethods then
    SilentAimSettings.BlockedMethods = {}
end

Main:AddDropdown("Blocked Methods", {
    AllowNull = true,
    Multi = true,
    Text = "Blocked Methods",
    Default = SilentAimSettings.BlockedMethods,
    Values = {
        "Destroy",
        "BulkMoveTo",
        "PivotTo",
        "TranslateBy",
        "SetPrimaryPartCFrame"
    }
}):OnChanged(function(values)
    SilentAimSettings.BlockedMethods = values or {}
end)

Main:AddDropdown("Include", {
    AllowNull = true,
    Multi = true,
    Text = "Include",
    Default = SilentAimSettings.Include or {},
    Values = {"Camera", "Character"},
    Tooltip = "Includes these objects in the ignore list"
}):OnChanged(function(values)
    SilentAimSettings.Include = values or {}
end)

Main:AddDropdown("Origin", {
    AllowNull = true,
    Multi = true,
    Text = "Origin",
    Default = SilentAimSettings.Origin or {"Camera"},
    Values = {"Camera", "Custom"},
    Tooltip = "Sets the origin of the bullet"
}):OnChanged(function(values)
    SilentAimSettings.Origin = values or {"Camera"}
end)

Main:AddSlider("MultiplyUnitBy", {
    Text = "Multiply Unit By",
    Default = SilentAimSettings.MultiplyUnitBy,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Tooltip = "Multiplies the direction vector by this value"
}):OnChanged(function(value)
    SilentAimSettings.MultiplyUnitBy = value
end)

Main:AddSlider("HitChance", {
    Text = "Hit Chance",
    Default = SilentAimSettings.HitChance,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = false,
}):OnChanged(function(value)
    SilentAimSettings.HitChance = value
end)

local FieldOfViewBOX = GeneralTab:AddLeftTabbox("Field Of View")
do
    local Main = FieldOfViewBOX:AddTab("Visuals")

    local fovToggle = Main:AddToggle("Visible", {
        Text = "Show FOV Circle",
        Default = SilentAimSettings.FOVVisible
    })
    local fovColorPicker = fovToggle:AddColorPicker("Color", {
        Default = SilentAimSettings.FOVColor or Color3.fromRGB(54, 57, 241)
    })

    fovToggle:OnChanged(function(state)
        SilentAimSettings.FOVVisible = state
        fov_circle.Visible = state
    end)

    fovColorPicker:OnChanged(function(color)
        SilentAimSettings.FOVColor = color
        fov_circle.Color = color
    end)

    Main:AddSlider("Radius", {
        Text = "FOV Circle Radius",
        Min = 0,
        Max = 360,
        Default = SilentAimSettings.FOVRadius,
        Rounding = 0
    }):OnChanged(function(value)
        fov_circle.Radius = value
        SilentAimSettings.FOVRadius = value
    end)

    local targetToggle = Main:AddToggle("MousePosition", {
        Text = "Show Silent Aim Target",
        Default = SilentAimSettings.ShowSilentAimTarget
    })
    local targetColorPicker = targetToggle:AddColorPicker("MouseVisualizeColor", {
        Default = SilentAimSettings.TargetHighlightColor or Color3.fromRGB(54, 57, 241)
    })

    targetToggle:OnChanged(function(state)
        SilentAimSettings.ShowSilentAimTarget = state
    end)

    targetColorPicker:OnChanged(function(color)
        SilentAimSettings.TargetHighlightColor = color
    end)

    Main:AddDropdown("PlayerDropdown", {
        SpecialType = "Player",
        Text = "Ignore Player",
        Tooltip = "Friend list",
        Multi = true
    }):OnChanged(function(players)
        SilentAimSettings.IgnoredPlayers = {}
        if type(players) == "table" then
            for _, name in ipairs(players) do
                SilentAimSettings.IgnoredPlayers[name] = true
            end
        end
    end)
end

local function removeOldHighlight()
    if ScriptState.previousHighlight then
        ScriptState.previousHighlight:Destroy()
        ScriptState.previousHighlight = nil
    end
end

task.spawn(function()
    RenderStepped:Connect(function()
        if SilentAimSettings.ShowSilentAimTarget then
            local closestPlayer = getClosestPlayer()
            if closestPlayer then
                local char = closestPlayer.Parent
                if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    if SilentAimSettings.TeamCheck and closestPlayer:IsA("Player") and closestPlayer.Team == LocalPlayer.Team then
                        removeOldHighlight()
                        return
                    end
                    local Root = char.PrimaryPart or char:FindFirstChild("HumanoidRootPart")
                    if Root then
                        local _, IsOnScreen = WorldToViewportPoint(Camera, Root.Position)
                        removeOldHighlight()
                        if IsOnScreen then
                            local highlight = char:FindFirstChildOfClass("Highlight")
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Parent = char
                                highlight.Adornee = char
                            end
                            local color = SilentAimSettings.TargetHighlightColor or Color3.fromRGB(54, 57, 241)
                            highlight.FillColor = color
                            highlight.FillTransparency = 0.5
                            highlight.OutlineColor = color
                            highlight.OutlineTransparency = 0
                            ScriptState.previousHighlight = highlight
                        end
                    end
                end
            else
                removeOldHighlight()
            end
        else
            removeOldHighlight()
        end

        if SilentAimSettings.FOVVisible then
            fov_circle.Visible = true
            fov_circle.Color = SilentAimSettings.FOVColor or Color3.fromRGB(54, 57, 241)
            fov_circle.Position = getMousePosition()
        else
            fov_circle.Visible = false
        end
    end)
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SoundService = game:GetService("SoundService")

local sounds = {
    ["RIFK7"] = "rbxassetid://9102080552",
    ["Bubble"] = "rbxassetid://9102092728",
    ["Minecraft"] = "rbxassetid://5869422451",
    ["Cod"] = "rbxassetid://160432334",
    ["Bameware"] = "rbxassetid://6565367558",
    ["Neverlose"] = "rbxassetid://6565370984",
    ["Gamesense"] = "rbxassetid://4817809188",
    ["Rust"] = "rbxassetid://6565371338",
}

local hitSound = Instance.new("Sound")
hitSound.Volume = 3
hitSound.Parent = SoundService

local HitSoundBox = GeneralTab:AddRightTabbox("HitSound")
do
    local Main = HitSoundBox:AddTab("HitSound [beta]")

    Main:AddToggle("HitSoundEnabled", {
        Text = "Enable HitSound",
        Default = SilentAimSettings.HitSoundEnabled
    }):OnChanged(function(state)
        SilentAimSettings.HitSoundEnabled = state
    end)

    Main:AddDropdown("HitSoundSelect", {
        Values = {"RIFK7","Bubble","Minecraft","Cod","Bameware","Neverlose","Gamesense","Rust"},
        Default = SilentAimSettings.HitSound or "Neverlose",
        Text = "HitSound",
        Tooltip = "Choose sound"
    }):OnChanged(function(value)
        SilentAimSettings.HitSound = value
        local id = sounds[value]
        if id then
            hitSound.SoundId = id
        end
    end)
end

hitSound.SoundId = sounds[SilentAimSettings.HitSound or "Neverlose"]

local soundPool = {}
local soundIndex = 1

local function getNextSound()
    if soundIndex > #soundPool then
        local s = hitSound:Clone()
        s.Parent = workspace
        s.Looped = false
        table.insert(soundPool, s)
    end
    local s = soundPool[soundIndex]
    soundIndex = soundIndex + 1
    return s
end

local function playHitSound()
    local s = getNextSound()
    s:Stop()
    s:Play()
end

local function trackPlayer(plr)
    if plr == LocalPlayer then return end

    plr.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then return end

        local lastHealth = hum.Health

        hum.HealthChanged:Connect(function(newHp)
            if SilentAimSettings.HitSoundEnabled then
                local closest = getClosestPlayer()
                if closest and closest.Parent == char then
                    if newHp < lastHealth then
                        playHitSound()
                    end
                    if lastHealth > 0 and newHp <= 0 then
                        playHitSound()
                    end
                end
            end
            lastHealth = newHp
        end)
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    trackPlayer(plr)
end
Players.PlayerAdded:Connect(trackPlayer)

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

RunService.Heartbeat:Connect(function()
    if SilentAimSettings.Enabled then
        ScriptState.ClosestHitPart = getClosestPlayer()
    else
        ScriptState.ClosestHitPart = nil
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method, Arguments = getnamecallmethod(), {...}
    local self, chance = Arguments[1], CalculateChance(SilentAimSettings.HitChance)

    local BlockedMethods = SilentAimSettings.BlockedMethods or {}
    if Method == "Destroy" and self == Client then
        return
    end
    if table.find(BlockedMethods, Method) then
        return
    end

    local CanContinue = false
    if SilentAimSettings.CheckForFireFunc and (Method == "FindPartOnRay" or Method == "FindPartOnRayWithWhitelist" or Method == "FindPartOnRayWithIgnoreList" or Method == "Raycast" or Method == "ViewportPointToRay" or Method == "ScreenPointToRay") then
        local Traceback = tostring(debug.traceback()):lower()
        if Traceback:find("bullet") or Traceback:find("gun") or Traceback:find("fire") then
            CanContinue = true
        else
            return oldNamecall(...)
        end
    end

    if SilentAimSettings.Enabled and Method == "FireServer" and not checkcaller() and chance then
        local HitPart = getClosestPlayer()
        if HitPart then
            local remote = self
            if remote and remote.Name == "ReplicateBullet" and remote.Parent and remote.Parent.Name == "Replication" and remote.Parent.Parent == game.ReplicatedStorage then
                if #Arguments >= 3 then
                    local origin = Arguments[2]
                    local direction = Arguments[3]
                    if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                        local targetPos = HitPart.Position
                        local root = HitPart.Parent and HitPart.Parent:FindFirstChild("HumanoidRootPart")
                        if root then
                            local vel = root.AssemblyLinearVelocity or root.Velocity
                            if vel then
                                targetPos = targetPos + vel * PredictionAmount
                            end
                        end
                        local newDirection = (targetPos - origin).Unit
                        Arguments[3] = newDirection
                        return oldNamecall(unpack(Arguments))
                    end
                end
            end
        end
    end

    if SilentAimSettings.Enabled and self == workspace and not checkcaller() and chance then
        local HitPart = getClosestPlayer()
        if HitPart then
            local function modifyRay(Origin)
                if SilentAimSettings.BulletTP then
                    Origin = (HitPart.CFrame * CFrame.new(0, 0, 1)).p
                end
                return Origin, getDirection(Origin, HitPart.Position)
            end

            local isAuto = SilentAimSettings.SilentAimMethod == "Auto"
            local selectedMethod = SilentAimSettings.SilentAimMethod

            -- FindPartOnRayWithIgnoreList
            if Method == "FindPartOnRayWithIgnoreList" and (isAuto or selectedMethod == Method or selectedMethod == "CounterBlox") then
                if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
                    local Origin, Direction = modifyRay(Arguments[2].Origin)
                    Arguments[2] = Ray.new(Origin, Direction * SilentAimSettings.MultiplyUnitBy)
                    return oldNamecall(unpack(Arguments))
                end
            -- FindPartOnRayWithWhitelist
            elseif Method == "FindPartOnRayWithWhitelist" and (isAuto or selectedMethod == Method) then
                if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithWhitelist) then
                    local Origin, Direction = modifyRay(Arguments[2].Origin)
                    Arguments[2] = Ray.new(Origin, Direction * SilentAimSettings.MultiplyUnitBy)
                    return oldNamecall(unpack(Arguments))
                end
            -- FindPartOnRay
            elseif (Method == "FindPartOnRay" or Method == "findPartOnRay") and (isAuto or selectedMethod:lower() == Method:lower()) then
                if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRay) then
                    local Origin, Direction = modifyRay(Arguments[2].Origin)
                    Arguments[2] = Ray.new(Origin, Direction * SilentAimSettings.MultiplyUnitBy)
                    return oldNamecall(unpack(Arguments))
                end
            -- Raycast
            elseif Method == "Raycast" and (isAuto or selectedMethod == Method) then
                if ValidateArguments(Arguments, ExpectedArguments.Raycast) then
                    local Origin = Arguments[2]
                    if SilentAimSettings.BulletTP then
                        Origin = (HitPart.CFrame * CFrame.new(0, 0, 1)).p
                    end
                    local Direction = (HitPart.Position - Origin).Unit * SilentAimSettings.MultiplyUnitBy * 1000
                    Arguments[2] = Origin
                    Arguments[3] = Direction
                    return oldNamecall(unpack(Arguments))
                end
            -- ViewportPointToRay
            elseif Method == "ViewportPointToRay" and (isAuto or selectedMethod == Method) then
                if ValidateArguments(Arguments, ExpectedArguments.ViewportPointToRay) then
                    local Origin = Camera.CFrame.p
                    if SilentAimSettings.BulletTP then
                        Origin = (HitPart.CFrame * CFrame.new(0, 0, 1)).p
                    end
                    Arguments[2] = Camera:WorldToScreenPoint(HitPart.Position)
                    return Ray.new(Origin, (HitPart.Position - Origin).Unit * SilentAimSettings.MultiplyUnitBy)
                end
            -- ScreenPointToRay
            elseif Method == "ScreenPointToRay" and (isAuto or selectedMethod == Method) then
                if ValidateArguments(Arguments, ExpectedArguments.ScreenPointToRay) then
                    local Origin = Camera.CFrame.p
                    if SilentAimSettings.BulletTP then
                        Origin = (HitPart.CFrame * CFrame.new(0, 0, 1)).p
                    end
                    Arguments[2] = Camera:WorldToScreenPoint(HitPart.Position)
                    return Ray.new(Origin, (HitPart.Position - Origin).Unit * SilentAimSettings.MultiplyUnitBy)
                end
            end
        end
    end

    return oldNamecall(...)
end))

-- ==================== 备用拦截方案 ====================
-- 用于非标准射线检测的游戏

SilentAimSettings.MouseHitHook = false
SilentAimSettings.RemoteHook = false
SilentAimSettings.BulletRedirect = false
SilentAimSettings.BulletRedirectSpeed = 500

-- Mouse.Hit / Mouse.Target 拦截
-- 只在检测到射击相关调用时才拦截，避免影响相机控制
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if SilentAimSettings.Enabled and SilentAimSettings.MouseHitHook and not checkcaller() then
        if self == Mouse and (key == "Hit" or key == "Target" or key == "UnitRay") then
            -- 检查调用栈是否来自射击相关函数
            local traceback = debug.traceback():lower()
            local isShootingContext = traceback:find("shoot") or traceback:find("fire") or 
                                       traceback:find("bullet") or traceback:find("gun") or 
                                       traceback:find("weapon") or traceback:find("attack") or
                                       traceback:find("raycast") or traceback:find("damage")
            
            if isShootingContext then
                local HitPart = getClosestPlayer()
                if HitPart then
                    if key == "Hit" then
                        return CFrame.new(HitPart.Position)
                    elseif key == "Target" then
                        return HitPart
                    elseif key == "UnitRay" then
                        local origin = Camera.CFrame.Position
                        local direction = (HitPart.Position - origin).Unit
                        return Ray.new(origin, direction)
                    end
                end
            end
        end
    end
    return oldIndex(self, key)
end))

-- 通用 Remote 拦截（尝试修改常见的射击参数格式）
local oldFireServer
oldFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
    if SilentAimSettings.Enabled and SilentAimSettings.RemoteHook and not checkcaller() then
        local args = {...}
        local HitPart = getClosestPlayer()
        if HitPart and #args > 0 then
            local modified = false
            for i, arg in ipairs(args) do
                -- 修改 Vector3 参数（可能是方向或位置）
                if typeof(arg) == "Vector3" then
                    -- 检查是否像是方向向量（长度接近1）
                    if arg.Magnitude > 0.9 and arg.Magnitude < 1.1 then
                        args[i] = (HitPart.Position - Camera.CFrame.Position).Unit
                        modified = true
                    end
                -- 修改 CFrame 参数
                elseif typeof(arg) == "CFrame" then
                    local origin = arg.Position
                    args[i] = CFrame.new(origin, HitPart.Position)
                    modified = true
                -- 修改 Ray 参数
                elseif typeof(arg) == "Ray" then
                    local origin = arg.Origin
                    args[i] = Ray.new(origin, (HitPart.Position - origin).Unit * 1000)
                    modified = true
                -- 修改表参数中的常见字段
                elseif typeof(arg) == "table" then
                    if arg.Direction and typeof(arg.Direction) == "Vector3" then
                        arg.Direction = (HitPart.Position - Camera.CFrame.Position).Unit
                        modified = true
                    end
                    if arg.Target and typeof(arg.Target) == "Vector3" then
                        arg.Target = HitPart.Position
                        modified = true
                    end
                    if arg.Hit and typeof(arg.Hit) == "CFrame" then
                        arg.Hit = CFrame.new(HitPart.Position)
                        modified = true
                    end
                    if arg.Position and typeof(arg.Position) == "Vector3" then
                        arg.Position = HitPart.Position
                        modified = true
                    end
                end
            end
            if modified then
                return oldFireServer(self, unpack(args))
            end
        end
    end
    return oldFireServer(self, ...)
end))

-- ==================== 物理子弹重定向 ====================
-- 用于使用 BasePart 作为子弹并通过 Touched 事件判定碰撞的游戏
-- 监听新创建的子弹并将其重定向到目标

local bulletKeywords = {"bullet", "projectile", "shell", "round", "shot", "ammo"}
local trackedBullets = {}

local function isBulletPart(part)
    if not part:IsA("BasePart") then return false end
    local name = part.Name:lower()
    for _, keyword in ipairs(bulletKeywords) do
        if name:find(keyword) then return true end
    end
    -- 检查是否是新创建的、快速移动的小物体
    if part.Size.Magnitude < 5 and part.Velocity.Magnitude > 50 then
        return true
    end
    return false
end

local function redirectBullet(bullet)
    if trackedBullets[bullet] then return end
    trackedBullets[bullet] = true
    
    task.spawn(function()
        local startTime = tick()
        local maxLifetime = 5 -- 最多追踪5秒
        
        while bullet and bullet.Parent and (tick() - startTime) < maxLifetime do
            if SilentAimSettings.Enabled and SilentAimSettings.BulletRedirect then
                local HitPart = getClosestPlayer()
                if HitPart then
                    local targetPos = HitPart.Position
                    local bulletPos = bullet.Position
                    local direction = (targetPos - bulletPos).Unit
                    local speed = SilentAimSettings.BulletRedirectSpeed or 500
                    
                    -- 设置子弹速度指向目标
                    bullet.Velocity = direction * speed
                    -- 也可以直接设置 CFrame
                    bullet.CFrame = CFrame.new(bulletPos, targetPos)
                end
            end
            task.wait()
        end
        
        trackedBullets[bullet] = nil
    end)
end

-- 监听 workspace 中新创建的部件
workspace.DescendantAdded:Connect(function(descendant)
    if SilentAimSettings.Enabled and SilentAimSettings.BulletRedirect then
        if isBulletPart(descendant) then
            redirectBullet(descendant)
        end
    end
end)

-- 额外监听常见的子弹容器
pcall(function()
    local particlesFolder = workspace:FindFirstChild("Particles") or workspace:FindFirstChild("Bullets") or workspace:FindFirstChild("Projectiles")
    if particlesFolder then
        particlesFolder.ChildAdded:Connect(function(child)
            if SilentAimSettings.Enabled and SilentAimSettings.BulletRedirect and child:IsA("BasePart") then
                redirectBullet(child)
            end
        end)
    end
end)

local worldbox = VisualsTab:AddRightGroupbox("World")

local lighting = game:GetService("Lighting")
local camera = game.Workspace.CurrentCamera
ScriptState.lockedTime, ScriptState.fovValue, ScriptState.nebulaEnabled = 12, 70, false
local originalAmbient, originalOutdoorAmbient = lighting.Ambient, lighting.OutdoorAmbient
local originalFogStart, originalFogEnd, originalFogColor = lighting.FogStart, lighting.FogEnd, lighting.FogColor

local nebulaThemeColor = Color3.fromRGB(173, 216, 230)

worldbox:AddSlider("world_time", {
    Text = "Clock Time", Default = 12, Min = 0, Max = 24, Rounding = 1,
    Callback = function(v)
        ScriptState.lockedTime = v
        lighting.ClockTime = v
    end,
})

local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", function(self, property, value)
    if not checkcaller() and self == lighting then
        if property == "ClockTime" then value = ScriptState.lockedTime end
    end
    return oldNewIndex(self, property, value)
end)

worldbox:AddSlider("fov_slider", {
    Text = "FOV", Default = 70, Min = 30, Max = 120, Rounding = 2,
    Callback = function(v) ScriptState.fovValue = v end,
})

worldbox:AddToggle("fov_toggle", {
    Text = "Enable FOV Change", Default = false,
    Callback = function(state) ScriptState.fovEnabled = state end,
})

game:GetService("RunService").RenderStepped:Connect(function() 
    if ScriptState.fovEnabled then
        camera.FieldOfView = ScriptState.fovValue 
    end
end)

worldbox:AddToggle("nebula_theme", {
    Text = "Nebula Theme", Default = false,
    Callback = function(state)
        ScriptState.nebulaEnabled = state
        if state then
            local b = Instance.new("BloomEffect", lighting)
            b.Intensity = 0.7
            b.Size = 24
            b.Threshold = 1
            b.Name = "NebulaBloom"
            local c = Instance.new("ColorCorrectionEffect", lighting)
            c.Saturation = 0.5
            c.Contrast = 0.2
            c.TintColor = nebulaThemeColor
            c.Name = "NebulaColorCorrection"
            local a = Instance.new("Atmosphere", lighting)
            a.Density = 0.4
            a.Offset = 0.25
            a.Glare = 1
            a.Haze = 2
            a.Color = nebulaThemeColor
            a.Decay = Color3.fromRGB(25, 25, 112)
            a.Name = "NebulaAtmosphere"
            lighting.Ambient = nebulaThemeColor
            lighting.OutdoorAmbient = nebulaThemeColor
            lighting.FogStart = 100
            lighting.FogEnd = 500
            lighting.FogColor = nebulaThemeColor
        else
            for _, v in pairs({"NebulaBloom", "NebulaColorCorrection", "NebulaAtmosphere"}) do
                local obj = lighting:FindFirstChild(v)
                if obj then
                    obj:Destroy()
                end
            end
            lighting.Ambient = originalAmbient
            lighting.OutdoorAmbient = originalOutdoorAmbient
            lighting.FogStart = originalFogStart
            lighting.FogEnd = originalFogEnd
            lighting.FogColor = originalFogColor
        end
    end,
}):AddColorPicker("nebula_color_picker", {
    Text = "Nebula Color", Default = Color3.fromRGB(173, 216, 230),
    Callback = function(c)
        nebulaThemeColor = c
        if ScriptState.nebulaEnabled then
            local nc = lighting:FindFirstChild("NebulaColorCorrection")
            if nc then
                nc.TintColor = c
            end
            local na = lighting:FindFirstChild("NebulaAtmosphere")
            if na then
                na.Color = c
            end
            lighting.Ambient = c
            lighting.OutdoorAmbient = c
            lighting.FogColor = c
        end
    end,
})

local Lighting = game:GetService("Lighting")
local Visuals = {}
local Skyboxes = {}

function Visuals:NewSky(Data)
    local Name = Data.Name
    Skyboxes[Name] = {
        SkyboxBk = Data.SkyboxBk,
        SkyboxDn = Data.SkyboxDn,
        SkyboxFt = Data.SkyboxFt,
        SkyboxLf = Data.SkyboxLf,
        SkyboxRt = Data.SkyboxRt,
        SkyboxUp = Data.SkyboxUp,
        MoonTextureId = Data.Moon or "rbxasset://sky/moon.jpg",
        SunTextureId = Data.Sun or "rbxasset://sky/sun.jpg"
    }
end

function Visuals:SwitchSkybox(Name)
    local OldSky = Lighting:FindFirstChildOfClass("Sky")
    if OldSky then OldSky:Destroy() end

    local Sky = Instance.new("Sky", Lighting)
    for Index, Value in pairs(Skyboxes[Name]) do
        Sky[Index] = Value
    end
end

if Lighting:FindFirstChildOfClass("Sky") then
    local OldSky = Lighting:FindFirstChildOfClass("Sky")
    Visuals:NewSky({
        Name = "Game's Default Sky",
        SkyboxBk = OldSky.SkyboxBk,
        SkyboxDn = OldSky.SkyboxDn,
        SkyboxFt = OldSky.SkyboxFt,
        SkyboxLf = OldSky.SkyboxLf,
        SkyboxRt = OldSky.SkyboxRt,
        SkyboxUp = OldSky.SkyboxUp
    })
end

Visuals:NewSky({
    Name = "Sunset",
    SkyboxBk = "rbxassetid://600830446",
    SkyboxDn = "rbxassetid://600831635",
    SkyboxFt = "rbxassetid://600832720",
    SkyboxLf = "rbxassetid://600886090",
    SkyboxRt = "rbxassetid://600833862",
    SkyboxUp = "rbxassetid://600835177"
})

Visuals:NewSky({
    Name = "Arctic",
    SkyboxBk = "http://www.roblox.com/asset/?id=225469390",
    SkyboxDn = "http://www.roblox.com/asset/?id=225469395",
    SkyboxFt = "http://www.roblox.com/asset/?id=225469403",
    SkyboxLf = "http://www.roblox.com/asset/?id=225469450",
    SkyboxRt = "http://www.roblox.com/asset/?id=225469471",
    SkyboxUp = "http://www.roblox.com/asset/?id=225469481"
})

Visuals:NewSky({
    Name = "Space",
    SkyboxBk = "http://www.roblox.com/asset/?id=166509999",
    SkyboxDn = "http://www.roblox.com/asset/?id=166510057",
    SkyboxFt = "http://www.roblox.com/asset/?id=166510116",
    SkyboxLf = "http://www.roblox.com/asset/?id=166510092",
    SkyboxRt = "http://www.roblox.com/asset/?id=166510131",
    SkyboxUp = "http://www.roblox.com/asset/?id=166510114"
})

Visuals:NewSky({
    Name = "Roblox Default",
    SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex",
    SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex",
    SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex",
    SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex",
    SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex",
    SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
})

Visuals:NewSky({
    Name = "Red Night", 
    SkyboxBk = "http://www.roblox.com/Asset/?ID=401664839";
    SkyboxDn = "http://www.roblox.com/Asset/?ID=401664862";
    SkyboxFt = "http://www.roblox.com/Asset/?ID=401664960";
    SkyboxLf = "http://www.roblox.com/Asset/?ID=401664881";
    SkyboxRt = "http://www.roblox.com/Asset/?ID=401664901";
    SkyboxUp = "http://www.roblox.com/Asset/?ID=401664936";
})

Visuals:NewSky({
    Name = "Deep Space", 
    SkyboxBk = "http://www.roblox.com/asset/?id=149397692";
    SkyboxDn = "http://www.roblox.com/asset/?id=149397686";
    SkyboxFt = "http://www.roblox.com/asset/?id=149397697";
    SkyboxLf = "http://www.roblox.com/asset/?id=149397684";
    SkyboxRt = "http://www.roblox.com/asset/?id=149397688";
    SkyboxUp = "http://www.roblox.com/asset/?id=149397702";
})

Visuals:NewSky({
    Name = "Pink Skies", 
    SkyboxBk = "http://www.roblox.com/asset/?id=151165214";
    SkyboxDn = "http://www.roblox.com/asset/?id=151165197";
    SkyboxFt = "http://www.roblox.com/asset/?id=151165224";
    SkyboxLf = "http://www.roblox.com/asset/?id=151165191";
    SkyboxRt = "http://www.roblox.com/asset/?id=151165206";
    SkyboxUp = "http://www.roblox.com/asset/?id=151165227";
})

Visuals:NewSky({
    Name = "Purple Sunset", 
    SkyboxBk = "rbxassetid://264908339";
    SkyboxDn = "rbxassetid://264907909";
    SkyboxFt = "rbxassetid://264909420";
    SkyboxLf = "rbxassetid://264909758";
    SkyboxRt = "rbxassetid://264908886";
    SkyboxUp = "rbxassetid://264907379";
})

Visuals:NewSky({
    Name = "Blue Night", 
    SkyboxBk = "http://www.roblox.com/Asset/?ID=12064107";
    SkyboxDn = "http://www.roblox.com/Asset/?ID=12064152";
    SkyboxFt = "http://www.roblox.com/Asset/?ID=12064121";
    SkyboxLf = "http://www.roblox.com/Asset/?ID=12063984";
    SkyboxRt = "http://www.roblox.com/Asset/?ID=12064115";
    SkyboxUp = "http://www.roblox.com/Asset/?ID=12064131";
})

Visuals:NewSky({
    Name = "Blossom Daylight", 
    SkyboxBk = "http://www.roblox.com/asset/?id=271042516";
    SkyboxDn = "http://www.roblox.com/asset/?id=271077243";
    SkyboxFt = "http://www.roblox.com/asset/?id=271042556";
    SkyboxLf = "http://www.roblox.com/asset/?id=271042310";
    SkyboxRt = "http://www.roblox.com/asset/?id=271042467";
    SkyboxUp = "http://www.roblox.com/asset/?id=271077958";
})

Visuals:NewSky({
    Name = "Blue Nebula", 
    SkyboxBk = "http://www.roblox.com/asset?id=135207744";
    SkyboxDn = "http://www.roblox.com/asset?id=135207662";
    SkyboxFt = "http://www.roblox.com/asset?id=135207770";
    SkyboxLf = "http://www.roblox.com/asset?id=135207615";
    SkyboxRt = "http://www.roblox.com/asset?id=135207695";
    SkyboxUp = "http://www.roblox.com/asset?id=135207794";
})

Visuals:NewSky({
    Name = "Blue Planet", 
    SkyboxBk = "rbxassetid://218955819";
    SkyboxDn = "rbxassetid://218953419";
    SkyboxFt = "rbxassetid://218954524";
    SkyboxLf = "rbxassetid://218958493";
    SkyboxRt = "rbxassetid://218957134";
    SkyboxUp = "rbxassetid://218950090";
})

Visuals:NewSky({
    Name = "Deep Space", 
    SkyboxBk = "http://www.roblox.com/asset/?id=159248188";
    SkyboxDn = "http://www.roblox.com/asset/?id=159248183";
    SkyboxFt = "http://www.roblox.com/asset/?id=159248187";
    SkyboxLf = "http://www.roblox.com/asset/?id=159248173";
    SkyboxRt = "http://www.roblox.com/asset/?id=159248192";
    SkyboxUp = "http://www.roblox.com/asset/?id=159248176";
})

local SkyboxNames = {}
for Name, _ in pairs(Skyboxes) do
    table.insert(SkyboxNames, Name)
end

local worldbox = VisualsTab:AddRightGroupbox("SkyBox")
local SkyboxDropdown = worldbox:AddDropdown("SkyboxSelector", {
    AllowNull = false,
    Text = "Select Skybox",
    Default = "Game's Default Sky",
    Values = SkyboxNames
}):OnChanged(function(SelectedSkybox)
    if Skyboxes[SelectedSkybox] then
        Visuals:SwitchSkybox(SelectedSkybox)
    end
end)

local localPlayer = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera
local humanoid = nil

frabox:AddToggle("functionalityEnabled", {
    Text = "Enable/Disable movement",
    Default = true,
    Tooltip = "Enable or disable.",
    Callback = function(value)
        ScriptState.isFunctionalityEnabled = value
    end
})

frabox:AddToggle("speedEnabled", {
    Text = "Speed Toggle",
    Default = false,
    Tooltip = "It makes you go fast.",
    Callback = function(value)
        ScriptState.isSpeedActive = value
    end
}):AddKeyPicker("speedToggleKey", {
    Default = "C",  
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Speed Toggle Key",
    Tooltip = "CFrame keybind.",
    Callback = function(value)
        ScriptState.isSpeedActive = value
    end
})

frabox:AddSlider("cframespeed", {
    Text = "CFrame Multiplier",
    Default = 1,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Tooltip = "The CFrame speed.",
    Callback = function(value)
        ScriptState.Cmultiplier = value
    end,
})

frabox:AddToggle("flyEnabled", {
    Text = "CFly Toggle",
    Default = false,
    Tooltip = "Toggle CFrame Fly functionality.",
    Callback = function(value)
        ScriptState.isFlyActive = value
    end
}):AddKeyPicker("flyToggleKey", {
    Default = "F",  
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "CFly Toggle Key",
    Tooltip = "CFrame Fly keybind.",
    Callback = function(value)
        ScriptState.isFlyActive = value
    end
})

frabox:AddSlider("ScriptState.flySpeed", {
    Text = "CFly Speed",
    Default = 1,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Tooltip = "The CFrame Fly speed.",
    Callback = function(value)
        ScriptState.flySpeed = value
    end,
})

frabox:AddToggle("noClipEnabled", {
    Text = "NoClip Toggle",
    Default = false,
    Tooltip = "Enable or disable NoClip.",
    Callback = function(value)
        ScriptState.isNoClipActive = value
    end
}):AddKeyPicker("noClipToggleKey", {
    Default = "N",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "NoClip Toggle Key",
    Tooltip = "Keybind to toggle NoClip.",
    Callback = function(value)
        ScriptState.isNoClipActive = value
    end
})

local function modifyWeaponSettings(property, value)
    local function findSettingsModule(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("ModuleScript") then
                local success, module = pcall(function() return require(child) end)
                if success and module[property] ~= nil then
                    return child
                end
            end
            local found = findSettingsModule(child)
            if found then
                return found
            end
        end
        return nil
    end

    local player = game:GetService("Players").LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()

    local function applyAttribute(weapon)
        if weapon and weapon:IsA("Tool") then
            pcall(function()
                weapon:SetAttribute(property, value)
            end)
        end
    end

    local function applyRequireModule(settingsModule)
        if settingsModule then
            local success, module = pcall(function() return require(settingsModule) end)
            if success and module[property] ~= nil then
                module[property] = value
            end
        end
    end

    local useAttribute = getgenv().WeaponModifyMethod == "Attribute"

    local function processWeapon(weapon)
        if not weapon then return end
        if useAttribute then
            applyAttribute(weapon)
        else
            local settingsModule = findSettingsModule(weapon)
            applyRequireModule(settingsModule)
        end
    end

    if getgenv().WeaponOnHands then
        local toolInHand = character:FindFirstChildOfClass("Tool")
        if toolInHand then
            processWeapon(toolInHand)
        end
    else
        for _, item in pairs(backpack:GetChildren()) do
            processWeapon(item)
        end
    end
end


--not final code need optimize FindFirstChild... Cuz can make FinFirstChilde true withous find 1 and find 2 only find 1
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

ACSEngineBox:AddToggle("WeaponOnHands", {
    Text = "Weapon In Hands",
    Default = false,
    Tooltip = "Apply changes only to the weapon in hands if enabled.",
    Callback = function(value)
        getgenv().WeaponOnHands = value
    end
})

ACSEngineBox:AddDropdown("WeaponModifyMethod", {
    Text = "Weapon Modify Method",
    Default = "Attribute",
    Values = {"Attribute", "Require"},
    Tooltip = "Choose how to modify weapon settings",
    Callback = function(value)
        getgenv().WeaponModifyMethod = value
    end
})

ACSEngineBox:AddButton('INF AMMO', function()
    modifyWeaponSettings("Ammo", math.huge)
end)

ACSEngineBox:AddButton('NO RECOIL | NO SPREAD', function()
    if getgenv().WeaponModifyMethod == "Attribute" then
        modifyWeaponSettings("VRecoil", Vector2.new(0, 0))
        modifyWeaponSettings("HRecoil", Vector2.new(0, 0))
    else
        modifyWeaponSettings("VRecoil", {0, 0})
        modifyWeaponSettings("HRecoil", {0, 0})
    end
    modifyWeaponSettings("MinSpread", 0)
    modifyWeaponSettings("MaxSpread", 0)
    modifyWeaponSettings("RecoilPunch", 0)
    modifyWeaponSettings("AimRecoilReduction", 0)
end)

ACSEngineBox:AddButton('INF BULLET DISTANCE', function()
    modifyWeaponSettings("Distance", 25000)
end)

ACSEngineBox:AddInput("BulletSpeedInput", {
    Text = "Bullet Speed",
    Default = "10000",
    Tooltip = "Set the bullet speed",
    Callback = function(value)
        getgenv().bulletSpeedValue = tonumber(value) or 10000
    end
})

ACSEngineBox:AddButton('CHANGE BULLET SPEED', function()
    modifyWeaponSettings("BSpeed", getgenv().bulletSpeedValue or 10000)
    modifyWeaponSettings("MuzzleVelocity", getgenv().bulletSpeedValue or 10000)
end)

local fireRateInput = ACSEngineBox:AddInput('FireRateInput', {
    Text = 'Enter Fire Rate',
    Default = '8888',
    Tooltip = 'Type the fire rate value you want to apply.',
})

ACSEngineBox:AddButton('CHANGE FIRE RATE', function()
    local rate = tonumber(fireRateInput.Value) or 8888
    modifyWeaponSettings("FireRate", rate)
    modifyWeaponSettings("ShootRate", rate)
end)

local bulletsInput = ACSEngineBox:AddInput('BulletsInput', {
    Text = 'Enter Bullets',
    Default = '50',
    Tooltip = 'Type the number of bullets you want to apply.',
    Numeric = true
})

ACSEngineBox:AddButton('MULTI BULLETS', function()
    local bulletsValue = tonumber(bulletsInput.Value) or 50
    modifyWeaponSettings("Bullets", bulletsValue)
end)

local inputField = ACSEngineBox:AddInput('FireModeInput', {
    Text = 'Enter Fire Mode',
    Default = 'Auto',
    Tooltip = 'Type the fire mode you want to apply.',
})

ACSEngineBox:AddButton('CHANGE FIRE MODE', function()
    modifyWeaponSettings("Mode", inputField.Value or 'Auto')
end)

local targetStrafe = GeneralTab:AddLeftGroupbox("Target Strafe")
ScriptState.strafeSpeed, ScriptState.strafeRadius = 50, 5
ScriptState.strafeMode, ScriptState.targetPlayer = "Horizontal", nil
local function startTargetStrafe()
    if not ScriptState.strafeAllowed then return end
    ScriptState.targetPlayer = getClosestPlayer()
    if ScriptState.targetPlayer and ScriptState.targetPlayer.Parent then
        ScriptState.originalCameraMode = game:GetService("Players").LocalPlayer.CameraMode
        game:GetService("Players").LocalPlayer.CameraMode = Enum.CameraMode.Classic
        local targetPos = ScriptState.targetPlayer.Position
        LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPos))
        Camera.CameraSubject = ScriptState.targetPlayer.Parent:FindFirstChild("Humanoid")
    end
end

local function strafeAroundTarget()
    if not (ScriptState.strafeAllowed and ScriptState.targetPlayer and ScriptState.targetPlayer.Parent) then return end
    local targetPos = ScriptState.targetPlayer.Position
    local angle = tick() * (ScriptState.strafeSpeed / 10)
    local offset = ScriptState.strafeMode == "Horizontal"
        and Vector3.new(math.cos(angle) * ScriptState.strafeRadius, 0, math.sin(angle) * ScriptState.strafeRadius)
        or Vector3.new(math.cos(angle) * ScriptState.strafeRadius, ScriptState.strafeRadius, math.sin(angle) * ScriptState.strafeRadius)
    LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPos + offset))
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(LocalPlayer.Character.HumanoidRootPart.Position, targetPos)
end

local function stopTargetStrafe()
    game:GetService("Players").LocalPlayer.CameraMode = ScriptState.originalCameraMode or Enum.CameraMode.Classic
    Camera.CameraSubject = LocalPlayer.Character.Humanoid
    ScriptState.strafeEnabled, ScriptState.targetPlayer = false, nil
end


targetStrafe:AddToggle("strafeControlToggle", {
    Text = "Enable/Disable",
    Default = true,
    Tooltip = "Enable or disable the ability to use Target Strafe.",
    Callback = function(value)
        ScriptState.strafeAllowed = value
        if not ScriptState.strafeAllowed and ScriptState.strafeEnabled then
            stopTargetStrafe()
        end
    end
})

targetStrafe:AddToggle("strafeToggle", {
    Text = "Enable Target Strafe",
    Default = false,
    Tooltip = "Enable or disable Target Strafe.",
    Callback = function(value)
        if ScriptState.strafeAllowed then
            ScriptState.strafeEnabled = value
            if ScriptState.strafeEnabled then startTargetStrafe() else stopTargetStrafe() end
        end
    end
}):AddKeyPicker("strafeToggleKey", {
    Default = "L",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Target Strafe Toggle Key",
    Tooltip = "Key to toggle Target Strafe",
    Callback = function(value)
        if ScriptState.strafeAllowed then
            ScriptState.strafeEnabled = value
            if ScriptState.strafeEnabled then startTargetStrafe() else stopTargetStrafe() end
        end
    end
})

targetStrafe:AddDropdown("strafeModeDropdown", {
    AllowNull = false,
    Text = "Target Strafe Mode",
    Default = "Horizontal",
    Values = {"Horizontal", "UP"},
    Tooltip = "Select the strafing mode.",
    Callback = function(value) ScriptState.strafeMode = value end
})

targetStrafe:AddSlider("strafeRadiusSlider", {
    Text = "Strafe Radius",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Tooltip = "Set the radius of movement around the target.",
    Callback = function(value) ScriptState.strafeRadius = value end
})

targetStrafe:AddSlider("strafeSpeedSlider", {
    Text = "Strafe Speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1,
    Tooltip = "Set the speed of strafing around the target.",
    Callback = function(value) ScriptState.strafeSpeed = value end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if ScriptState.strafeEnabled and ScriptState.strafeAllowed then strafeAroundTarget() end
end)

local function updateMovement()
    if not ScriptState.isFunctionalityEnabled then return end

    local character = localPlayer.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    humanoid = character:FindFirstChildOfClass("Humanoid")

    if ScriptState.isSpeedActive and humanoid and humanoid.MoveDirection.Magnitude > 0 then
        local moveDirection = humanoid.MoveDirection.Unit
        root.CFrame = root.CFrame + moveDirection * ScriptState.Cmultiplier
    end

    if ScriptState.isFlyActive then
        local flyDirection = Vector3.zero
        local cameraCFrame = camera and camera.CFrame or workspace.CurrentCamera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            flyDirection += cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            flyDirection -= cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            flyDirection -= cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            flyDirection += cameraCFrame.RightVector
        end

        if flyDirection.Magnitude > 0 then
            flyDirection = flyDirection.Unit
        end

        local newPosition = root.Position + flyDirection * ScriptState.flySpeed
        root.CFrame = CFrame.new(newPosition)
        root.Velocity = Vector3.new(0, 0, 0)
    end

    if ScriptState.isNoClipActive then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end

local movementConnection = RunService.Heartbeat:Connect(updateMovement)

if IsMobile then
    local mobileToggleGui = Instance.new("ScreenGui")
    mobileToggleGui.Name = "PasteWareMobileToggle"
    mobileToggleGui.IgnoreGuiInset = true
    mobileToggleGui.ResetOnSpawn = false
    mobileToggleGui.DisplayOrder = 999
    protectgui(mobileToggleGui)
    pcall(function()
        mobileToggleGui.Parent = CoreGui
    end)
    if not mobileToggleGui.Parent then
        mobileToggleGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 10, 0.5, -25)
    toggleButton.BackgroundColor3 = Color3.fromRGB(70, 90, 180)
    toggleButton.BackgroundTransparency = 0.3
    toggleButton.Text = "☰"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 24
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = mobileToggleGui
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0.5, 0)

    local buttonDragging = false
    local buttonDragStart, buttonStartPos
    local dragMoved = false
    local DRAG_THRESHOLD = 10

    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            buttonDragging = true
            dragMoved = false
            buttonDragStart = input.Position
            buttonStartPos = toggleButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if not dragMoved then
                        Window:ToggleVisibility()
                    end
                    buttonDragging = false
                    dragMoved = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if buttonDragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - buttonDragStart
            if delta.Magnitude > DRAG_THRESHOLD then
                dragMoved = true
            end
            if dragMoved then
                toggleButton.Position = UDim2.new(buttonStartPos.X.Scale, buttonStartPos.X.Offset + delta.X, buttonStartPos.Y.Scale, buttonStartPos.Y.Offset + delta.Y)
            end
        end
    end)
end

