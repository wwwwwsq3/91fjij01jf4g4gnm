local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)
local InputService = cloneref(game:GetService("UserInputService"))
local TextService = cloneref(game:GetService("TextService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Teams = cloneref(game:GetService("Teams"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end
local Mouse = cloneref(LocalPlayer:GetMouse())

local setclipboard = setclipboard or nil
local getgenv = getgenv or function()
    return shared
end
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GetHUI = gethui or function()
    return CoreGui
end

local DrawingLib = if typeof(Drawing) == "table" then Drawing else { drawing_replaced = true }
local IsBadDrawingLib = false

local assert = function(condition, errorMessage)
    if not condition then
        error(if errorMessage then errorMessage else "assert failed", 3)
    end
end

local function SafeParentUI(Instance, Parent)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI, SkipHiddenUI)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(ProtectGui, UI)
    SafeParentUI(UI, GetHUI)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 999
ScreenGui.ResetOnSpawn = false
ParentUI(ScreenGui)

local ModalElement = Instance.new("TextButton")
ModalElement.BackgroundTransparency = 1
ModalElement.Modal = false
ModalElement.Size = UDim2.fromScale(0, 0)
ModalElement.AnchorPoint = Vector2.zero
ModalElement.Text = ""
ModalElement.ZIndex = -999
ModalElement.Parent = ScreenGui

local LibraryMainOuterFrame = nil

local Toggles = {}
local Options = {}
local Labels = {}
local Buttons = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    Cursor = {
        RobloxId = 9619665977,
        Path = "LinoriaLib/assets/Cursor.png",
        URL = BaseURL .. "assets/Cursor.png",
        Id = nil,
    },
    DropdownArrow = {
        RobloxId = 6282522798,
        Path = "LinoriaLib/assets/DropdownArrow.png",
        URL = BaseURL .. "assets/DropdownArrow.png",
        Id = nil,
    },
    Checker = {
        RobloxId = 12977615774,
        Path = "LinoriaLib/assets/Checker.png",
        URL = BaseURL .. "assets/Checker.png",
        Id = nil,
    },
    CheckerLong = {
        RobloxId = 12978095818,
        Path = "LinoriaLib/assets/CheckerLong.png",
        URL = BaseURL .. "assets/CheckerLong.png",
        Id = nil,
    },
    SaturationMap = {
        RobloxId = 4155801252,
        Path = "LinoriaLib/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",
        Id = nil,
    }
}
do
    local function RecursiveCreatePath(Path, IsFile)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(AssetName, RobloxAssetId, URL, ForceRedownload)
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,
            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local DPIScale = 1;
local Library = {
    Registry = {};
    RegistryMap = {};
    HudRegistry = {};

    FontColor = Color3.fromRGB(240, 240, 240);
    MainColor = Color3.fromRGB(28, 28, 28);
    BackgroundColor = Color3.fromRGB(20, 20, 20);
    SecondaryColor = Color3.fromRGB(38, 38, 38);

    AccentColor = Color3.fromRGB(0, 122, 255);
    DisabledAccentColor = Color3.fromRGB(142, 142, 142);

    OutlineColor = Color3.fromRGB(60, 60, 60);
    DisabledOutlineColor = Color3.fromRGB(70, 70, 70);

    DisabledTextColor = Color3.fromRGB(142, 142, 142);

    RiskColor = Color3.fromRGB(255, 59, 48);

    Black = Color3.new(0, 0, 0);
    Font = Enum.Font.SourceSansSemibold or Enum.Font.GothamSemibold or Enum.Font.SourceSans;

    OpenedFrames = {};
    DependencyBoxes = {};
    DependencyGroupboxes = {};

    UnloadSignals = {};
    Signals = {};

    ActiveTab = nil;
    TotalTabs = 0;

    ScreenGui = ScreenGui;
    KeybindFrame = nil;
    KeybindContainer = nil;
    Window = { Holder = nil; Tabs = {}; };

    VideoLink = "";
    
    Toggled = false;
    ToggleKeybind = nil;

    IsMobile = false;
    DevicePlatform = Enum.Platform.None;

    CanDrag = true;
    CantDragForced = false;

    Unloaded = false;

    Notify = nil;
    NotifySide = "Right";
    ShowCustomCursor = true;
    ShowToggleFrameInKeybinds = true;
    NotifyOnError = false;

    SaveManager = nil;
    ThemeManager = nil;

    Toggles = Toggles;
    Options = Options;
    Labels = Labels;
    Buttons = Buttons;

    ImageManager = CustomImageManager;
    
    CurrentRainbowHue = 0;
    CurrentRainbowColor = Color3.fromHSV(0, 0.8, 1);
    
    GlowEnabled = true;
    BlurEnabled = true;
    AnimationsEnabled = true;
}

function Library:GetToggle(Idx)
    return Toggles[Idx]
end

function Library:ApplyToTab(Tab)
    if not Tab then
        return
    end

    local Target = (typeof(Tab) == "table" and (Tab.TabFrame or Tab.Container or Tab.Frame)) or (typeof(Tab) == "Instance" and Tab) or nil
    if Target and typeof(Target) == "Instance" then
        Library:AddToRegistry(Target, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        })
    end
end

function Library:CreateThemeManager()
    return Library.ThemeManager
end

if RunService:IsStudio() then
   Library.IsMobile = InputService.TouchEnabled and not InputService.MouseEnabled 
else
    pcall(function() Library.DevicePlatform = InputService:GetPlatform() end)
    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
end

Library.MinSize = if Library.IsMobile then Vector2.new(550, 200) else Vector2.new(550, 300)

local function ApplyDPIScale(Position)
    return UDim2.new(Position.X.Scale, Position.X.Offset * DPIScale, Position.Y.Scale, Position.Y.Offset * DPIScale)
end

local function ApplyTextScale(TextSize)
    return TextSize * DPIScale
end

local function GetTableSize(t)
    local n = 0
    for _, _ in pairs(t) do
        n = n + 1
    end
    return n
end

local function GetPlayers(ExcludeLocalPlayer, ReturnInstances)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)

        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    if ReturnInstances == true then
        return PlayerList
    end

    local FixedPlayerList = {}
    for _, player in next, PlayerList do
        FixedPlayerList[#FixedPlayerList + 1] = player.Name
    end

    return FixedPlayerList
end

local function GetTeams(ReturnInstances)
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    if ReturnInstances == true then
        return TeamList
    end

    local FixedTeamList = {}
    for _, team in next, TeamList do
        FixedTeamList[#FixedTeamList + 1] = team.Name
    end

    return FixedTeamList
end

local function Trim(Text)
    return Text:match("^%s*(.-)%s*$")
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons, Icons = pcall(function()
    local Source = game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")
    if typeof(Source) ~= "string" then
        return nil
    end

    local Loader = loadstring(Source)
    if typeof(Loader) ~= "function" then
        return nil
    end

    return (Loader :: () -> IconModule)()
end)

function IsValidCustomIcon(Icon)
    return typeof(Icon) == "string"
        and (Icon:match("rbxasset") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

function Library:GetIcon(IconName)
    if not FetchIcons then
        return
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end

    return Icon
end

function Library:GetCustomIcon(IconName)
    if not IsValidCustomIcon(IconName) then
        return Library:GetIcon(IconName)
    else
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end
end

function Library:SetIconModule(module)
    FetchIcons = true
    Icons = module
end

function Library:Validate(Table, Template)
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in pairs(Template) do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

function Library:SetDPIScale(value) 
    assert(type(value) == "number", "Expected type number for DPI scale but got " .. typeof(value))
    
    DPIScale = value / 100
    Library.MinSize = (if Library.IsMobile then Vector2.new(550, 200) else Vector2.new(550, 300)) * DPIScale
end

function Library:SafeCallback(Func, ...)
    if not Func or typeof(Func) ~= "function" then
        return
    end

    local success, result = xpcall(Func, function(err)
        warn("Callback error:", err)
        return debug.traceback(err)
    end, ...)

    if not success then
        return nil
    end

    return result
end

function Library:AttemptSave()
    if not Library.SaveManager then return end
    Library.SaveManager:Save()
end

function Library:Create(Class, Properties)
    local _Instance = Class

    if typeof(Class) == "string" then
        _Instance = Instance.new(Class)
    end

    for Property, Value in next, Properties do
        if Property == "Size" or Property == "Position" then
            Value = ApplyDPIScale(Value)
        elseif Property == "TextSize" then
            Value = ApplyTextScale(Value)
        end

        local success, err = pcall(function()
            _Instance[Property] = Value
        end)

        if not success then
            warn(err)
        end
    end

    return _Instance
end

function Library:ApplyTextStroke(Inst)
    Inst.TextStrokeTransparency = 1

    return Library:Create('UIStroke', {
        Color = Color3.new(0, 0, 0);
        Thickness = 1.5;
        LineJoinMode = Enum.LineJoinMode.Round;
        Parent = Inst;
    })
end

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Font = Library.Font;
        TextColor3 = Library.FontColor;
        TextSize = 16;
        TextStrokeTransparency = 0;
    })

    Library:ApplyTextStroke(_Instance)

    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
    }, IsHud)

    return Library:Create(_Instance, Properties)
end

function Library:MakeDraggable(Instance, Cutoff, IsMainWindow)
    if not Instance then return end
    
    Instance.Active = true

    if Library.IsMobile == false then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow == true and Library.CantDragForced == true then
                    return
                end
           
                local ObjPos = Vector2.new(
                    Mouse.X - Instance.AbsolutePosition.X,
                    Mouse.Y - Instance.AbsolutePosition.Y
                )

                if ObjPos.Y > (Cutoff or 40) then
                    return
                end

                local DragTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                local OriginalColor = Instance.BackgroundColor3
                
                TweenService:Create(Instance, DragTweenInfo, {
                    BackgroundColor3 = Library.AccentColor,
                }):Play()

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Instance.Position = UDim2.new(
                        0,
                        Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                        0,
                        Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                    )

                    RunService.RenderStepped:Wait()
                end

                TweenService:Create(Instance, DragTweenInfo, {
                    BackgroundColor3 = IsMainWindow and Library.MainColor or OriginalColor,
                }):Play()
            end
        end)
    else
        local Dragging, DraggingInput, DraggingStart, StartPosition

        InputService.TouchStarted:Connect(function(Input)
            if IsMainWindow == true and Library.CantDragForced == true then
                Dragging = false
                return
            end

            if not Dragging and Library:MouseIsOverFrame(Instance, Input) and (IsMainWindow == true and (Library.CanDrag == true and Library.Window.Holder.Visible == true) or true) then
                DraggingInput = Input
                DraggingStart = Input.Position
                StartPosition = Instance.Position

                local OffsetPos = Input.Position - DraggingStart
                if OffsetPos.Y > (Cutoff or 40) then
                    Dragging = false
                    return
                end

                Dragging = true
                
                local DragTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                TweenService:Create(Instance, DragTweenInfo, {
                    BackgroundColor3 = Library.AccentColor,
                }):Play()
            end
        end)
        
        InputService.TouchMoved:Connect(function(Input)
            if IsMainWindow == true and Library.CantDragForced == true then
                Dragging = false
                return
            end

            if Input == DraggingInput and Dragging and (IsMainWindow == true and (Library.CanDrag == true and Library.Window.Holder.Visible == true) or true) then
                local OffsetPos = Input.Position - DraggingStart

                Instance.Position = UDim2.new(
                    StartPosition.X.Scale,
                    StartPosition.X.Offset + OffsetPos.X,
                    StartPosition.Y.Scale,
                    StartPosition.Y.Offset + OffsetPos.Y
                )
            end
        end)
        
        InputService.TouchEnded:Connect(function(Input)
            if Input == DraggingInput then 
                Dragging = false
                local DragTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                TweenService:Create(Instance, DragTweenInfo, {
                    BackgroundColor3 = IsMainWindow and Library.MainColor or Instance.BackgroundColor3,
                }):Play()
            end
        end)
    end
end

function Library:MakeDraggableUsingParent(Instance, Parent, Cutoff, IsMainWindow)
    if not Instance or not Parent then return end
    
    Instance.Active = true

    if Library.IsMobile == false then
        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if IsMainWindow == true and Library.CantDragForced == true then
                    return
                end
  
                local ObjPos = Vector2.new(
                    Mouse.X - Parent.AbsolutePosition.X,
                    Mouse.Y - Parent.AbsolutePosition.Y
                )

                if ObjPos.Y > (Cutoff or 40) then
                    return
                end

                local DragTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                TweenService:Create(Parent, DragTweenInfo, {
                    BackgroundColor3 = Library.AccentColor,
                }):Play()

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Parent.Position = UDim2.new(
                        0,
                        Mouse.X - ObjPos.X + (Parent.Size.X.Offset * Parent.AnchorPoint.X),
                        0,
                        Mouse.Y - ObjPos.Y + (Parent.Size.Y.Offset * Parent.AnchorPoint.Y)
                    )

                    RunService.RenderStepped:Wait()
                end

                TweenService:Create(Parent, DragTweenInfo, {
                    BackgroundColor3 = IsMainWindow and Library.MainColor or Parent.BackgroundColor3,
                }):Play()
            end
        end)
    else  
        Library:MakeDraggable(Parent, Cutoff, IsMainWindow)
    end
end

function Library:MakeResizable(Instance, MinSize)
    if Library.IsMobile then
        return
    end

    if not Instance then return end
    
    Instance.Active = true
    
    local ResizerImage_Size = 25 * DPIScale
    local ResizerImage_HoverTransparency = 0.5

    local Resizer = Library:Create('Frame', {
        SizeConstraint = Enum.SizeConstraint.RelativeXX;
        BackgroundColor3 = Color3.new(0, 0, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.new(0, 30, 0, 30);
        Position = UDim2.new(1, -30, 1, -30);
        Visible = true;
        ClipsDescendants = true;
        ZIndex = 1;
        Parent = Instance;
    })

    local ResizerImage = Library:Create('ImageButton', {
        BackgroundColor3 = Library.AccentColor;
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Size = UDim2.new(2, 0, 2, 0);
        Position = UDim2.new(1, -30, 1, -30);
        ZIndex = 2;
        Parent = Resizer;
    })

    local ResizerImageUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(1, 0);
        Parent = ResizerImage;
    })

    Library:AddToRegistry(ResizerImage, { BackgroundColor3 = 'AccentColor'; })

    Resizer.Size = UDim2.fromOffset(ResizerImage_Size, ResizerImage_Size)
    Resizer.Position = UDim2.new(1, -ResizerImage_Size, 1, -ResizerImage_Size)
    MinSize = MinSize or Library.MinSize

    local OffsetPos
    Resizer.Parent = Instance

    local function FinishResize(Transparency)
        ResizerImage.Position = UDim2.new()
        ResizerImage.Size = UDim2.new(2, 0, 2, 0)
        ResizerImage.Parent = Resizer
        ResizerImage.BackgroundTransparency = Transparency
        ResizerImageUICorner.Parent = ResizerImage
        OffsetPos = nil
    end

    ResizerImage.MouseButton1Down:Connect(function()
        if not OffsetPos then
            OffsetPos = Vector2.new(Mouse.X - (Instance.AbsolutePosition.X + Instance.AbsoluteSize.X), Mouse.Y - (Instance.AbsolutePosition.Y + Instance.AbsoluteSize.Y))

            ResizerImage.BackgroundTransparency = 1
            ResizerImage.Size = UDim2.fromOffset(Library.ScreenGui.AbsoluteSize.X, Library.ScreenGui.AbsoluteSize.Y)
            ResizerImage.Position = UDim2.new()
            ResizerImageUICorner.Parent = nil
            ResizerImage.Parent = Library.ScreenGui
        end
    end)

    ResizerImage.MouseMoved:Connect(function()
        if OffsetPos then		
            local MousePos = Vector2.new(Mouse.X - OffsetPos.X, Mouse.Y - OffsetPos.Y)
            local FinalSize = Vector2.new(math.clamp(MousePos.X - Instance.AbsolutePosition.X, MinSize.X, math.huge), math.clamp(MousePos.Y - Instance.AbsolutePosition.Y, MinSize.Y, math.huge))
            Instance.Size = UDim2.fromOffset(FinalSize.X, FinalSize.Y)
        end
    end)

    ResizerImage.MouseEnter:Connect(function()
        FinishResize(ResizerImage_HoverTransparency)
    end)

    ResizerImage.MouseLeave:Connect(function()
        FinishResize(1)
    end)

    ResizerImage.MouseButton1Up:Connect(function()
        FinishResize(ResizerImage_HoverTransparency)
    end)
end

function Library:AddToolTip(InfoStr, DisabledInfoStr, HoverInstance)
    InfoStr = typeof(InfoStr) == "string" and InfoStr or nil
    DisabledInfoStr = typeof(DisabledInfoStr) == "string" and DisabledInfoStr or nil

    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        ZIndex = 100;
        Parent = Library.ScreenGui;
        Visible = false;
    })

    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = Tooltip;
    })

    local UIStroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        Thickness = 1;
        Parent = Tooltip;
    })

    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(8, 4);
        TextSize = 14;
        Text = InfoStr;
        TextColor3 = Library.FontColor;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1;
        Parent = Tooltip;
    })

    Library:AddToRegistry(Tooltip, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    })

    Library:AddToRegistry(UIStroke, {
        Color = 'AccentColor';
    })

    Library:AddToRegistry(Label, {
        TextColor3 = 'FontColor',
    })

    local TooltipTable = {
        Tooltip = Tooltip;
        Disabled = false;
        Signals = {};
    }
    local IsHovering = false

    local function UpdateText(Text)
        if Text == nil then return end

        local X, Y = Library:GetTextBounds(Text, Library.Font, 14 * DPIScale)

        Label.Text = Text
        Tooltip.Size = UDim2.fromOffset(X + 16, Y + 8)
        Label.Size = UDim2.fromOffset(X, Y)
    end

    local function GiveSignal(Connection)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    UpdateText(InfoStr)

    GiveSignal(HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then
            Tooltip.Visible = false
            return
        end

        if not TooltipTable.Disabled then
            if InfoStr == nil or InfoStr == "" then
                Tooltip.Visible = false
                return
            end

            if Label.Text ~= InfoStr then
                UpdateText(InfoStr)
            end
        else
            if DisabledInfoStr == nil or DisabledInfoStr == "" then
                Tooltip.Visible = false
                return
            end

            if Label.Text ~= DisabledInfoStr then 
                UpdateText(DisabledInfoStr)
            end
        end

        IsHovering = true

        Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        Tooltip.Visible = true

        while IsHovering do
            if TooltipTable.Disabled == true and DisabledInfoStr == nil then break end

            RunService.Heartbeat:Wait()
            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
        end

        IsHovering = false
        Tooltip.Visible = false
    end))

    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end))
    
    if LibraryMainOuterFrame then
        GiveSignal(LibraryMainOuterFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if LibraryMainOuterFrame.Visible == false then
                IsHovering = false
                Tooltip.Visible = false
            end
        end))
    end

    function TooltipTable:Destroy()
        for Idx = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Idx)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        Tooltip:Destroy()
    end

    table.insert(Tooltips, TooltipTable)
    return TooltipTable
end

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault, condition)
    if not HighlightInstance or not Instance then return end
    
    local function undoHighlight()
        local Reg = Library.RegistryMap[Instance]

        for Property, ColorIdx in next, PropertiesDefault do
            if Instance[Property] ~= nil then
                Instance[Property] = Library[ColorIdx] or ColorIdx

                if Reg and Reg.Properties[Property] then
                    Reg.Properties[Property] = ColorIdx
                end
            end
        end
    end

    local function doHighlight()
        if condition and not condition() then 
            undoHighlight()
            return 
        end

        local Reg = Library.RegistryMap[Instance]

        for Property, ColorIdx in next, Properties do
            if Instance[Property] ~= nil then
                Instance[Property] = Library[ColorIdx] or ColorIdx

                if Reg and Reg.Properties[Property] then
                    Reg.Properties[Property] = ColorIdx
                end
            end
        end
    end

    HighlightInstance.MouseEnter:Connect(doHighlight)
    HighlightInstance.MouseMoved:Connect(doHighlight)
    HighlightInstance.MouseLeave:Connect(undoHighlight)
end

function Library:MouseIsOverOpenedFrame(Input)
    if not Mouse then return false end
    
    local Pos
    if Library.IsMobile and Input then 
        Pos = Input.Position
    else
        Pos = Vector2.new(Mouse.X, Mouse.Y)
    end

    for Frame, _ in next, Library.OpenedFrames do
        if Frame and Frame.Parent then
            local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize

            if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X
                and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then

                return true
            end
        end
    end

    return false
end

function Library:MouseIsOverFrame(Frame, Input)
    if not Frame then return false end
    
    local Pos
    if Library.IsMobile and Input then 
        Pos = Input.Position
    else
        if Mouse and Mouse.X then
            Pos = Vector2.new(Mouse.X, Mouse.Y)
        else
            return false
        end
    end
    
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize

    if Pos.X >= AbsPos.X and Pos.X <= AbsPos.X + AbsSize.X
        and Pos.Y >= AbsPos.Y and Pos.Y <= AbsPos.Y + AbsSize.Y then

        return true
    end

    return false
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in next, Library.DependencyBoxes do
        if Depbox.Update then
            Depbox:Update()
        end
    end
end

function Library:UpdateDependencyGroupboxes()
    for _, Depbox in next, Library.DependencyGroupboxes do
        if Depbox.Update then
            Depbox:Update()
        end
    end
end

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB
end

function Library:GetTextBounds(Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text:gsub("<%/?[%w:]+[^>]*>", ""), Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color)
    return Color3.fromHSV(H, S, V / 1.5)
end
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)

function Library:AddToRegistry(Instance, Properties, IsHud)
    if not Instance then return end
    
    local Idx = #Library.Registry + 1
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    }

    table.insert(Library.Registry, Data)
    Library.RegistryMap[Instance] = Data

    if IsHud then
        table.insert(Library.HudRegistry, Data)
    end
end

function Library:RemoveFromRegistry(Instance)
    if not Instance then return end
    
    local Data = Library.RegistryMap[Instance]

    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx)
            end
        end

        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx)
            end
        end

        Library.RegistryMap[Instance] = nil
    end
end

function Library:UpdateColorsUsingRegistry()
    for Idx, Object in next, Library.Registry do
        if Object.Instance and Object.Instance.Parent then
            for Property, ColorIdx in next, Object.Properties do
                if typeof(ColorIdx) == "string" then
                    if Library[ColorIdx] then
                        Object.Instance[Property] = Library[ColorIdx]
                    end
                elseif typeof(ColorIdx) == 'function' then
                    Object.Instance[Property] = ColorIdx()
                end
            end
        end
    end
end

function Library:GiveSignal(Connection)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function Library:Unload()
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    for _, UnloadCallback in Library.UnloadSignals do
        Library:SafeCallback(UnloadCallback)
    end

    for _, Tooltip in Tooltips do
        if Tooltip.Destroy then
            Library:SafeCallback(Tooltip.Destroy, Tooltip)
        end
    end

    Library.Unloaded = true
    ScreenGui:Destroy()

    getgenv().Linoria = nil
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if Library.Unloaded then
        return
    end

    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance)
    end
end))

local Templates = {
    Window = {
        Title = "No Title",
        AutoShow = false,
        Position = UDim2.fromOffset(175, 50),
        Size = UDim2.fromOffset(0, 0),
        AnchorPoint = Vector2.zero,
        TabPadding = 1,
        MenuFadeTime = 0.2,
        NotifySide = "Left",
        ShowCustomCursor = true,
        UnlockMouseWhileOpen = true,
        Center = false
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    }
}

local BaseAddons = {}
do
    local BaseAddonsFuncs = {}

    function BaseAddonsFuncs:AddKeyPicker(Idx, Info)
        local ParentObj = self
        local ToggleLabel = self.TextLabel

        assert(Info.Default, string.format('AddKeyPicker (IDX: %s): Missing default value.', tostring(Idx)))

        local KeyPicker = {
            Value = nil;
            Modifiers = {};
            DisplayValue = nil;
            Toggled = false;
            Mode = Info.Mode or 'Toggle';
            Type = 'KeyPicker';
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;
            SyncToggleState = Info.SyncToggleState or false;
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label", "KeyPicker with the mode 'Press' can be only applied on Labels.")
            
            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { 'Toggle', 'Hold' }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false

        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3"
        }

        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,
            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,
            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,
            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",
            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",
            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",
            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock"
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then continue end
                if not InputService:IsKeyDown(Input) then continue end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then 
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then continue end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then 
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return InputService:IsMouseButtonPressed(Input.UserInputType) and not InputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return InputService:IsKeyDown(Input.KeyCode) and not InputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then continue end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        local PickOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 28, 0, 15);
            ZIndex = 6;
            Parent = ToggleLabel;
        })

        local PickInner = Library:Create('Frame', {
            BackgroundColor3 = Library.SecondaryColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 7;
            Parent = PickOuter;
        })

        local UICorner = Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 4);
            Parent = PickInner;
        })

        Library:AddToRegistry(PickInner, {
            BackgroundColor3 = 'SecondaryColor';
            BorderColor3 = 'OutlineColor';
        })

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13;
            Text = Info.Default;
            TextWrapped = true;
            ZIndex = 8;
            Parent = PickInner;
        })

        local KeybindsToggle = {}
        do
            local KeybindsToggleContainer = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 18);
                Visible = false;
                ZIndex = 110;
                Parent = Library.KeybindContainer;
            })

            local KeybindsToggleOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 13, 0, 13);
                Position = UDim2.new(0, 0, 0, 6);
                Visible = true;
                ZIndex = 110;
                Parent = KeybindsToggleContainer;
            })

            Library:AddToRegistry(KeybindsToggleOuter, {
                BorderColor3 = 'Black';
            })

            local KeybindsToggleInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 111;
                Parent = KeybindsToggleOuter;
            })

            Library:AddToRegistry(KeybindsToggleInner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            })

            local KeybindsToggleLabel = Library:CreateLabel({
                BackgroundTransparency = 1;
                Size = UDim2.new(0, 216, 1, 0);
                Position = UDim2.new(1, 6, 0, -1);
                TextSize = 14;
                Text = "";
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 111;
                Parent = KeybindsToggleInner;
            })

            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = KeybindsToggleLabel;
            })

            local KeybindsToggleRegion = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Size = UDim2.new(0, 170, 1, 0);
                ZIndex = 113;
                Parent = KeybindsToggleOuter;
            })

            Library:OnHighlight(KeybindsToggleRegion, KeybindsToggleOuter,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' },
                function()
                    return true
                end
            )

            function KeybindsToggle:Display(State)
                KeybindsToggleInner.BackgroundColor3 = State and Library.AccentColor or Library.MainColor
                KeybindsToggleInner.BorderColor3 = State and Library.AccentColorDark or Library.OutlineColor
                KeybindsToggleLabel.TextColor3 = State and Library.AccentColor or Library.FontColor

                if Library.RegistryMap[KeybindsToggleInner] then
                    Library.RegistryMap[KeybindsToggleInner].Properties.BackgroundColor3 = State and 'AccentColor' or 'MainColor'
                    Library.RegistryMap[KeybindsToggleInner].Properties.BorderColor3 = State and 'AccentColorDark' or 'OutlineColor'
                end
                
                if Library.RegistryMap[KeybindsToggleLabel] then
                    Library.RegistryMap[KeybindsToggleLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor'
                end
            end

            function KeybindsToggle:SetText(Text)
                KeybindsToggleLabel.Text = Text
            end

            function KeybindsToggle:SetVisibility(bool)
                KeybindsToggleContainer.Visible = bool
            end

            function KeybindsToggle:SetNormal(bool)
                KeybindsToggle.Normal = bool

                KeybindsToggleOuter.BackgroundTransparency = if KeybindsToggle.Normal then 1 else 0

                KeybindsToggleInner.BackgroundTransparency = if KeybindsToggle.Normal then 1 else 0
                KeybindsToggleInner.BorderSizePixel = if KeybindsToggle.Normal then 0 else 1

                KeybindsToggleLabel.Position = if KeybindsToggle.Normal then UDim2.new(1, -13, 0, -1) else UDim2.new(1, 6, 0, -1)
            end

            KeyPicker.DoClick = function(...) end
            Library:GiveSignal(KeybindsToggleRegion.InputBegan:Connect(function(Input)
                if Library.Unloaded then
                    return
                end

                if KeybindsToggle.Normal then return end
                                        
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                end
            end))

            KeybindsToggle.Loaded = true
        end

        local ModeSelectOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 80, 0, 0);
            Visible = false;
            ZIndex = 14;
            Parent = ScreenGui;
        })

        local function UpdateMenuOuterPos()
            ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y)
        end

        UpdateMenuOuterPos()
        ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(UpdateMenuOuterPos)

        local ModeSelectInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 0, 3);
            ZIndex = 15;
            Parent = ModeSelectOuter;
        })

        local UICorner2 = Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 4);
            Parent = ModeSelectInner;
        })

        Library:AddToRegistry(ModeSelectInner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        })

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        })

        local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' }
        local ModeButtons = {}
        local UnbindButton = {}

        for Idx, Mode in next, Modes do
            local ModeButton = {}

            local Label = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = Mode;
                ZIndex = 16;
                Parent = ModeSelectInner;
            })
            ModeSelectInner.Size = ModeSelectInner.Size + UDim2.new(0, 0, 0, 15)
            ModeSelectOuter.Size = ModeSelectOuter.Size + UDim2.new(0, 0, 0, 18)

            function ModeButton:Select()
                for _, Button in next, ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Label.TextColor3 = Library.AccentColor
                if Library.RegistryMap[Label] then
                    Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor'
                end

                ModeSelectOuter.Visible = false
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Label.TextColor3 = Library.FontColor
                if Library.RegistryMap[Label] then
                    Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor'
                end
            end

            Label.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    ModeButton:Select()
                end
            end)

            if Mode == KeyPicker.Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        do
            local UnbindInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Position = UDim2.new(0, 0, 0, ModeSelectInner.Size.Y.Offset + 3);
                Size = UDim2.new(1, 0, 0, 18);
                ZIndex = 15;
                Parent = ModeSelectOuter;
            })

            ModeSelectOuter.Size = ModeSelectOuter.Size + UDim2.new(0, 0, 0, 18)

            Library:AddToRegistry(UnbindInner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            })

            local UnbindLabel = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = "解除绑定";
                ZIndex = 16;
                Parent = UnbindInner;
            })

            KeyPicker.SetValue = function(...) end
            function UnbindButton:UnbindKey()
                KeyPicker:SetValue({ nil, KeyPicker.Mode, {} })
                ModeSelectOuter.Visible = false
            end

            UnbindLabel.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    UnbindButton:UnbindKey()
                end
            end)
        end

        function KeyPicker:Display(Text)
            DisplayLabel.Text = Text or KeyPicker.DisplayValue

            PickOuter.Size = UDim2.new(0, 999999, 0, 18)
            RunService.RenderStepped:Wait()
            PickOuter.Size = UDim2.new(0, math.max(28, DisplayLabel.TextBounds.X + 8), 0, 18)
        end

        function KeyPicker:Update()
            if Info.NoUI then
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == 'Toggle'

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if KeybindsToggle.Loaded then
                KeybindsToggle:SetNormal(not ShowToggle)

                KeybindsToggle:SetVisibility(true)
                KeybindsToggle:SetText(string.format('[%s] %s (%s)', tostring(KeyPicker.DisplayValue), tostring(Info.Text), tostring(KeyPicker.Mode or 'Toggle')))
                KeybindsToggle:Display(State)
            end

            local YSize = 0
            local XSize = 0

            for _, Frame in next, Library.KeybindContainer:GetChildren() do
                if Frame:IsA('Frame') and Frame.Visible then
                    YSize = YSize + 18
                    local Label = Frame:FindFirstChild("TextLabel", true)
                    if not Label then continue end
                    
                    local LabelSize = Label.TextBounds.X + 20
                    if (LabelSize > XSize) then
                        XSize = LabelSize
                    end
                end
            end

            Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10, 220), 0, (YSize + 23 + 6) * DPIScale)
            UpdateMenuOuterPos()
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then
                return true
            
            elseif KeyPicker.Mode == 'Hold' then
                local Key = KeyPicker.Value
                if Key == 'None' then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    return InputService:IsMouseButtonPressed(SpecialKeys[Key]) and not InputService:GetFocusedTextBox()
                else
                    return InputService:IsKeyDown(Enum.KeyCode[Key]) and not InputService:GetFocusedTextBox()
                end

            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:SetValue(Data, SkipCallback)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, UserInputType = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end
                
                if SpecialKeys[Key] == nil then 
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers = VerifyModifiers((typeof(Modifiers) == "table") and Modifiers or KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0 then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value) else KeyPicker.Value

            DisplayLabel.Text = KeyPicker.DisplayValue

            if Mode ~= nil and ModeButtons[Mode] ~= nil then 
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Display()
            KeyPicker:Update()

            if SkipCallback == true then return end
            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, UserInputType, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, UserInputType, NewModifiers)
        end

        function KeyPicker:OnClick(Callback)
            KeyPicker.Clicked = Callback
        end

        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback
        end

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        function KeyPicker:DoClick()
            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:SetModePickerVisibility(bool)
            ModeSelectOuter.Visible = bool
        end

        function KeyPicker:GetModePickerVisibility()
            return ModeSelectOuter.Visible
        end

        PickOuter.InputBegan:Connect(function(PickerInput)
            if PickerInput.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                Picking = true

                KeyPicker:Display("...")

                local Input
                local ActiveModifiers = {}

                local GetInput = function()
                    Input = InputService.InputBegan:Wait()
                    if InputService:GetFocusedTextBox() then
                        return true
                    end

                    return false
                end

                repeat
                    task.wait()

                    KeyPicker:Display("...")

                    if GetInput() then
                        Picking = false
                        KeyPicker:Update()
                        return
                    end

                    if Input.KeyCode == Enum.KeyCode.Escape then
                        break
                    end

                    if IsModifierInput(Input) then
                        local StopLoop = false

                        repeat
                            task.wait()
                            if InputService:IsKeyDown(Input.KeyCode) then
                                task.wait(0.075)

                                if InputService:IsKeyDown(Input.KeyCode) then
                                    if not table.find(ActiveModifiers, ModifiersInput[Input.KeyCode]) then
                                        ActiveModifiers[#ActiveModifiers + 1] = ModifiersInput[Input.KeyCode]
                                        KeyPicker:Display(table.concat(ActiveModifiers, " + ") .. " + ...")
                                    end

                                    if GetInput() then
                                        StopLoop = true
                                        break
                                    end

                                    if Input.KeyCode == Enum.KeyCode.Escape then
                                        break
                                    end

                                    if not IsModifierInput(Input) then
                                        break
                                    end
                                else
                                    if not table.find(ActiveModifiers, ModifiersInput[Input.KeyCode]) then
                                        break
                                    end
                                end
                            end
                        until false

                        if StopLoop then
                            Picking = false
                            KeyPicker:Update()
                            return
                        end
                    end

                    break
                until false

                local Key = "Unknown"
                if SpecialKeysInput[Input.UserInputType] ~= nil then
                    Key = SpecialKeysInput[Input.UserInputType]
                elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                    Key = Input.KeyCode == Enum.KeyCode.Escape and "None" or Input.KeyCode.Name
                end

                ActiveModifiers = if Input.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

                KeyPicker.Toggled = false
                KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

                repeat task.wait() until not IsInputDown(Input) or InputService:GetFocusedTextBox()
                Picking = false

            elseif PickerInput.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                local visible = KeyPicker:GetModePickerVisibility()
                
                if visible == false then
                    for _, option in next, Options do
                        if option.Type == "KeyPicker" then
                            option:SetModePickerVisibility(false)
                        end
                    end
                end

                KeyPicker:SetModePickerVisibility(not visible)
            end
        end)

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if Library.Unloaded then
                return
            end

            if KeyPicker.Value == "Unknown" then return end
        
            if (not Picking) and (not InputService:GetFocusedTextBox()) then
                local Key = KeyPicker.Value
                local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
                local HoldingKey = false

                if HoldingModifiers then
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode.Name == Key then
                            HoldingKey = true
                        end
                    elseif SpecialKeysInput[Input.UserInputType] == Key then
                        HoldingKey = true
                    end
                end

                if KeyPicker.Mode == 'Toggle' then
                    if HoldingKey then
                        KeyPicker.Toggled = not KeyPicker.Toggled
                        KeyPicker:DoClick()
                    end
                elseif KeyPicker.Mode == "Press" then
                    if HoldingKey then
                        KeyPicker:DoClick()
                    end
                end

                KeyPicker:Update()
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize

                if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                    or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                    KeyPicker:SetModePickerVisibility(false)
                end
            end
        end))

        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if Library.Unloaded then
                return
            end

            if (not Picking) then
                KeyPicker:Update()
            end
        end))
        
        KeyPicker:SetValue({ Info.Default, Info.Mode or "Toggle", Info.DefaultModifiers }, true)
        KeyPicker.DisplayFrame = PickOuter

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        Options[Idx] = KeyPicker

        return KeyPicker
    end
    
    function BaseAddonsFuncs:AddColorPicker(Idx, Info)
    local ParentObj = self
    local ToggleLabel = self.TextLabel

    assert(Info.Default, string.format('AddColorPicker (IDX: %s): Missing default value.', tostring(Idx)))

    local ColorPicker = {
        Value = Info.Default;
        Transparency = Info.Transparency or 0;
        Type = 'ColorPicker';
        Title = typeof(Info.Title) == "string" and Info.Title or 'Color picker';
        Callback = Info.Callback or function(Color) end;
    }

    ColorPicker.SetHSVFromRGB = function(self, Color)
        local H, S, V = Color:ToHSV()
        self.Hue = H
        self.Sat = S
        self.Vib = V
    end

    ColorPicker:SetHSVFromRGB(ColorPicker.Value)

    local DisplayFrame = Library:Create('Frame', {
        BackgroundColor3 = ColorPicker.Value;
        BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(0, 28, 0, 15);
        ZIndex = 6;
        Parent = ToggleLabel;
    })

    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 4);
        Parent = DisplayFrame;
    })

    Library:Create('ImageLabel', {
        BorderSizePixel = 0;
        Size = UDim2.new(0, 27, 0, 13);
        ZIndex = 5;
        Image = CustomImageManager.GetAsset("Checker");
        Visible = not not Info.Transparency;
        Parent = DisplayFrame;
    })

    local PickerFrameOuter = Library:Create('Frame', {
        Name = 'Color';
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
        Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
        Visible = false;
        ZIndex = 15;
        Parent = ScreenGui,
    })

    DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
        PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18)
    end)

    local PickerFrameInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 16;
        Parent = PickerFrameOuter;
    })

    local UICorner2 = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = PickerFrameInner;
    })

    local UIStroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        Thickness = 1;
        Parent = PickerFrameInner;
    })

    local Highlight = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 17;
        Parent = PickerFrameInner;
    })

    local SatVibMapOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 4, 0, 25);
        Size = UDim2.new(0, 200, 0, 200);
        ZIndex = 17;
        Parent = PickerFrameInner;
    })

    local SatVibMapInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 18;
        Parent = SatVibMapOuter;
    })

    local SatVibMap = Library:Create('ImageLabel', {
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 18;
        Image = CustomImageManager.GetAsset("SaturationMap");
        Parent = SatVibMapInner;
    })

    local CursorOuter = Library:Create('ImageLabel', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.new(0, 6, 0, 6);
        BackgroundTransparency = 1;
        Image = CustomImageManager.GetAsset("Cursor");
        ImageColor3 = Color3.new(0, 0, 0);
        ZIndex = 19;
        Parent = SatVibMap;
    })

    Library:Create('ImageLabel', {
        Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
        Position = UDim2.new(0, 1, 0, 1);
        BackgroundTransparency = 1;
        Image = CustomImageManager.GetAsset("Cursor");
        ZIndex = 20;
        Parent = CursorOuter;
    })

    local HueSelectorOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 208, 0, 25);
        Size = UDim2.new(0, 15, 0, 200);
        ZIndex = 17;
        Parent = PickerFrameInner;
    })

    local HueSelectorInner = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 18;
        Parent = HueSelectorOuter;
    })

    local HueCursor = Library:Create('Frame', { 
        BackgroundColor3 = Color3.new(1, 1, 1);
        AnchorPoint = Vector2.new(0, 0.5);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(1, 0, 0, 1);
        ZIndex = 18;
        Parent = HueSelectorInner;
    })

    local HueBoxOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.fromOffset(4, 228),
        Size = UDim2.new(0.5, -6, 0, 20),
        ZIndex = 18,
        Parent = PickerFrameInner;
    })

    local HueBoxInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 18,
        Parent = HueBoxOuter;
    })

    Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
        });
        Rotation = 90;
        Parent = HueBoxInner;
    })

    local HueBox = Library:Create('TextBox', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -5, 1, 0);
        Font = Library.Font;
        PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
        PlaceholderText = 'Hex颜色';
        Text = '#FFFFFF';
        TextColor3 = Library.FontColor;
        TextSize = 14;
        TextStrokeTransparency = 0;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 20,
        Parent = HueBoxInner;
    })

    Library:ApplyTextStroke(HueBox)

    local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
        Position = UDim2.new(0.5, 2, 0, 228),
        Size = UDim2.new(0.5, -6, 0, 20),
        Parent = PickerFrameInner
    })

    local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
        Text = '255, 255, 255',
        PlaceholderText = 'RGB颜色',
        TextColor3 = Library.FontColor
    })

    local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor
    
    if Info.Transparency then 
        TransparencyBoxOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(4, 251);
            Size = UDim2.new(1, -8, 0, 15);
            ZIndex = 19;
            Parent = PickerFrameInner;
        })

        TransparencyBoxInner = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 19;
            Parent = TransparencyBoxOuter;
        })

        Library:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' })

        Library:Create('ImageLabel', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Image = CustomImageManager.GetAsset("CheckerLong");
            ZIndex = 20;
            Parent = TransparencyBoxInner;
        })

        TransparencyCursor = Library:Create('Frame', { 
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0.5, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 1, 1, 0);
            ZIndex = 21;
            Parent = TransparencyBoxInner;
        })
    end

    Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 14);
        Position = UDim2.fromOffset(5, 5);
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = 14;
        Text = ColorPicker.Title;
        TextWrapped = false;
        ZIndex = 16;
        Parent = PickerFrameInner;
    })

    local ContextMenu = {}
    do
        ContextMenu.Options = {}
        ContextMenu.Container = Library:Create('Frame', {
            BorderColor3 = Color3.new();
            ZIndex = 14;
            Visible = false;
            Parent = ScreenGui
        })

        ContextMenu.Inner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.fromScale(1, 1);
            ZIndex = 15;
            Parent = ContextMenu.Container;
        })

        local UICorner3 = Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 6);
            Parent = ContextMenu.Inner;
        })

        Library:Create('UIListLayout', {
            Name = 'Layout';
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ContextMenu.Inner;
        })

        Library:Create('UIPadding', {
            Name = 'Padding';
            PaddingLeft = UDim.new(0, 4);
            Parent = ContextMenu.Inner;
        })

        local function updateMenuPosition()
            ContextMenu.Container.Position = UDim2.fromOffset(
                (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
                DisplayFrame.AbsolutePosition.Y + 1
            )
        end

        local function updateMenuSize()
            local menuWidth = 60
            for i, label in next, ContextMenu.Inner:GetChildren() do
                if label:IsA('TextLabel') then
                    menuWidth = math.max(menuWidth, label.TextBounds.X)
                end
            end

            ContextMenu.Container.Size = UDim2.fromOffset(
                menuWidth + 8,
                ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
            )
        end

        DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
        ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

        task.spawn(updateMenuPosition)
        task.spawn(updateMenuSize)

        Library:AddToRegistry(ContextMenu.Inner, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        })

        function ContextMenu:Show()
            if Library.IsMobile then
                Library.CanDrag = false
            end

            self.Container.Visible = true
        end

        function ContextMenu:Hide()
            if Library.IsMobile then
                Library.CanDrag = true
            end
            
            self.Container.Visible = false
        end

        function ContextMenu:AddOption(Str, Callback)
            if typeof(Callback) ~= 'function' then
                Callback = function() end
            end

            local Button = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = Str;
                ZIndex = 16;
                Parent = self.Inner;
                TextXAlignment = Enum.TextXAlignment.Left,
            })

            Library:OnHighlight(Button, Button, 
                { TextColor3 = 'AccentColor' },
                { TextColor3 = 'FontColor' }
            )

            Button.InputBegan:Connect(function(Input)
                if Input.UserInputType ~= Enum.UserInputType.MouseButton1 or Input.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end

                Callback()
            end)
        end

        ContextMenu:AddOption('复制颜色', function()
            Library.ColorClipboard = ColorPicker.Value
            Library:Notify('颜色已复制!', 2)
        end)

        ColorPicker.SetValueRGB = function(...) end
        ContextMenu:AddOption('粘贴颜色', function()
            if not Library.ColorClipboard then
                Library:Notify('您尚未复制任何颜色!', 2)
                return
            end

            ColorPicker:SetValueRGB(Library.ColorClipboard)
        end)

        ContextMenu:AddOption('复制HEX', function()
            pcall(setclipboard, ColorPicker.Value:ToHex())
            Library:Notify('HEX代码已复制到剪贴板!', 2)
        end)

        ContextMenu:AddOption('复制RGB', function()
            pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
            Library:Notify('RGB值已复制到剪贴板!', 2)
        end)
    end
    ColorPicker.ContextMenu = ContextMenu

    Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; })
    Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; })
    Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; })
    Library:AddToRegistry(UIStroke, { Color = 'AccentColor'; })

    Library:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; })
    Library:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; })
    Library:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', })
    Library:AddToRegistry(HueBox, { TextColor3 = 'FontColor', })

    local SequenceTable = {}

    for Hue = 0, 1, 0.1 do
        table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end

    Library:Create('UIGradient', {
        Color = ColorSequence.new(SequenceTable);
        Rotation = 90;
        Parent = HueSelectorInner;
    })

    ColorPicker.Display = function(self)
        self.Value = Color3.fromHSV(self.Hue, self.Sat, self.Vib)
        SatVibMap.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1)

        Library:Create(DisplayFrame, {
            BackgroundColor3 = self.Value;
            BackgroundTransparency = self.Transparency;
            BorderColor3 = Library:GetDarkerColor(self.Value);
        })

        if TransparencyBoxInner then
            TransparencyBoxInner.BackgroundColor3 = self.Value
            TransparencyCursor.Position = UDim2.new(1 - self.Transparency, 0, 0, 0)
        end

        CursorOuter.Position = UDim2.new(self.Sat, 0, 1 - self.Vib, 0)
        HueCursor.Position = UDim2.new(0, 0, self.Hue, 0)

        HueBox.Text = '#' .. self.Value:ToHex()
        RgbBox.Text = table.concat({ math.floor(self.Value.R * 255), math.floor(self.Value.G * 255), math.floor(self.Value.B * 255) }, ', ')
    end

    function ColorPicker:OnChanged(Func)
        ColorPicker.Changed = Func
    end

    if ParentObj.Addons then
        table.insert(ParentObj.Addons, ColorPicker)
    end

    function ColorPicker:Show()
        for Frame, Val in next, Library.OpenedFrames do
            if Frame.Name == 'Color' then
                Frame.Visible = false
                Library.OpenedFrames[Frame] = nil
            end
        end

        PickerFrameOuter.Visible = true
        Library.OpenedFrames[PickerFrameOuter] = true
    end

    function ColorPicker:Hide()
        PickerFrameOuter.Visible = false
        Library.OpenedFrames[PickerFrameOuter] = nil
    end

    function ColorPicker:SetValue(HSV, Transparency)
        if typeof(HSV) == "Color3" then
            ColorPicker:SetValueRGB(HSV, Transparency)
            return
        end

        local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

        ColorPicker.Transparency = Transparency or 0
        ColorPicker:SetHSVFromRGB(Color)
        ColorPicker:Display()

        Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value, ColorPicker.Transparency)
        Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value, ColorPicker.Transparency)
    end

    ColorPicker.SetValueRGB = function(self, Color, Transparency)
        if self._settingValue then return end
        self._settingValue = true
        
        self.Transparency = Transparency or 0
        self:SetHSVFromRGB(Color)
        self:Display()
        
        self._settingValue = false

        Library:SafeCallback(self.Callback, self.Value, self.Transparency)
        Library:SafeCallback(self.Changed, self.Value, self.Transparency)
    end

    HueBox.FocusLost:Connect(function(enter)
        if enter then
            local success, result = pcall(Color3.fromHex, HueBox.Text)
            if success and typeof(result) == 'Color3' then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
            end
        end

        ColorPicker:Display()
    end)

    RgbBox.FocusLost:Connect(function(enter)
        if enter then
            local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
            if r and g and b then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
            end
        end

        ColorPicker:Display()
    end)

    SatVibMap.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                local MinX = SatVibMap.AbsolutePosition.X
                local MaxX = MinX + SatVibMap.AbsoluteSize.X
                local MouseX = math.clamp(Mouse.X, MinX, MaxX)

                local MinY = SatVibMap.AbsolutePosition.Y
                local MaxY = MinY + SatVibMap.AbsoluteSize.Y
                local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY))
                ColorPicker:Display()
                Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value, ColorPicker.Transparency)
                Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value, ColorPicker.Transparency)

                RunService.RenderStepped:Wait()
            end

            Library:AttemptSave()
        end
    end)

    HueSelectorInner.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                local MinY = HueSelectorInner.AbsolutePosition.Y
                local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y
                local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY))
                ColorPicker:Display()
                Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value, ColorPicker.Transparency)
                Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value, ColorPicker.Transparency)

                RunService.RenderStepped:Wait()
            end

            Library:AttemptSave()
        end
    end)

    DisplayFrame.InputBegan:Connect(function(Input)
        if Library:MouseIsOverOpenedFrame(Input) then
            return
        end

        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if PickerFrameOuter.Visible then
                ColorPicker:Hide()
            else
                ContextMenu:Hide()
                ColorPicker:Show()
            end
        elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
            ContextMenu:Show()
            ColorPicker:Hide()
        end
    end)

    if TransparencyBoxInner then
        TransparencyBoxInner.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                    local MinX = TransparencyBoxInner.AbsolutePosition.X
                    local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X
                    local MouseX = math.clamp(Mouse.X, MinX, MaxX)

                    ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX))

                    ColorPicker:Display()

                    RunService.RenderStepped:Wait()
                end

                Library:AttemptSave()
            end
        end)
    end

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
        if Library.Unloaded then
            return
        end

        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize

            if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                ColorPicker:Hide()
            end

            if not Library:MouseIsOverFrame(ContextMenu.Container) then
                ContextMenu:Hide()
            end
        end

        if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
            if not Library:MouseIsOverFrame(ContextMenu.Container) and not Library:MouseIsOverFrame(DisplayFrame) then
                ContextMenu:Hide()
            end
        end
    end))

    ColorPicker:Display()
    ColorPicker.DisplayFrame = DisplayFrame

    ColorPicker.Default = ColorPicker.Value

    Options[Idx] = ColorPicker

    return ColorPicker
end

function BaseAddonsFuncs:AddDropdown(Idx, Info)
    Info.ReturnInstanceInstead = if typeof(Info.ReturnInstanceInstead) == "boolean" then Info.ReturnInstanceInstead else false

    if Info.SpecialType == 'Player' then
        Info.ExcludeLocalPlayer = if typeof(Info.ExcludeLocalPlayer) == "boolean" then Info.ExcludeLocalPlayer else false

        Info.Values = GetPlayers(Info.ExcludeLocalPlayer, Info.ReturnInstanceInstead)
        Info.AllowNull = true
    elseif Info.SpecialType == 'Team' then
        Info.Values = GetTeams(Info.ReturnInstanceInstead)
        Info.AllowNull = true
    end

    assert(Info.Values, string.format('AddDropdown (IDX: %s): Missing dropdown value list.', tostring(Idx)))
    if not (Info.AllowNull or Info.Default) then
        Info.Default = 1
        warn(string.format('AddDropdown (IDX: %s): Missing default value, selected the first index instead. Pass `AllowNull` as true if this was intentional.', tostring(Idx)))
    end

    Info.Searchable = if typeof(Info.Searchable) == "boolean" then Info.Searchable else false
    Info.FormatDisplayValue = if typeof(Info.FormatDisplayValue) == "function" then Info.FormatDisplayValue else nil

    local Dropdown = {
        Values = Info.Values;
        Value = Info.Multi and {};
        DisabledValues = Info.DisabledValues or {};

        Multi = Info.Multi;
        Type = 'Dropdown';
        SpecialType = Info.SpecialType;
        Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        Callback = Info.Callback or function(Value) end;
        Changed = Info.Changed or function(Value) end;

        OriginalText = Info.Text; Text = Info.Text;
        ExcludeLocalPlayer = Info.ExcludeLocalPlayer;
        ReturnInstanceInstead = Info.ReturnInstanceInstead;
    }

    local Tooltip

    local ParentObj = self
    local ToggleLabel = self.TextLabel
    local Container = self.Container

    local RelativeOffset = 0

    for _, Element in next, Container:GetChildren() do
        if Element:IsA('GuiObject') then
            RelativeOffset = RelativeOffset + Element.Size.Y.Offset
        end
    end

    local DropdownOuter = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(0, 60, 0, 18);
        Visible = Dropdown.Visible;
        ZIndex = 6;
        Parent = ToggleLabel;
    })

    Library:AddToRegistry(DropdownOuter, {
        BorderColor3 = 'Black';
    })

    local DropdownInner = Library:Create('Frame', {
        BackgroundColor3 = Library.SecondaryColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = DropdownOuter;
    })

    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 4);
        Parent = DropdownInner;
    })

    Library:AddToRegistry(DropdownInner, {
        BackgroundColor3 = 'SecondaryColor';
        BorderColor3 = 'OutlineColor';
    })

    Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
        });
        Rotation = 90;
        Parent = DropdownInner;
    })

    local DropdownInnerSearch
    if Info.Searchable then
        DropdownInnerSearch = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Visible = false;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(0.9, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = '搜索...';
            Text = '';
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ClearTextOnFocus = false;
            ZIndex = 7;
            Parent = DropdownOuter;
        })

        Library:ApplyTextStroke(DropdownInnerSearch)

        Library:AddToRegistry(DropdownInnerSearch, {
            TextColor3 = 'FontColor';
        })
    end

    local DropdownArrow = Library:Create('ImageLabel', {
        AnchorPoint = Vector2.new(0, 0.5);
        BackgroundTransparency = 1;
        Position = UDim2.new(1, -16, 0.5, 0);
        Size = UDim2.new(0, 12, 0, 12);
        Image = CustomImageManager.GetAsset("DropdownArrow");
        ZIndex = 8;
        Parent = DropdownInner;
    })

    local ItemList = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -5, 1, 0);
        TextSize = 14;
        Text = '--';
        TextXAlignment = Enum.TextXAlignment.Left;
        TextWrapped = false;
        TextTruncate = Enum.TextTruncate.AtEnd;
        RichText = true;
        ZIndex = 7;
        Parent = DropdownInner;
    })

    Library:OnHighlight(DropdownOuter, DropdownOuter,
        { BorderColor3 = 'AccentColor' },
        { BorderColor3 = 'Black' },
        function()
            return not Dropdown.Disabled
        end
    )

    if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
        Tooltip = Library:AddToolTip(Info.Tooltip, Info.DisabledTooltip, DropdownOuter)
        Tooltip.Disabled = Dropdown.Disabled
    end

    local MAX_DROPDOWN_ITEMS = if typeof(Info.MaxVisibleDropdownItems) == "number" then math.clamp(Info.MaxVisibleDropdownItems, 4, 16) else 8

    local ListOuter = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        ZIndex = 20;
        Visible = false;
        Parent = ScreenGui;
    })

    local OpenedXSizeForList = 0

    local function RecalculateListPosition()
        ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1)
    end

    local function RecalculateListSize(YSize)
        local Y = YSize or math.clamp(GetTableSize(Dropdown.Values) * (20 * DPIScale), 0, MAX_DROPDOWN_ITEMS * (20 * DPIScale)) + 1
        ListOuter.Size = UDim2.fromOffset(ListOuter.Visible and OpenedXSizeForList or DropdownOuter.AbsoluteSize.X + 0.5, Y)
    end

    RecalculateListPosition()
    RecalculateListSize()

    DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition)
    DropdownOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(RecalculateListSize)

    local ListInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 21;
        Parent = ListOuter;
    })

    local UICorner2 = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = ListInner;
    })

    local UIStroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        Thickness = 1;
        Parent = ListInner;
    })

    Library:AddToRegistry(ListInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    })

    Library:AddToRegistry(UIStroke, {
        Color = 'AccentColor';
    })

    local Scrolling = Library:Create('ScrollingFrame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        CanvasSize = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 21;
        Parent = ListInner;
        TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
        BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Library.AccentColor,
    })

    Library:AddToRegistry(Scrolling, {
        ScrollBarImageColor3 = 'AccentColor'
    })

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 0);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Scrolling;
    })

    function Dropdown:UpdateColors()
        ItemList.TextColor3 = Dropdown.Disabled and Library.DisabledAccentColor or Color3.new(1, 1, 1)
        DropdownArrow.ImageColor3 = Dropdown.Disabled and Library.DisabledAccentColor or Color3.new(1, 1, 1)
    end

    function Dropdown:GenerateDisplayText(SelectedValue)
        local Str = ''

        if Info.Multi and typeof(SelectedValue) == "table" then
            for Idx, Value in next, Dropdown.Values do
                local StringValue = if typeof(Value) == "Instance" then Value.Name else Value

                if SelectedValue[Value] then
                    Str = Str .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(StringValue)) or StringValue) .. ', '
                end
            end

            Str = Str:sub(1, #Str - 2)
            Str = (Str == '' and '--' or Str)
        else
            if not SelectedValue then
                return '--'
            end

            local StringValue = if typeof(SelectedValue) == "Instance" then SelectedValue.Name else tostring(SelectedValue)
            Str = Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(StringValue)) or StringValue
        end

        return Str
    end

    function Dropdown:Display()
        local Str = Dropdown:GenerateDisplayText(Dropdown.Value)
        ItemList.Text = Str

        local X = ListOuter.Visible and OpenedXSizeForList or Library:GetTextBounds(ItemList.Text, Library.Font, ItemList.TextSize, Vector2.new(ToggleLabel.AbsoluteSize.X, math.huge)) + 26
        DropdownOuter.Size = UDim2.new(0, X, 0, 18)
    end

    function Dropdown:GetActiveValues()
        if Info.Multi then
            local T = {}

            for Value, Bool in next, Dropdown.Value do
                table.insert(T, Value)
            end

            return T
        else
            return Dropdown.Value and 1 or 0
        end
    end
    
    function Dropdown:BuildDropdownList()
        local Values = Dropdown.Values
        local DisabledValues = Dropdown.DisabledValues
        local Buttons = {}

        for _, Element in next, Scrolling:GetChildren() do
            if not Element:IsA('UIListLayout') then
                Element:Destroy()
            end
        end

        local Count = 0
        OpenedXSizeForList = DropdownOuter.AbsoluteSize.X + 0.5

        for Idx, Value in next, Values do
            local StringValue = if typeof(Value) == "Instance" then Value.Name else Value
            if Info.Searchable and not string.lower(StringValue):match(string.lower(DropdownInnerSearch.Text)) then
                continue
            end

            local IsDisabled = table.find(DisabledValues, StringValue)
            local Table = {}

            Count = Count + 1

            local Button = Library:Create('TextButton', {
                AutoButtonColor = false,
                BackgroundColor3 = Library.SecondaryColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Middle;
                Size = UDim2.new(1, -1, 0, 20);
                Text = '';
                ZIndex = 23;
                Parent = Scrolling;
            })

            local UICorner3 = Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 4);
                Parent = Button;
            })

            Library:AddToRegistry(Button, {
                BackgroundColor3 = 'SecondaryColor';
                BorderColor3 = 'OutlineColor';
            })

            local ButtonLabel = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, -6, 1, 0);
                Position = UDim2.new(0, 6, 0, 0);
                TextSize = 14;
                Text = Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(StringValue)) or StringValue;
                TextXAlignment = Enum.TextXAlignment.Left;
                RichText = true;
                ZIndex = 25;
                Parent = Button;
            })

            Library:OnHighlight(Button, Button,
                { BorderColor3 = IsDisabled and 'DisabledAccentColor' or 'AccentColor', ZIndex = 24 },
                { BorderColor3 = 'OutlineColor', ZIndex = 23 }
            )

            local Selected

            if Info.Multi then
                Selected = Dropdown.Value[Value]
            else
                Selected = Dropdown.Value == Value
            end

            function Table:UpdateButton()
                if Info.Multi then
                    Selected = Dropdown.Value[Value]
                else
                    Selected = Dropdown.Value == Value
                end

                ButtonLabel.TextColor3 = Selected and Library.AccentColor or (IsDisabled and Library.DisabledAccentColor or Library.FontColor)
                if Library.RegistryMap[ButtonLabel] then
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or (IsDisabled and 'DisabledAccentColor' or 'FontColor')
                end
            end

            if not IsDisabled then
                Button.MouseButton1Click:Connect(function(Input)
                    local Try = not Selected

                    if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                    else
                        if Info.Multi then
                            Selected = Try

                            if Selected then
                                Dropdown.Value[Value] = true
                            else
                                Dropdown.Value[Value] = nil
                            end
                        else
                            Selected = Try

                            if Selected then
                                Dropdown.Value = Value
                            else
                                Dropdown.Value = nil
                            end

                            for _, OtherButton in next, Buttons do
                                OtherButton:UpdateButton()
                            end
                        end

                        Table:UpdateButton()
                        Dropdown:Display()
                        
                        Library:UpdateDependencyBoxes()
                        Library:UpdateDependencyGroupboxes()
                        Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                        Library:SafeCallback(Dropdown.Changed, Dropdown.Value)

                        Library:AttemptSave()
                    end
                end)
            end

            Table:UpdateButton()
            Dropdown:Display()

            local Str = Dropdown:GenerateDisplayText(Value)
            local X = Library:GetTextBounds(Str, Library.Font, ItemList.TextSize, Vector2.new(ToggleLabel.AbsoluteSize.X, math.huge)) + 26
            if X > OpenedXSizeForList then
                OpenedXSizeForList = X
            end

            Buttons[Button] = Table
        end
        
        Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * (20 * DPIScale)) + 1)

        Scrolling.Visible = false
        Scrolling.Visible = true

        local Y = math.clamp(Count * (20 * DPIScale), 0, MAX_DROPDOWN_ITEMS * (20 * DPIScale)) + 1
        RecalculateListSize(Y)
    end

    function Dropdown:SetValues(NewValues)
        if NewValues then
            Dropdown.Values = NewValues
        end

        Dropdown:BuildDropdownList()
    end

    function Dropdown:AddValues(NewValues)
        if typeof(NewValues) == "table" then
            for _, val in pairs(NewValues) do
                table.insert(Dropdown.Values, val)
            end
        elseif typeof(NewValues) == "string" then
            table.insert(Dropdown.Values, NewValues)
        else
            return
        end

        Dropdown:BuildDropdownList()
    end

    function Dropdown:SetDisabledValues(NewValues)
        if NewValues then
            Dropdown.DisabledValues = NewValues
        end

        Dropdown:BuildDropdownList()
    end

    function Dropdown:AddDisabledValues(DisabledValues)
        if typeof(DisabledValues) == "table" then
            for _, val in pairs(DisabledValues) do
                table.insert(Dropdown.DisabledValues, val)
            end
        elseif typeof(DisabledValues) == "string" then
            table.insert(Dropdown.DisabledValues, DisabledValues)
        else
            return
        end

        Dropdown:BuildDropdownList()
    end

    function Dropdown:SetVisible(Visibility)
        Dropdown.Visible = Visibility

        DropdownOuter.Visible = Dropdown.Visible
        if not Dropdown.Visible then Dropdown:CloseDropdown() end
    end

    function Dropdown:SetDisabled(Disabled)
        Dropdown.Disabled = Disabled

        if Tooltip then
            Tooltip.Disabled = Disabled
        end

        if Disabled then
            Dropdown:CloseDropdown()
        end

        Dropdown:Display()
        Dropdown:UpdateColors()
    end

    function Dropdown:OpenDropdown()
        if Dropdown.Disabled then
            return
        end

        if Library.IsMobile then
            Library.CanDrag = false
        end

        if Info.Searchable then
            ItemList.Visible = false
            DropdownInnerSearch.Text = ""
            DropdownInnerSearch.Visible = true
        end
        
        ListOuter.Visible = true
        Library.OpenedFrames[ListOuter] = true
        DropdownArrow.Rotation = 180

        Dropdown:Display()
        RecalculateListSize()
    end

    function Dropdown:CloseDropdown()
        if Library.IsMobile then         
            Library.CanDrag = true
        end

        if Info.Searchable then
            DropdownInnerSearch.Text = ""
            DropdownInnerSearch.Visible = false
            ItemList.Visible = true
        end
    
        ListOuter.Visible = false
        Library.OpenedFrames[ListOuter] = nil
        DropdownArrow.Rotation = 0

        Dropdown:Display()
        RecalculateListSize()
    end

    function Dropdown:OnChanged(Func)
        Dropdown.Changed = Func
    end

    function Dropdown:SetValue(Value)
        if Dropdown.Multi then
            local Table = {}

            for Val, Active in pairs(Value or {}) do
                if typeof(Active) ~= "boolean" then
                    Table[Active] = true
                elseif Active and table.find(Dropdown.Values, Val) then
                    Table[Val] = true
                end
            end

            Dropdown.Value = Table
        else
            if table.find(Dropdown.Values, Value) then
                Dropdown.Value = Value
            elseif not Value then
                Dropdown.Value = nil
            end
        end

        Dropdown:BuildDropdownList()

        if not Dropdown.Disabled then
            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end
    end

    function Dropdown:SetText(...)
        return
    end

    DropdownOuter.InputBegan:Connect(function(Input)
        if Dropdown.Disabled then
            return
        end

        if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
            if ListOuter.Visible then
                Dropdown:CloseDropdown()
            else
                Dropdown:OpenDropdown()
            end
        end
    end)

    if Info.Searchable then
        DropdownInnerSearch:GetPropertyChangedSignal("Text"):Connect(function()
            Dropdown:BuildDropdownList()
        end)
    end

    InputService.InputBegan:Connect(function(Input)
        if Dropdown.Disabled then
            return
        end

        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize

            if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                or Mouse.Y < (AbsPos.Y - (20 * DPIScale) - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                Dropdown:CloseDropdown()
            end
        end
    end)

    Dropdown:BuildDropdownList()
    Dropdown:Display()

    local Defaults = {}

    if typeof(Info.Default) == "string" then
        local DefaultIdx = table.find(Dropdown.Values, Info.Default)
        if DefaultIdx then
            table.insert(Defaults, DefaultIdx)
        end

    elseif typeof(Info.Default) == 'table' then
        for _, Value in next, Info.Default do
            local DefaultIdx = table.find(Dropdown.Values, Value)
            if DefaultIdx then
                table.insert(Defaults, DefaultIdx)
            end
        end

    elseif typeof(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
        table.insert(Defaults, Info.Default)
    end

    if next(Defaults) then
        for i = 1, #Defaults do
            local Index = Defaults[i]
            if Info.Multi then
                Dropdown.Value[Dropdown.Values[Index]] = true
            else
                Dropdown.Value = Dropdown.Values[Index]
            end

            if (not Info.Multi) then break end
        end

        Dropdown:BuildDropdownList()
        Dropdown:Display()
    end

    task.delay(0.1, Dropdown.UpdateColors, Dropdown)

    Dropdown.DisplayFrame = DropdownOuter
    if ParentObj.Addons then
        table.insert(ParentObj.Addons, Dropdown)
    end

    Dropdown.Default = Defaults
    Dropdown.DefaultValues = Dropdown.Values

    Options[Idx] = Dropdown

    return self
end

BaseAddons.__index = BaseAddonsFuncs
BaseAddons.__namecall = function(Table, Key, ...)
    return BaseAddonsFuncs[Key](...)
end
end

local BaseGroupbox = {}
do
    local BaseGroupboxFuncs = {}

    function BaseGroupboxFuncs:AddBlank(Size, Visible)
        local Groupbox = self
        local Container = Groupbox.Container

        return Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            Visible = if typeof(Visible) == "boolean" then Visible else true;
            ZIndex = 1;
            Parent = Container;
        })
    end

    function BaseGroupboxFuncs:AddDivider()
        local Groupbox = self
        local Container = self.Container

        Groupbox:AddBlank(2)
        local DividerOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 5);
            ZIndex = 5;
            Parent = Container;
        })

        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DividerOuter;
        })

        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black';
        })

        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        })

        Groupbox:AddBlank(9)
        Groupbox:Resize()

        table.insert(Groupbox.Elements, {
            Holder = DividerOuter,
            Type = "Divider",
        })
    end

    function BaseGroupboxFuncs:AddLabel(...)
        local Data = {}

        if select(2, ...) ~= nil and typeof(select(2, ...)) == "table" then
            if select(1, ...) ~= nil then
                assert(typeof(select(1, ...)) == "string", "Expected string for Idx, got " .. typeof(select(1, ...)))
            end
            
            local Params = select(2, ...)

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Idx = select(1, ...)
        else
            Data.Text = select(1, ...) or ""
            Data.DoesWrap = select(2, ...) or false
            Data.Idx = select(3, ...) or nil
        end

        Data.OriginalText = Data.Text
        
        local Label = {
            Type = "Label";
            Addons = {};
        }

        local Groupbox = self
        local Container = Groupbox.Container

        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15);
            TextSize = 14;
            Text = Data.Text;
            TextWrapped = Data.DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
            RichText = true;
        })

        if Data.DoesWrap then
            local Y = select(2, Library:GetTextBounds(Data.Text, Library.Font, 14 * DPIScale, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
            TextLabel.Size = UDim2.new(1, -4, 0, Y)
        else
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4 * DPIScale);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TextLabel;
            })
        end

        Label.TextLabel = TextLabel
        Label.Container = Container

        function Label:SetText(Text)
            TextLabel.Text = Text

            if Data.DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14 * DPIScale, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            end

            Groupbox:Resize()
        end

        setmetatable(Label, BaseAddons)

        Groupbox:AddBlank(5)
        Groupbox:Resize()

        table.insert(Groupbox.Elements, Label)
        
        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        return Label
    end
    
    function BaseGroupboxFuncs:AddTabbox(Info)
        Info = typeof(Info) == "table" and Info or { Name = tostring(Info or "Tabbox") }

        local Tabbox = {
            Tabs = {};
        }

        local Container = self.Container
        if not Container then
            warn("Groupbox missing Container, cannot create Tabbox")
            return nil
        end

        local TitleLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 14);
            TextSize = 14;
            Text = Info.Name or "Tabbox";
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        })

        local TabboxButtons = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 1);
            Size = UDim2.new(1, 0, 0, 18);
            ZIndex = 8;
            Parent = Container;
        })

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = TabboxButtons;
        })

        function Tabbox:AddTab(Name)
            local Tab = {
                Elements = {};
                Container = nil;
                TableType = "TabboxTab";
            }

            local Button = Library:Create('Frame', {
                BackgroundColor3 = Library.SecondaryColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(0.5, 0, 1, 0);
                ZIndex = 8;
                Parent = TabboxButtons;
            })

            local ButtonUICorner = Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 3);
                Parent = Button;
            })

            Library:AddToRegistry(Button, {
                BackgroundColor3 = 'SecondaryColor';
                BorderColor3 = 'OutlineColor';
            })

            local ButtonLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 13;
                Text = Name or "";
                ZIndex = 9;
                Parent = Button;
                RichText = true;
            })

            Library:OnHighlight(Button, Button,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'OutlineColor' }
            )

            local TabContainer = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 0);
                ZIndex = 7;
                Visible = false;
                Parent = Container;
            })

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabContainer;
            })

            function Tab:Show()
                for _, t in next, Tabbox.Tabs do
                    t:Hide()
                end

                TabContainer.Visible = true
                Button.BackgroundColor3 = Library.AccentColor
                Button.BorderColor3 = Library.AccentColorDark
                ButtonLabel.TextColor3 = Color3.new(1, 1, 1)
            end

            function Tab:Hide()
                TabContainer.Visible = false
                Button.BackgroundColor3 = Library.SecondaryColor
                Button.BorderColor3 = Library.OutlineColor
                ButtonLabel.TextColor3 = Library.FontColor
            end

            function Tab:Resize()
                local TabCount = 0
                for _, t in next, Tabbox.Tabs do
                    TabCount = TabCount + 1
                end

                for _, btn in next, TabboxButtons:GetChildren() do
                    if btn:IsA('GuiObject') then
                        btn.Size = UDim2.new(1 / TabCount, 0, 1, 0)
                    end
                end
            end

            Button.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Tab:Show()
                end
            end)

            Tab.Container = TabContainer
            Tabbox.Tabs[Name or ""] = Tab
            setmetatable(Tab, BaseGroupbox)
            Tab:AddBlank(3)
            Tab:Resize()

            if #TabboxButtons:GetChildren() == 2 then
                Tab:Show()
            end

            return Tab
        end

        for _, btn in next, TabboxButtons:GetChildren() do
            if btn:IsA('GuiObject') then
                btn.Size = UDim2.new(1, 0, 1, 0)
            end
        end

        return Tabbox
    end
    
    function BaseGroupboxFuncs:AddColorPicker(Idx, Info)
        Info = Info or {}
        local titleText = Info.Title or Info.Text or Info.Name or "颜色选择"
        local HolderLabel = self:AddLabel(titleText, false, Idx and (Idx .. "_label") or nil)
        return HolderLabel:AddColorPicker(Idx, Info)
    end
    
    function BaseGroupboxFuncs:AddButton(...)
        local Button = typeof(select(1, ...)) == "table" and select(1, ...) or {
            Text = select(1, ...),
            Func = select(2, ...)
        }
        Button.OriginalText = Button.Text
        Button.Func = Button.Func or Button.Callback
        assert(typeof(Button.Func) == 'function', 'AddButton: `Func` callback is missing.')

        local Blank = nil
        local Groupbox = self
        local Container = Groupbox.Container
        local IsVisible = if typeof(Button.Visible) == "boolean" then Button.Visible else true

        local function CreateBaseButton(Button)
            local Outer = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 20);
                Visible = IsVisible;
                ZIndex = 5;
            })

            local Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.SecondaryColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = Outer;
            })

            local UICorner = Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 4);
                Parent = Inner;
            })

            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 14;
                Text = Button.Text;
                ZIndex = 6;
                Parent = Inner;
                RichText = true;
            })

            Library:Create('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = Inner;
            })

            Library:AddToRegistry(Outer, {
                BorderColor3 = 'Black';
            })

            Library:AddToRegistry(Inner, {
                BackgroundColor3 = 'SecondaryColor';
                BorderColor3 = 'OutlineColor';
            })

            Library:OnHighlight(Outer, Outer,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            )

            return Outer, Inner, Label
        end

        local function InitEvents(Button)
            local function WaitForEvent(event, timeout, validator)
                local bindable = Instance.new('BindableEvent')
                local connection = event:Once(function(...)

                    if typeof(validator) == 'function' and validator(...) then
                        bindable:Fire(true)
                    else
                        bindable:Fire(false)
                    end
                end)
                task.delay(timeout, function()
                    connection:disconnect()
                    bindable:Fire(false)
                end)
                return bindable.Event:Wait()
            end

            local function ValidateClick(Input)
                if Library:MouseIsOverOpenedFrame(Input) then
                    return false
                end

                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    return true
                elseif Input.UserInputType == Enum.UserInputType.Touch then
                    return true
                else
                    return false
                end
            end

            Button.Outer.InputBegan:Connect(function(Input)
                if Button.Disabled then
                    return
                end

                if not ValidateClick(Input) then return end
                if Button.Locked then return end

                if Button.DoubleClick then
                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'AccentColor' })

                    Button.Label.TextColor3 = Library.AccentColor
                    Button.Label.Text = '确定吗?'
                    Button.Locked = true

                    local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)

                    Library:RemoveFromRegistry(Button.Label)
                    Library:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' })

                    Button.Label.TextColor3 = Library.FontColor
                    Button.Label.Text = Button.Text
                    task.defer(rawset, Button, 'Locked', false)

                    if clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    return
                end

                Library:SafeCallback(Button.Func)
            end)
        end

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
        Button.Outer.Parent = Container

        InitEvents(Button)

        function Button:AddButton(...)
            local SubButton = typeof(select(1, ...)) == "table" and select(1, ...) or {
                Text = select(1, ...),
                Func = select(2, ...)
            }
            SubButton.OriginalText = SubButton.Text
            SubButton.Func = SubButton.Func or SubButton.Callback
            assert(typeof(SubButton.Func) == 'function', 'AddButton: `Func` callback is missing.')

            self.Outer.Size = UDim2.new(0.5, -2, 0, 20 * DPIScale)

            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)

            SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
            SubButton.Outer.Size = UDim2.new(1, -3, 0, self.Outer.AbsoluteSize.Y)
            SubButton.Outer.Parent = self.Outer

            function SubButton:UpdateColors()
                SubButton.Label.TextColor3 = SubButton.Disabled and Library.DisabledAccentColor or Color3.new(1, 1, 1)
            end

            function SubButton:AddToolTip(tooltip, disabledTooltip)
                if typeof(tooltip) == "string" or typeof(disabledTooltip) == "string" then
                    if SubButton.TooltipTable then
                        SubButton.TooltipTable:Destroy()
                    end
                
                    SubButton.TooltipTable = Library:AddToolTip(tooltip, disabledTooltip, self.Outer)
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                return SubButton
            end

            function SubButton:SetDisabled(Disabled)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = Disabled
                end

                SubButton:UpdateColors()
            end

            function SubButton:SetText(Text)
                if typeof(Text) == "string" then
                    SubButton.Text = Text
                    SubButton.Label.Text = SubButton.Text
                end
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable = SubButton:AddToolTip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Outer)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            task.delay(0.1, SubButton.UpdateColors, SubButton)
            InitEvents(SubButton)

            table.insert(Buttons, SubButton)
            return SubButton
        end

        function Button:UpdateColors()
            Button.Label.TextColor3 = Button.Disabled and Library.DisabledAccentColor or Color3.new(1, 1, 1)
        end

        function Button:AddToolTip(tooltip, disabledTooltip)
            if typeof(tooltip) == "string" or typeof(disabledTooltip) == "string" then
                if Button.TooltipTable then
                    Button.TooltipTable:Destroy()
                end

                Button.TooltipTable = Library:AddToolTip(tooltip, disabledTooltip, self.Outer)
                Button.TooltipTable.Disabled = Button.Disabled
            end

            return Button
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Button:AddToolTip(Button.Tooltip, Button.DisabledTooltip, Button.Outer)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        function Button:SetVisible(Visibility)
            IsVisible = Visibility

            Button.Outer.Visible = IsVisible
            if Blank then Blank.Visible = IsVisible end

            Groupbox:Resize()
        end

        function Button:SetText(Text)
            if typeof(Text) == "string" then
                Button.Text = Text
                Button.Label.Text = Button.Text
            end
        end

        function Button:SetDisabled(Disabled)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Disabled
            end

            Button:UpdateColors()
        end

        task.delay(0.1, Button.UpdateColors, Button)
        Blank = Groupbox:AddBlank(5, IsVisible)
        Groupbox:Resize()

        table.insert(Groupbox.Elements, Button)
        table.insert(Buttons, Button)

        return Button
    end
    
    function BaseGroupboxFuncs:AddInput(Idx, Info)
    assert(Info.Text, string.format('AddInput (IDX: %s): Missing `Text` string.', tostring(Idx)))

    Info.ClearTextOnFocus = if typeof(Info.ClearTextOnFocus) == "boolean" then Info.ClearTextOnFocus else true

    local Textbox = {
        Value = Info.Default or '';
        Numeric = Info.Numeric or false;
        Finished = Info.Finished or false;
        Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        AllowEmpty = if typeof(Info.AllowEmpty) == "boolean" then Info.AllowEmpty else true;
        EmptyReset = if typeof(Info.EmptyReset) == "string" then Info.EmptyReset else "---";
        Type = 'Input';
        Callback = Info.Callback or function(Value) end;
    }

    local Groupbox = self
    local Container = Groupbox.Container
    local Blank

    local InputLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 15);
        TextSize = 14;
        Text = Info.Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = Container;
    })

    Groupbox:AddBlank(1)

    local TextBoxOuter = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(1, -4, 0, 20);
        ZIndex = 5;
        Parent = Container;
    })

    local TextBoxInner = Library:Create('Frame', {
        BackgroundColor3 = Library.SecondaryColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = TextBoxOuter;
    })

    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 4);
        Parent = TextBoxInner;
    })

    Library:AddToRegistry(TextBoxInner, {
        BackgroundColor3 = 'SecondaryColor';
        BorderColor3 = 'OutlineColor';
    })

    Library:OnHighlight(TextBoxOuter, TextBoxOuter,
        { BorderColor3 = 'AccentColor' },
        { BorderColor3 = 'Black' }
    )

    local TooltipTable
    if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
        TooltipTable = Library:AddToolTip(Info.Tooltip, Info.DisabledTooltip, TextBoxOuter)
        TooltipTable.Disabled = Textbox.Disabled
    end

    Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
        });
        Rotation = 90;
        Parent = TextBoxInner;
    })

    local TextBoxContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        ClipsDescendants = true;
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -5, 1, 0);
        ZIndex = 7;
        Parent = TextBoxInner;
    })

    local Box = Library:Create('TextBox', {
        BackgroundTransparency = 1;
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(5, 1),
        Font = Library.Font;
        PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
        PlaceholderText = Info.Placeholder or '';
        Text = Info.Default or (if Textbox.AllowEmpty == false then Textbox.EmptyReset else "---");
        TextColor3 = Library.FontColor;
        TextSize = 14;
        TextStrokeTransparency = 0;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextEditable = not Textbox.Disabled;
        ClearTextOnFocus = not Textbox.Disabled and Info.ClearTextOnFocus;
        ZIndex = 7;
        Parent = TextBoxContainer;
    })

    Library:ApplyTextStroke(Box)

    Library:AddToRegistry(Box, {
        TextColor3 = 'FontColor';
    })

    function Textbox:OnChanged(Func)
        Textbox.Changed = Func
    end

    function Textbox:UpdateColors()
        Box.TextColor3 = Textbox.Disabled and Library.DisabledAccentColor or Library.FontColor

        if Library.RegistryMap[Box] then
            Library.RegistryMap[Box].Properties.TextColor3 = Textbox.Disabled and 'DisabledAccentColor' or 'FontColor'
        end
    end

    function Textbox:Display()
        TextBoxOuter.Visible = Textbox.Visible
        InputLabel.Visible = Textbox.Visible
        if Blank then Blank.Visible = Textbox.Visible end

        Groupbox:Resize()
    end

    function Textbox:SetValue(Text)
        if not Textbox.AllowEmpty and Trim(Text) == "" then
            Text = Textbox.EmptyReset
        end

        if Info.MaxLength and #Text > Info.MaxLength then
            Text = Text:sub(1, Info.MaxLength)
        end

        if Textbox.Numeric then
            if #tostring(Text) > 0 and not tonumber(Text) then
                Text = Textbox.Value
            end
        end

        Textbox.Value = Text
        Box.Text = Text

        if not Textbox.Disabled then
            Library:SafeCallback(Textbox.Callback, Textbox.Value)
            Library:SafeCallback(Textbox.Changed, Textbox.Value)
        end
    end

    function Textbox:SetVisible(Visibility)
        Textbox.Visible = Visibility

        Textbox:Display()
    end

    function Textbox:SetDisabled(Disabled)
        Textbox.Disabled = Disabled

        Box.TextEditable = not Disabled
        Box.ClearTextOnFocus = not Disabled and Info.ClearTextOnFocus

        if TooltipTable then
            TooltipTable.Disabled = Disabled
        end

        Textbox:UpdateColors()
    end

    if Textbox.Finished then
        Box.FocusLost:Connect(function(enter)
            if not enter then return end

            Textbox:SetValue(Box.Text)
            Library:AttemptSave()
        end)
    else
        Box:GetPropertyChangedSignal('Text'):Connect(function()
            Textbox:SetValue(Box.Text)
            Library:AttemptSave()
        end)
    end

    local function Update()
        local PADDING = 2
        local reveal = TextBoxContainer.AbsoluteSize.X

        if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
            Box.Position = UDim2.new(0, PADDING, 0, 0)
        else
            local cursor = Box.CursorPosition
            if cursor ~= -1 then
                local subtext = string.sub(Box.Text, 1, cursor-1)
                local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X

                local currentCursorPos = Box.Position.X.Offset + width

                if currentCursorPos < PADDING then
                    Box.Position = UDim2.fromOffset(PADDING-width, 0)
                elseif currentCursorPos > reveal - PADDING - 1 then
                    Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
                end
            end
        end
    end

    task.spawn(Update)

    Box:GetPropertyChangedSignal('Text'):Connect(Update)
    Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
    Box.FocusLost:Connect(Update)
    Box.Focused:Connect(Update)

    Blank = Groupbox:AddBlank(5, Textbox.Visible)
    task.delay(0.1, Textbox.UpdateColors, Textbox)
    Textbox:Display()
    Groupbox:Resize()

    Textbox.Default = Textbox.Value

    table.insert(Groupbox.Elements, Textbox)
    Options[Idx] = Textbox

    return Textbox
end

function BaseGroupboxFuncs:AddDropdown(Idx, Info)
    Info.ReturnInstanceInstead = if typeof(Info.ReturnInstanceInstead) == "boolean" then Info.ReturnInstanceInstead else false

    if Info.SpecialType == 'Player' then
        Info.ExcludeLocalPlayer = if typeof(Info.ExcludeLocalPlayer) == "boolean" then Info.ExcludeLocalPlayer else false

        Info.Values = GetPlayers(Info.ExcludeLocalPlayer, Info.ReturnInstanceInstead)
        Info.AllowNull = true
    elseif Info.SpecialType == 'Team' then
        Info.Values = GetTeams(Info.ReturnInstanceInstead)
        Info.AllowNull = true
    end

    assert(Info.Values, string.format('AddDropdown (IDX: %s): Missing dropdown value list.', tostring(Idx)))
    if not (Info.AllowNull or Info.Default) then
        Info.Default = 1
        warn(string.format('AddDropdown (IDX: %s): Missing default value, selected the first index instead. Pass `AllowNull` as true if this was intentional.', tostring(Idx)))
    end

    Info.Searchable = if typeof(Info.Searchable) == "boolean" then Info.Searchable else false
    Info.FormatDisplayValue = if typeof(Info.FormatDisplayValue) == "function" then Info.FormatDisplayValue else nil

    local Dropdown = {
        Values = Info.Values;
        Value = Info.Multi and {};
        DisabledValues = Info.DisabledValues or {};

        Multi = Info.Multi;
        Type = 'Dropdown';
        SpecialType = Info.SpecialType;
        Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        Callback = Info.Callback or function(Value) end;
        Changed = Info.Changed or function(Value) end;

        OriginalText = Info.Text; Text = Info.Text;
        ExcludeLocalPlayer = Info.ExcludeLocalPlayer;
        ReturnInstanceInstead = Info.ReturnInstanceInstead;
    }

    local Tooltip
    local Groupbox = self
    local Container = Groupbox.Container
    local Blank

    local Label = Library:CreateLabel({
        Size = UDim2.new(1, -4, 0, 15);
        TextSize = 14;
        Text = Info.Text or "";
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = Container;
        RichText = true;
    })

    Groupbox:AddBlank(1)

    local DropdownOuter = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(1, -4, 0, 18);
        Visible = Dropdown.Visible;
        ZIndex = 6;
        Parent = Container;
    })

    Library:AddToRegistry(DropdownOuter, {
        BorderColor3 = 'Black';
    })

    local DropdownInner = Library:Create('Frame', {
        BackgroundColor3 = Library.SecondaryColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = DropdownOuter;
    })

    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 4);
        Parent = DropdownInner;
    })

    Library:AddToRegistry(DropdownInner, {
        BackgroundColor3 = 'SecondaryColor';
        BorderColor3 = 'OutlineColor';
    })

    Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
        });
        Rotation = 90;
        Parent = DropdownInner;
    })

    local DropdownInnerSearch
    if Info.Searchable then
        DropdownInnerSearch = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Visible = false;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(0.9, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = '搜索...';
            Text = '';
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ClearTextOnFocus = false;
            ZIndex = 7;
            Parent = DropdownOuter;
        })

        Library:ApplyTextStroke(DropdownInnerSearch)

        Library:AddToRegistry(DropdownInnerSearch, {
            TextColor3 = 'FontColor';
        })
    end

    local DropdownArrow = Library:Create('ImageLabel', {
        AnchorPoint = Vector2.new(0, 0.5);
        BackgroundTransparency = 1;
        Position = UDim2.new(1, -16, 0.5, 0);
        Size = UDim2.new(0, 12, 0, 12);
        Image = CustomImageManager.GetAsset("DropdownArrow");
        ZIndex = 8;
        Parent = DropdownInner;
    })

    local ItemList = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -5, 1, 0);
        TextSize = 14;
        Text = '--';
        TextXAlignment = Enum.TextXAlignment.Left;
        TextWrapped = false;
        TextTruncate = Enum.TextTruncate.AtEnd;
        RichText = true;
        ZIndex = 7;
        Parent = DropdownInner;
    })

    Library:OnHighlight(DropdownOuter, DropdownOuter,
        { BorderColor3 = 'AccentColor' },
        { BorderColor3 = 'Black' },
        function()
            return not Dropdown.Disabled
        end
    )

    if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
        Tooltip = Library:AddToolTip(Info.Tooltip, Info.DisabledTooltip, DropdownOuter)
        Tooltip.Disabled = Dropdown.Disabled
    end

    local MAX_DROPDOWN_ITEMS = if typeof(Info.MaxVisibleDropdownItems) == "number" then math.clamp(Info.MaxVisibleDropdownItems, 4, 16) else 8

    local ListOuter = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        ZIndex = 20;
        Visible = false;
        Parent = ScreenGui;
    })

    local OpenedXSizeForList = 0

    local function RecalculateListPosition()
        ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1)
    end

    local function RecalculateListSize(YSize)
        local Y = YSize or math.clamp(GetTableSize(Dropdown.Values) * (20 * DPIScale), 0, MAX_DROPDOWN_ITEMS * (20 * DPIScale)) + 1
        ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X + 0.5, Y)
    end

    RecalculateListPosition()
    RecalculateListSize()

    DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition)
    DropdownOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(RecalculateListSize)

    local ListInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 21;
        Parent = ListOuter;
    })

    local UICorner2 = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = ListInner;
    })

    local UIStroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        Thickness = 1;
        Parent = ListInner;
    })

    Library:AddToRegistry(ListInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    })

    Library:AddToRegistry(UIStroke, {
        Color = 'AccentColor';
    })

    local Scrolling = Library:Create('ScrollingFrame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        CanvasSize = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 21;
        Parent = ListInner;
        TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
        BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Library.AccentColor,
    })

    Library:AddToRegistry(Scrolling, {
        ScrollBarImageColor3 = 'AccentColor'
    })

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 0);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Scrolling;
    })

    function Dropdown:UpdateColors()
        ItemList.TextColor3 = Dropdown.Disabled and Library.DisabledAccentColor or Color3.new(1, 1, 1)
        DropdownArrow.ImageColor3 = Dropdown.Disabled and Library.DisabledAccentColor or Color3.new(1, 1, 1)
    end

    function Dropdown:GenerateDisplayText(SelectedValue)
        local Str = ''

        if Info.Multi and typeof(SelectedValue) == "table" then
            for Idx, Value in next, Dropdown.Values do
                local StringValue = if typeof(Value) == "Instance" then Value.Name else Value

                if SelectedValue[Value] then
                    Str = Str .. (Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(StringValue)) or StringValue) .. ', '
                end
            end

            Str = Str:sub(1, #Str - 2)
            Str = (Str == '' and '--' or Str)
        else
            if not SelectedValue then
                return '--'
            end

            local StringValue = if typeof(SelectedValue) == "Instance" then SelectedValue.Name else tostring(SelectedValue)
            Str = Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(StringValue)) or StringValue
        end

        return Str
    end

    function Dropdown:Display()
        local Str = Dropdown:GenerateDisplayText(Dropdown.Value)
        ItemList.Text = Str
    end

    function Dropdown:GetActiveValues()
        if Info.Multi then
            local T = {}

            for Value, Bool in next, Dropdown.Value do
                table.insert(T, Value)
            end

            return T
        else
            return Dropdown.Value and 1 or 0
        end
    end
    
    function Dropdown:BuildDropdownList()
        local Values = Dropdown.Values
        local DisabledValues = Dropdown.DisabledValues
        local Buttons = {}

        for _, Element in next, Scrolling:GetChildren() do
            if not Element:IsA('UIListLayout') then
                Element:Destroy()
            end
        end

        local Count = 0
        OpenedXSizeForList = DropdownOuter.AbsoluteSize.X + 0.5

        for Idx, Value in next, Values do
            local StringValue = if typeof(Value) == "Instance" then Value.Name else Value
            if Info.Searchable and not string.lower(StringValue):match(string.lower(DropdownInnerSearch.Text)) then
                continue
            end

            local IsDisabled = table.find(DisabledValues, StringValue)
            local Table = {}

            Count = Count + 1

            local Button = Library:Create('TextButton', {
                AutoButtonColor = false;
                BackgroundColor3 = Library.SecondaryColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Middle;
                Size = UDim2.new(1, -1, 0, 20);
                Text = '';
                ZIndex = 23;
                Parent = Scrolling;
            })

            local UICorner3 = Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 4);
                Parent = Button;
            })

            Library:AddToRegistry(Button, {
                BackgroundColor3 = 'SecondaryColor';
                BorderColor3 = 'OutlineColor';
            })

            local ButtonLabel = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, -6, 1, 0);
                Position = UDim2.new(0, 6, 0, 0);
                TextSize = 14;
                Text = Info.FormatDisplayValue and tostring(Info.FormatDisplayValue(StringValue)) or StringValue;
                TextXAlignment = Enum.TextXAlignment.Left;
                RichText = true;
                ZIndex = 25;
                Parent = Button;
            })

            Library:OnHighlight(Button, Button,
                { BorderColor3 = IsDisabled and 'DisabledAccentColor' or 'AccentColor', ZIndex = 24 },
                { BorderColor3 = 'OutlineColor', ZIndex = 23 }
            )

            local Selected

            if Info.Multi then
                Selected = Dropdown.Value[Value]
            else
                Selected = Dropdown.Value == Value
            end

            function Table:UpdateButton()
                if Info.Multi then
                    Selected = Dropdown.Value[Value]
                else
                    Selected = Dropdown.Value == Value
                end

                ButtonLabel.TextColor3 = Selected and Library.AccentColor or (IsDisabled and Library.DisabledAccentColor or Library.FontColor)
                if Library.RegistryMap[ButtonLabel] then
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or (IsDisabled and 'DisabledAccentColor' or 'FontColor')
                end
            end

            if not IsDisabled then
                Button.MouseButton1Click:Connect(function(Input)
                    local Try = not Selected

                    if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                    else
                        if Info.Multi then
                            Selected = Try

                            if Selected then
                                Dropdown.Value[Value] = true
                            else
                                Dropdown.Value[Value] = nil
                            end
                        else
                            Selected = Try

                            if Selected then
                                Dropdown.Value = Value
                            else
                                Dropdown.Value = nil
                            end

                            for _, OtherButton in next, Buttons do
                                OtherButton:UpdateButton()
                            end
                        end

                        Table:UpdateButton()
                        Dropdown:Display()
                        
                        Library:UpdateDependencyBoxes()
                        Library:UpdateDependencyGroupboxes()
                        Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                        Library:SafeCallback(Dropdown.Changed, Dropdown.Value)

                        Library:AttemptSave()
                    end
                end)
            end

            Table:UpdateButton()
            Dropdown:Display()

            Buttons[Button] = Table
        end
        
        Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * (20 * DPIScale)) + 1)

        Scrolling.Visible = false
        Scrolling.Visible = true

        local Y = math.clamp(Count * (20 * DPIScale), 0, MAX_DROPDOWN_ITEMS * (20 * DPIScale)) + 1
        RecalculateListSize(Y)
    end

    function Dropdown:SetValues(NewValues)
        if NewValues then
            Dropdown.Values = NewValues
        end

        Dropdown:BuildDropdownList()
    end

    function Dropdown:AddValues(NewValues)
        if typeof(NewValues) == "table" then
            for _, val in pairs(NewValues) do
                table.insert(Dropdown.Values, val)
            end
        elseif typeof(NewValues) == "string" then
            table.insert(Dropdown.Values, NewValues)
        else
            return
        end

        Dropdown:BuildDropdownList()
    end

    function Dropdown:SetDisabledValues(NewValues)
        if NewValues then
            Dropdown.DisabledValues = NewValues
        end

        Dropdown:BuildDropdownList()
    end

    function Dropdown:AddDisabledValues(DisabledValues)
        if typeof(DisabledValues) == "table" then
            for _, val in pairs(DisabledValues) do
                table.insert(Dropdown.DisabledValues, val)
            end
        elseif typeof(DisabledValues) == "string" then
            table.insert(Dropdown.DisabledValues, DisabledValues)
        else
            return
        end

        Dropdown:BuildDropdownList()
    end

    function Dropdown:SetVisible(Visibility)
        Dropdown.Visible = Visibility

        DropdownOuter.Visible = Dropdown.Visible
        Label.Visible = Dropdown.Visible
        if Blank then Blank.Visible = Dropdown.Visible end
        if not Dropdown.Visible then Dropdown:CloseDropdown() end

        Groupbox:Resize()
    end

    function Dropdown:SetDisabled(Disabled)
        Dropdown.Disabled = Disabled

        if Tooltip then
            Tooltip.Disabled = Disabled
        end

        if Disabled then
            Dropdown:CloseDropdown()
        end

        Dropdown:Display()
        Dropdown:UpdateColors()
    end

    function Dropdown:OpenDropdown()
        if Dropdown.Disabled then
            return
        end

        if Library.IsMobile then
            Library.CanDrag = false
        end

        if Info.Searchable then
            ItemList.Visible = false
            DropdownInnerSearch.Text = ""
            DropdownInnerSearch.Visible = true
        end
        
        ListOuter.Visible = true
        Library.OpenedFrames[ListOuter] = true
        DropdownArrow.Rotation = 180

        Dropdown:Display()
        RecalculateListSize()
    end

    function Dropdown:CloseDropdown()
        if Library.IsMobile then         
            Library.CanDrag = true
        end

        if Info.Searchable then
            DropdownInnerSearch.Text = ""
            DropdownInnerSearch.Visible = false
            ItemList.Visible = true
        end
    
        ListOuter.Visible = false
        Library.OpenedFrames[ListOuter] = nil
        DropdownArrow.Rotation = 0

        Dropdown:Display()
        RecalculateListSize()
    end

    function Dropdown:OnChanged(Func)
        Dropdown.Changed = Func
    end

    function Dropdown:SetValue(Value)
        if Dropdown.Multi then
            local Table = {}

            for Val, Active in pairs(Value or {}) do
                if typeof(Active) ~= "boolean" then
                    Table[Active] = true
                elseif Active and table.find(Dropdown.Values, Val) then
                    Table[Val] = true
                end
            end

            Dropdown.Value = Table
        else
            if table.find(Dropdown.Values, Value) then
                Dropdown.Value = Value
            elseif not Value then
                Dropdown.Value = nil
            end
        end

        Dropdown:BuildDropdownList()

        if not Dropdown.Disabled then
            Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
        end
    end

    function Dropdown:SetText(...)
        return
    end

    DropdownOuter.InputBegan:Connect(function(Input)
        if Dropdown.Disabled then
            return
        end

        if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
            if ListOuter.Visible then
                Dropdown:CloseDropdown()
            else
                Dropdown:OpenDropdown()
            end
        end
    end)

    if Info.Searchable then
        DropdownInnerSearch:GetPropertyChangedSignal("Text"):Connect(function()
            Dropdown:BuildDropdownList()
        end)
    end

    InputService.InputBegan:Connect(function(Input)
        if Dropdown.Disabled then
            return
        end

        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize

            if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                or Mouse.Y < (AbsPos.Y - (20 * DPIScale) - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                Dropdown:CloseDropdown()
            end
        end
    end)

    Dropdown:BuildDropdownList()
    Dropdown:Display()

    local Defaults = {}

    if typeof(Info.Default) == "string" then
        local DefaultIdx = table.find(Dropdown.Values, Info.Default)
        if DefaultIdx then
            table.insert(Defaults, DefaultIdx)
        end

    elseif typeof(Info.Default) == 'table' then
        for _, Value in next, Info.Default do
            local DefaultIdx = table.find(Dropdown.Values, Value)
            if DefaultIdx then
                table.insert(Defaults, DefaultIdx)
            end
        end

    elseif typeof(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
        table.insert(Defaults, Info.Default)
    end

    if next(Defaults) then
        for i = 1, #Defaults do
            local Index = Defaults[i]
            if Info.Multi then
                Dropdown.Value[Dropdown.Values[Index]] = true
            else
                Dropdown.Value = Dropdown.Values[Index]
            end

            if (not Info.Multi) then break end
        end

        Dropdown:BuildDropdownList()
        Dropdown:Display()
    end

    task.delay(0.1, Dropdown.UpdateColors, Dropdown)

    Dropdown.DisplayFrame = DropdownOuter
    Dropdown.Default = Defaults
    Dropdown.DefaultValues = Dropdown.Values

    Blank = Groupbox:AddBlank(5, Dropdown.Visible)
    Groupbox:Resize()

    Options[Idx] = Dropdown

    table.insert(Groupbox.Elements, Dropdown)

    return Dropdown
end

function BaseGroupboxFuncs:AddToggle(Idx, Info)
    assert(Info.Text, string.format('AddInput (IDX: %s): Missing `Text` string.', tostring(Idx)))

    local Toggle = {
        Value = Info.Default or false;
        Type = 'Toggle';
        Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        Risky = if typeof(Info.Risky) == "boolean" then Info.Risky else false;
        OriginalText = Info.Text; Text = Info.Text;
        Callback = Info.Callback or function(Value) end;
        Addons = {};
    }

    local Blank
    local Tooltip
    local Groupbox = self
    local Container = Groupbox.Container

    local ToggleContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -4, 0, 13);
        Visible = Toggle.Visible;
        ZIndex = 5;
        Parent = Container;
    })

    local ToggleOuter = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(0, 13, 0, 13);
        Visible = Toggle.Visible;
        ZIndex = 5;
        Parent = ToggleContainer;
    })

    Library:AddToRegistry(ToggleOuter, {
        BorderColor3 = 'Black';
    })

    local ToggleInner = Library:Create('Frame', {
        BackgroundColor3 = Library.SecondaryColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = ToggleOuter;
    })

    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 4);
        Parent = ToggleInner;
    })

    Library:AddToRegistry(ToggleInner, {
        BackgroundColor3 = 'SecondaryColor';
        BorderColor3 = 'OutlineColor';
    })

    local ToggleLabel = Library:CreateLabel({
        Size = UDim2.new(1, -19, 0, 11);
        Position = UDim2.new(0, 19, 0, 0);
        TextSize = 14;
        Text = Info.Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 6;
        Parent = ToggleContainer;
        RichText = true;
    })

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = ToggleLabel;
    })

    local ToggleRegion = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 170, 1, 0);
        ZIndex = 8;
        Parent = ToggleOuter;
    })

    Library:OnHighlight(ToggleRegion, ToggleOuter,
        { BorderColor3 = 'AccentColor' },
        { BorderColor3 = 'Black' },
        function()
            if Toggle.Disabled then
                return false
            end

            for _, Addon in next, Toggle.Addons do
                if Library:MouseIsOverFrame(Addon.DisplayFrame) then return false end
            end
            return true
        end
    )

    function Toggle:UpdateColors()
        Toggle:Display()
    end

    if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
        Tooltip = Library:AddToolTip(Info.Tooltip, Info.DisabledTooltip, ToggleRegion)
        Tooltip.Disabled = Toggle.Disabled
    end

    function Toggle:Display()
        if Toggle.Disabled then
            ToggleLabel.TextColor3 = Library.DisabledTextColor

            ToggleInner.BackgroundColor3 = Toggle.Value and Library.DisabledAccentColor or Library.SecondaryColor
            ToggleInner.BorderColor3 = Library.DisabledOutlineColor

            if Library.RegistryMap[ToggleInner] then
                Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'DisabledAccentColor' or 'SecondaryColor'
                Library.RegistryMap[ToggleInner].Properties.BorderColor3 = 'DisabledOutlineColor'
            end
            if Library.RegistryMap[ToggleLabel] then
                Library.RegistryMap[ToggleLabel].Properties.TextColor3 = 'DisabledTextColor'
            end

            return
        end

        ToggleLabel.TextColor3 = Toggle.Risky and Library.RiskColor or Color3.new(1, 1, 1)

        ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.SecondaryColor
        ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor

        if Library.RegistryMap[ToggleInner] then
            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'SecondaryColor'
            Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor'
        end

        if Library.RegistryMap[ToggleLabel] then
            Library.RegistryMap[ToggleLabel].Properties.TextColor3 = Toggle.Risky and 'RiskColor' or nil
        end
    end

    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
    end

    function Toggle:SetValue(Bool)
        if Toggle.Disabled then
            return
        end

        Bool = (not not Bool)

        Toggle.Value = Bool
        Toggle:Display()

        for _, Addon in next, Toggle.Addons do
            if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                Addon.Toggled = Bool
                Addon:Update()
            end
        end

        if not Toggle.Disabled then
            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        Library:UpdateDependencyBoxes()
        Library:UpdateDependencyGroupboxes()
    end

    function Toggle:SetVisible(Visibility)
        Toggle.Visible = Visibility

        ToggleOuter.Visible = Toggle.Visible
        if Blank then Blank.Visible = Toggle.Visible end

        Groupbox:Resize()
    end

    function Toggle:SetDisabled(Disabled)
        Toggle.Disabled = Disabled

        if Tooltip then
            Tooltip.Disabled = Disabled
        end

        Toggle:Display()
    end

    function Toggle:SetText(Text)
        if typeof(Text) == "string" then
            Toggle.Text = Text
            ToggleLabel.Text = Toggle.Text
        end
    end

    ToggleRegion.InputBegan:Connect(function(Input)
        if Toggle.Disabled then
            return
        end

        if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
            for _, Addon in next, Toggle.Addons do
                if Library:MouseIsOverFrame(Addon.DisplayFrame) then return end
            end

            Toggle:SetValue(not Toggle.Value)
            Library:AttemptSave()
        end
    end)

    if Toggle.Risky == true then
        Library:RemoveFromRegistry(ToggleLabel)

        ToggleLabel.TextColor3 = Library.RiskColor
        Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
    end

    Toggle:Display()
    Blank = Groupbox:AddBlank(Info.BlankSize or 5 + 2, Toggle.Visible)
    Groupbox:Resize()

    Toggle.TextLabel = ToggleLabel
    Toggle.Container = Container
    setmetatable(Toggle, BaseAddons)

    Toggle.Default = Toggle.Value

    table.insert(Groupbox.Elements, Toggle)
    Toggles[Idx] = Toggle

    Library:UpdateDependencyBoxes()
    Library:UpdateDependencyGroupboxes()

    return Toggle
end

function BaseGroupboxFuncs:AddSlider(Idx, Info)
    assert(Info.Default,    string.format('AddSlider (IDX: %s): Missing default value.', tostring(Idx)))
    assert(Info.Text,       string.format('AddSlider (IDX: %s): Missing slider text.', tostring(Idx)))
    assert(Info.Min,        string.format('AddSlider (IDX: %s): Missing minimum value.', tostring(Idx)))
    assert(Info.Max,        string.format('AddSlider (IDX: %s): Missing maximum value.', tostring(Idx)))
    assert(Info.Rounding,   string.format('AddSlider (IDX: %s): Missing rounding value.', tostring(Idx)))

    local Slider = {
        Value = Info.Default;
        Min = Info.Min;
        Max = Info.Max;
        Rounding = Info.Rounding;
        MaxSize = 232;
        Type = 'Slider';
        Visible = if typeof(Info.Visible) == "boolean" then Info.Visible else true;
        Disabled = if typeof(Info.Disabled) == "boolean" then Info.Disabled else false;
        OriginalText = Info.Text; Text = Info.Text;
        Prefix = typeof(Info.Prefix) == "string" and Info.Prefix or "";
        Suffix = typeof(Info.Suffix) == "string" and Info.Suffix or "";
        Callback = Info.Callback or function(Value) end;
    }

    local Blanks = {}
    local SliderText = nil
    local Groupbox = self
    local Container = Groupbox.Container
    local Tooltip

    if not Info.Compact then
        SliderText = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 10);
            TextSize = 14;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Bottom;
            Visible = Slider.Visible;
            ZIndex = 5;
            Parent = Container;
            RichText = true;
        })

        table.insert(Blanks, Groupbox:AddBlank(3, Slider.Visible))
    end

    local SliderOuter = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(1, -4, 0, 13);
        Visible = Slider.Visible;
        ZIndex = 5;
        Parent = Container;
    })

    SliderOuter:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
        Slider.MaxSize = SliderOuter.AbsoluteSize.X - 2
    end)

    Library:AddToRegistry(SliderOuter, {
        BorderColor3 = 'Black';
    })

    local SliderInner = Library:Create('Frame', {
        BackgroundColor3 = Library.SecondaryColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = SliderOuter;
    })

    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 4);
        Parent = SliderInner;
    })

    Library:AddToRegistry(SliderInner, {
        BackgroundColor3 = 'SecondaryColor';
        BorderColor3 = 'OutlineColor';
    })

    local Fill = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderColor3 = Library.AccentColorDark;
        Size = UDim2.new(0, 0, 1, 0);
        ZIndex = 7;
        Parent = SliderInner;
    })

    local FillUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 4);
        Parent = Fill;
    })

    Library:AddToRegistry(Fill, {
        BackgroundColor3 = 'AccentColor';
        BorderColor3 = 'AccentColorDark';
    })

    local HideBorderRight = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(1, 0, 0, 0);
        Size = UDim2.new(0, 1, 1, 0);
        ZIndex = 8;
        Parent = Fill;
    })

    Library:AddToRegistry(HideBorderRight, {
        BackgroundColor3 = 'AccentColor';
    })

    local DisplayLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 1, 0);
        TextSize = 14;
        Text = '无限';
        ZIndex = 9;
        Parent = SliderInner;
        RichText = true;
    })

    Library:OnHighlight(SliderOuter, SliderOuter,
        { BorderColor3 = 'AccentColor' },
        { BorderColor3 = 'Black' },
        function()
            return not Slider.Disabled
        end
    )

    if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
        Tooltip = Library:AddToolTip(Info.Tooltip, Info.DisabledTooltip, SliderOuter)
        Tooltip.Disabled = Slider.Disabled
    end

    function Slider:UpdateColors()
        if SliderText then
            SliderText.TextColor3 = Slider.Disabled and Library.DisabledAccentColor or Color3.new(1, 1, 1)
        end
        DisplayLabel.TextColor3 = Slider.Disabled and Library.DisabledAccentColor or Color3.new(1, 1, 1)

        HideBorderRight.BackgroundColor3 = Slider.Disabled and Library.DisabledAccentColor or Library.AccentColor

        Fill.BackgroundColor3 = Slider.Disabled and Library.DisabledAccentColor or Library.AccentColor
        Fill.BorderColor3 = Slider.Disabled and Library.DisabledOutlineColor or Library.AccentColorDark

        if Library.RegistryMap[HideBorderRight] then
            Library.RegistryMap[HideBorderRight].Properties.BackgroundColor3 = Slider.Disabled and 'DisabledAccentColor' or 'AccentColor'
        end

        if Library.RegistryMap[Fill] then
            Library.RegistryMap[Fill].Properties.BackgroundColor3 = Slider.Disabled and 'DisabledAccentColor' or 'AccentColor'
            Library.RegistryMap[Fill].Properties.BorderColor3 = Slider.Disabled and 'DisabledOutlineColor' or 'AccentColorDark'
        end
    end
    
    function Slider:Display()
        local CustomDisplayText = nil
        if Info.FormatDisplayValue then
            CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
        end

        if CustomDisplayText then
            DisplayLabel.Text = tostring(CustomDisplayText)
        else
            local FormattedValue = (Slider.Value == 0 or Slider.Value == -0) and "0" or tostring(Slider.Value)
            if Info.Compact then
                DisplayLabel.Text = string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, FormattedValue, Slider.Suffix)

            elseif Info.HideMax then
                DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, FormattedValue, Slider.Suffix)

            else
                DisplayLabel.Text = string.format("%s%s%s/%s%s%s", 
                    Slider.Prefix, FormattedValue, Slider.Suffix,
                    Slider.Prefix, tostring(Slider.Max), Slider.Suffix)
            end
        end

        local X = Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, 1)
        Fill.Size = UDim2.new(X, 0, 1, 0)

        HideBorderRight.Visible = not (X == 1 or X == 0)
    end

    function Slider:OnChanged(Func)
        Slider.Changed = Func
    end

    local function Round(Value)
        if Slider.Rounding == 0 then
            return math.floor(Value)
        end

        return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value))
    end

    function Slider:GetValueFromXScale(X)
        return Round(Library:MapValue(X, 0, 1, Slider.Min, Slider.Max))
    end
    
    function Slider:SetMax(Value)
        assert(Value > Slider.Min, '最大值不能小于当前最小值。')
        
        Slider.Value = math.clamp(Slider.Value, Slider.Min, Value)
        Slider.Max = Value
        Slider:Display()
    end
    
    function Slider:SetMin(Value)
        assert(Value < Slider.Max, '最小值不能大于当前最大值。')

        Slider.Value = math.clamp(Slider.Value, Value, Slider.Max)
        Slider.Min = Value
        Slider:Display()
    end

    function Slider:SetValue(Str)
        if Slider.Disabled then
            return
        end

        local Num = tonumber(Str)

        if (not Num) then
            return
        end

        Num = math.clamp(Num, Slider.Min, Slider.Max)

        Slider.Value = Num
        Slider:Display()

        if not Slider.Disabled then
            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end
    end

    function Slider:SetVisible(Visibility)
        Slider.Visible = Visibility

        if SliderText then SliderText.Visible = Slider.Visible end
        SliderOuter.Visible = Slider.Visible

        for _, Blank in pairs(Blanks) do
            Blank.Visible = Slider.Visible
        end

        Groupbox:Resize()
    end

    function Slider:SetDisabled(Disabled)
        Slider.Disabled = Disabled

        if Tooltip then
            Tooltip.Disabled = Disabled
        end

        Slider:UpdateColors()
    end

    function Slider:SetText(Text)
        if typeof(Text) == "string" then
            Slider.Text = Text

            if SliderText then SliderText.Text = Slider.Text end
            Slider:Display()
        end
    end

    function Slider:SetPrefix(Prefix)
        if typeof(Prefix) == "string" then
            Slider.Prefix = Prefix
            Slider:Display()
        end
    end

    function Slider:SetSuffix(Suffix)
        if typeof(Suffix) == "string" then
            Slider.Suffix = Suffix
            Slider:Display()
        end
    end

    SliderInner.InputBegan:Connect(function(Input)
        if Slider.Disabled then
            return
        end

        if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
            if Library.IsMobile then
                Library.CanDrag = false
            end

            local Sides = {}
            if Library.Window then
                Sides = Library.Window.Tabs[Library.ActiveTab]:GetSides()
            end

            for _, Side in pairs(Sides) do
                if typeof(Side) == "Instance" then
                    if Side:IsA("ScrollingFrame") then
                        Side.ScrollingEnabled = false
                    end
                end
            end

            local mPos = Mouse.X
            local gPos = Fill.AbsoluteSize.X
            local Diff = mPos - (Fill.AbsolutePosition.X + gPos)

            while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch) do
                local nMPos = Mouse.X
                local nXOffset = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize)
                local nXScale = Library:MapValue(nXOffset, 0, Slider.MaxSize, 0, 1)

                local nValue = Slider:GetValueFromXScale(nXScale)
                local OldValue = Slider.Value
                Slider.Value = nValue

                Slider:Display()

                if nValue ~= OldValue then
                    Library:SafeCallback(Slider.Callback, Slider.Value)
                    Library:SafeCallback(Slider.Changed, Slider.Value)
                end

                RunService.RenderStepped:Wait()
            end

            if Library.IsMobile then
                Library.CanDrag = true
            end
            
            for _, Side in pairs(Sides) do
                if typeof(Side) == "Instance" then
                    if Side:IsA("ScrollingFrame") then
                        Side.ScrollingEnabled = true
                    end
                end
            end

            Library:AttemptSave()
        end
    end)

    task.delay(0.1, Slider.UpdateColors, Slider)
    Slider:Display()
    table.insert(Blanks, Groupbox:AddBlank(Info.BlankSize or 6, Slider.Visible))
    Groupbox:Resize()

    Slider.Default = Slider.Value

    table.insert(Groupbox.Elements, Slider)
    Options[Idx] = Slider

    return Slider
end

    BaseGroupbox.__index = BaseGroupboxFuncs
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return BaseGroupboxFuncs[Key](...)
    end
end

local KeybindOuter = Library:Create('Frame', {
    AnchorPoint = Vector2.new(0, 0.5);
    BorderColor3 = Color3.new(0, 0, 0);
    Position = UDim2.new(0, 10, 0.5, 0);
    Size = UDim2.new(0, 210, 0, 20);
    Visible = false;
    ZIndex = 100;
    Parent = ScreenGui;
})

local KeybindInner = Library:Create('Frame', {
    BackgroundColor3 = Library.MainColor;
    BorderColor3 = Library.OutlineColor;
    BorderMode = Enum.BorderMode.Inset;
    Size = UDim2.new(1, 0, 1, 0);
    ZIndex = 101;
    Parent = KeybindOuter;
})

local UICorner = Library:Create('UICorner', {
    CornerRadius = UDim.new(0, 6);
    Parent = KeybindInner;
})

local UIStroke = Library:Create('UIStroke', {
    Color = Library.AccentColor;
    Thickness = 1;
    Parent = KeybindInner;
})

Library:AddToRegistry(KeybindInner, {
    BackgroundColor3 = 'MainColor';
    BorderColor3 = 'OutlineColor';
}, true)

Library:AddToRegistry(UIStroke, {
    Color = 'AccentColor';
}, true)

local ColorFrame = Library:Create('Frame', {
    BackgroundColor3 = Library.AccentColor;
    BorderSizePixel = 0;
    Size = UDim2.new(1, 0, 0, 2);
    ZIndex = 102;
    Parent = KeybindInner;
})

Library:AddToRegistry(ColorFrame, {
    BackgroundColor3 = 'AccentColor';
}, true)

local _KeybindLabel = Library:CreateLabel({
    Size = UDim2.new(1, 0, 0, 20);
    Position = UDim2.fromOffset(5, 2),
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = '快捷键';
    ZIndex = 104;
    Parent = KeybindInner;
})
Library:MakeDraggable(KeybindOuter)

local KeybindContainer = Library:Create('Frame', {
    BackgroundTransparency = 1;
    Size = UDim2.new(1, 0, 1, -20);
    Position = UDim2.new(0, 0, 0, 20);
    ZIndex = 1;
    Parent = KeybindInner;
})

Library:Create('UIListLayout', {
    FillDirection = Enum.FillDirection.Vertical;
    SortOrder = Enum.SortOrder.LayoutOrder;
    Parent = KeybindContainer;
})

Library:Create('UIPadding', {
    PaddingLeft = UDim.new(0, 5),
    Parent = KeybindContainer,
})

Library.KeybindFrame = KeybindOuter
Library.KeybindContainer = KeybindContainer
Library:MakeDraggable(KeybindOuter)

do
    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, -25);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    })

    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    })

    local UICorner2 = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = WatermarkInner;
    })

    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor';
    })

    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 202;
        Parent = WatermarkInner;
    })

    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    })

    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            })
        end
    })

    local WatermarkLabel = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 203;
        Parent = InnerFrame;
    })

    Library.Watermark = WatermarkOuter
    Library.WatermarkText = WatermarkLabel
    Library:MakeDraggable(Library.Watermark)

    function Library:SetWatermarkVisibility(Bool)
        Library.Watermark.Visible = Bool
    end

    function Library:SetWatermark(Text)
        local X, Y = Library:GetTextBounds(Text, Library.Font, 14)
        Library.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3)
        Library:SetWatermarkVisibility(true)

        Library.WatermarkText.Text = Text
    end
end

do
    Library.LeftNotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 100;
        Parent = ScreenGui;
    })

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Library.LeftNotificationArea;
    })


    Library.RightNotificationArea = Library:Create('Frame', {
        AnchorPoint = Vector2.new(1, 0);
        BackgroundTransparency = 1;
        Position = UDim2.new(1, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 100;
        Parent = ScreenGui;
    })

    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Library.RightNotificationArea;
    })
        
    function Library:SetNotifySide(Side)
        Library.NotifySide = Side
    end

    function Library:Notify(...)
        local Data = {}
        local Info = select(1, ...)

        if typeof(Info) == "table" then
            Data.Title = Info.Title and tostring(Info.Title) or ""
            Data.Description = tostring(Info.Description)
            Data.Time = Info.Time or 5
            Data.SoundId = Info.SoundId
            Data.Steps = Info.Steps
            Data.Persist = Info.Persist
            Data.Icon = Info.Icon
        else
            Data.Title = ""
            Data.Description = tostring(Info)
            Data.Time = select(2, ...) or 5
            Data.SoundId = select(3, ...)
        end
        Data.Destroyed = false

        local DeletedInstance = false
        local DeleteConnection = nil
        if typeof(Data.Time) == "Instance" then
            DeleteConnection = Data.Time.Destroying:Connect(function()
                DeletedInstance = true
                DeleteConnection:Disconnect()
                DeleteConnection = nil
            end)
        end

        local Side = string.lower(Library.NotifySide)
        local XSize, YSize = Library:GetTextBounds(Data.Description, Library.Font, 14)
        YSize = YSize + 7

        local NotifyOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(0, 0, 0, YSize);
            ClipsDescendants = true;
            ZIndex = 100;
            Visible = false;
            Parent = Side == "left" and Library.LeftNotificationArea or Library.RightNotificationArea;
        })

        local NotifyInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 101;
            Parent = NotifyOuter;
        })

        local UICorner = Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 6);
            Parent = NotifyInner;
        })

        local UIStroke = Library:Create('UIStroke', {
            Color = Library.AccentColor;
            Thickness = 1;
            Parent = NotifyInner;
        })

        Library:AddToRegistry(NotifyInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        }, true)

        Library:AddToRegistry(UIStroke, {
            Color = 'AccentColor';
        }, true)

        local InnerFrame = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 102;
            Parent = NotifyInner;
        })

        local Gradient = Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
            Rotation = -90;
            Parent = InnerFrame;
        })

        Library:AddToRegistry(Gradient, {
            Color = function()
                return ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                    ColorSequenceKeypoint.new(1, Library.MainColor),
                })
            end
        })

        local NotifyLabel = Library:CreateLabel({
            AnchorPoint = Side == "left" and Vector2.new(0, 0) or Vector2.new(1, 0);
            Position = Side == "left" and UDim2.new(0, 4, 0, 0) or UDim2.new(1, -4, 0, 0);
            Size = UDim2.new(1, -4, 1, 0);
            Text = (Data.Title == "" and "" or "[" .. Data.Title .. "] ") .. tostring(Data.Description);
            TextXAlignment = Side == "left" and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right;
            TextSize = 14;
            ZIndex = 103;
            RichText = true;
            Parent = InnerFrame;
        })

        local SideColor = Library:Create('Frame', {
            AnchorPoint = Side == "left" and Vector2.new(0, 0) or Vector2.new(1, 0);
            Position = Side == "left" and UDim2.new(0, -1, 0, -1) or UDim2.new(1, -1, 0, -1);
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(0, 3, 1, 2);
            ZIndex = 104;
            Parent = NotifyOuter;
        })

        Library:AddToRegistry(SideColor, {
            BackgroundColor3 = 'AccentColor';
        }, true)

        if Data.Icon then
            local IconFrame = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Size = UDim2.new(0, 20, 0, 20);
                Position = UDim2.new(0, 4, 0.5, -10);
                ZIndex = 105;
                Parent = InnerFrame;
            })

            local Icon = Library:GetCustomIcon(Data.Icon)
            if Icon then
                Library:Create('ImageLabel', {
                    BackgroundTransparency = 1;
                    Size = UDim2.new(1, 0, 1, 0);
                    Image = Icon.Url;
                    ImageRectOffset = Icon.ImageRectOffset;
                    ImageRectSize = Icon.ImageRectSize;
                    ImageColor3 = Library.AccentColor;
                    ZIndex = 106;
                    Parent = IconFrame;
                })
            end
            
            NotifyLabel.Position = Side == "left" and UDim2.new(0, 28, 0, 0) or UDim2.new(1, -28, 0, 0)
            NotifyLabel.Size = UDim2.new(1, -32, 1, 0)
        end

        function Data:Resize()
            XSize, YSize = Library:GetTextBounds(NotifyLabel.Text, Library.Font, 14)
            YSize = YSize + 7
            
            pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize * DPIScale + 8 + 4 + (Data.Icon and 24 or 0), 0, YSize), 'Out', 'Quad', 0.4, true)
        end

        function Data:ChangeTitle(NewText)
            NewText = NewText == nil and "" or tostring(NewText)
            Data.Title = NewText
            NotifyLabel.Text = (Data.Title == "" and "" or "[" .. Data.Title .. "] ") .. tostring(Data.Description)
            Data:Resize()
        end

        function Data:ChangeDescription(NewText)
            if NewText == nil then return end
            NewText = tostring(NewText)
            Data.Description = NewText
            NotifyLabel.Text = (Data.Title == "" and "" or "[" .. Data.Title .. "] ") .. tostring(Data.Description)
            Data:Resize()
        end

        function Data:ChangeStep(...)
        end

        function Data:Destroy()
            Data.Destroyed = true

            if typeof(Data.Time) == "Instance" then
                pcall(Data.Time.Destroy, Data.Time)
            end
            
            if DeleteConnection then
                DeleteConnection:Disconnect()
            end

            pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true)
            task.wait(0.4)
            NotifyOuter:Destroy()
        end

        Data:Resize()

        if Data.SoundId then
            Library:Create('Sound', {
                SoundId = "rbxassetid://" .. tostring(Data.SoundId):gsub("rbxassetid://", "");
                Volume = 3;
                PlayOnRemove = true;
                Parent = game:GetService("SoundService");
            }):Destroy()
        end

        NotifyOuter.Visible = true
        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize * DPIScale + 8 + 4 + (Data.Icon and 24 or 0), 0, YSize), 'Out', 'Quad', 0.4, true)

        task.delay(0.4, function()
            if Data.Persist then
                return
            elseif typeof(Data.Time) == "Instance" then
                repeat
                    task.wait()
                until DeletedInstance or Data.Destroyed
            else
                task.wait(Data.Time or 5)
            end

            if not Data.Destroyed then
                Data:Destroy()
            end
        end)

        return Data
    end
end

function Library:CreateWindow(...)
    local Arguments = { ... }
    local WindowInfo = Templates.Window

    if typeof(Arguments[1]) == "table" then
        WindowInfo = Library:Validate(Arguments[1], Templates.Window)
    else
        WindowInfo = Library:Validate({
            Title = Arguments[1],
            AutoShow = Arguments[2] or false
        }, Templates.Window)
    end

    local ViewportSize = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    if WindowInfo.Size == UDim2.fromOffset(0, 0) then
        WindowInfo.Size = if Library.IsMobile then UDim2.fromOffset(550, math.clamp(ViewportSize.Y - 35, 200, 600)) else UDim2.fromOffset(550, 600)
    end

    Library.NotifySide = WindowInfo.NotifySide
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor

    if WindowInfo.TabPadding <= 0 then WindowInfo.TabPadding = 1 end
    if WindowInfo.Center then WindowInfo.Position = UDim2.new(0.5, -WindowInfo.Size.X.Offset / 2, 0.5, -WindowInfo.Size.Y.Offset / 2) end

    local Window = {
        Tabs = {};
        OriginalTitle = WindowInfo.Title; 
        Title = WindowInfo.Title;
    }

    local Outer = Library:Create('Frame', {
        AnchorPoint = WindowInfo.AnchorPoint;
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderSizePixel = 0;
        Position = WindowInfo.Position;
        Size = WindowInfo.Size;
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
        Name = "Window";
    })
    LibraryMainOuterFrame = Outer
    
    local OuterUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 12);
        Parent = Outer;
    })
    
    local AcrylicFrame = Library:Create('Frame', {
        BackgroundTransparency = 0.85;
        BackgroundColor3 = Color3.fromRGB(28, 28, 28);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 0;
        Parent = Outer;
    })
    
    local NoiseTexture = Library:Create('ImageLabel', {
        Image = "rbxassetid://9968331586";
        ImageTransparency = 0.85;
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 1;
        Parent = AcrylicFrame;
    })
    
    local OuterGlow = Library:Create('ImageLabel', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(1, 24, 1, 24);
        Image = "rbxassetid://8992230673";
        ImageColor3 = Library.AccentColor;
        ImageTransparency = 0.6;
        ScaleType = Enum.ScaleType.Slice;
        SliceCenter = Rect.new(20, 20, 280, 280);
        ZIndex = 0;
        Visible = Library.GlowEnabled;
        Parent = Outer;
    })

    Library:AddToRegistry(OuterGlow, {
        ImageColor3 = 'AccentColor';
    })

Library:MakeDraggable(Outer, 25, true)
if WindowInfo.Resizable then 
    Library:MakeResizable(Outer, Library.MinSize)
end

local Inner = Library:Create('Frame', {
    BackgroundColor3 = Library.MainColor;
    BorderColor3 = Library.AccentColor;
    BorderMode = Enum.BorderMode.Inset;
    Position = UDim2.new(0, 1, 0, 1);
    Size = UDim2.new(1, -2, 1, -2);
    ZIndex = 2;
    Parent = Outer;
})

    local InnerUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 10);
        Parent = Inner;
    })

    local InnerUIStroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        Thickness = 1;
        Transparency = 0.5;
        Parent = Inner;
    })

    Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'AccentColor';
    })

    Library:AddToRegistry(InnerUIStroke, {
        Color = 'AccentColor';
    })

    local WindowLabel = Library:CreateLabel({
        Position = UDim2.new(0, 7, 0, 0);
        Size = UDim2.new(0, 0, 0, 25);
        Text = WindowInfo.Title or '';
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 3;
        Parent = Inner;
    })

    local MainSectionOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 25);
        Size = UDim2.new(1, -16, 1, -33);
        ZIndex = 3;
        Parent = Inner;
    })

    local MainSectionUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 8);
        Parent = MainSectionOuter;
    })

    Library:AddToRegistry(MainSectionOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
    })

    local MainSectionInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);
        BorderMode = Enum.BorderMode.Inset;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 3;
        Parent = MainSectionOuter;
    })

    Library:AddToRegistry(MainSectionInner, {
        BackgroundColor3 = 'BackgroundColor';
    })

    local TabArea = Library:Create('ScrollingFrame', {
        ScrollingDirection = Enum.ScrollingDirection.X;
        CanvasSize = UDim2.new(0, 0, 2, 0);
        HorizontalScrollBarInset = Enum.ScrollBarInset.Always;
        AutomaticCanvasSize = Enum.AutomaticSize.XY;
        ScrollBarThickness = 0;
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 8 - WindowInfo.TabPadding, 0, 4);
        Size = UDim2.new(1, -10, 0, 26);
        ZIndex = 3;
        Parent = MainSectionInner;
    })

    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, WindowInfo.TabPadding);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        Parent = TabArea;
    })

    Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Size = UDim2.new(0, 0, 0, 0);
        LayoutOrder = -1;
        BackgroundTransparency = 1;
        ZIndex = 1;
        Parent = TabArea;
    })
    Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        Size = UDim2.new(0, 0, 0, 0);
        LayoutOrder = 9999999;
        BackgroundTransparency = 1;
        ZIndex = 1;
        Parent = TabArea;
    })

    local TabContainer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        Position = UDim2.new(0, 8, 0, 30);
        Size = UDim2.new(1, -16, 1, -38);
        ZIndex = 4;
        Parent = MainSectionInner;
    })
    
    local TabContainerUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 8);
        Parent = TabContainer;
    })

    local InnerVideoBackground = Library:Create('VideoFrame', {
        BackgroundColor3 = Library.MainColor;
        BorderMode = Enum.BorderMode.Inset;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 4;
        Visible = false;
        Volume = 0;
        Looped = true;
        Parent = TabContainer;
    })
    Library.InnerVideoBackground = InnerVideoBackground

    Library:AddToRegistry(TabContainer, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    })

    function Window:SetWindowTitle(Title)
        if typeof(Title) == "string" then
            Window.Title = Title
            WindowLabel.Text = Window.Title
        end
    end

    function Window:AddTab(Name)
        local Tab = {
            Groupboxes = {};
            Tabboxes = {};
            DependencyGroupboxes = {};
            WarningBox = {
                Bottom = false,
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "警告",
                Text = ""
            };
            OriginalName = Name; 
            Name = Name;
            TableType = "Tab";
        }

        local TabButtonWidth = Library:GetTextBounds(Tab.Name, Library.Font, 16)

        local TabButton = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Size = UDim2.new(0, TabButtonWidth + 12, 0.85, 0);
            ZIndex = 3;
            Parent = TabArea;
        })

        local TabButtonUICorner = Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 6);
            Parent = TabButton;
        })

        Library:AddToRegistry(TabButton, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        })

        local TabButtonLabel = Library:CreateLabel({
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, -1);
            Text = Tab.Name;
            ZIndex = 3;
            Parent = TabButton;
        })

        local Blocker = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, 0);
            Size = UDim2.new(1, 0, 0, 1);
            BackgroundTransparency = 1;
            ZIndex = 5;
            Parent = TabButton;
        })

        Library:AddToRegistry(Blocker, {
            BackgroundColor3 = 'MainColor';
        })

        local TabFrame = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            Visible = false;
            ZIndex = 4;
            Parent = TabContainer;
        })
        
        local TopBarLabelStroke
        local TopBarHighlight
        local TopBar, TopBarInner, TopBarLabel, TopBarTextLabel, TopBarScrollingFrame
do
            TopBar = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.fromRGB(248, 51, 51);
                BorderMode = Enum.BorderMode.Inset;
                Position = UDim2.new(0, 7, 0, 7);
                Size = UDim2.new(1, -13, 0, 0);
                ZIndex = 4;
                Parent = TabFrame;
                Visible = false;
            })

            local TopBarUICorner = Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 6);
                Parent = TopBar;
            })

            TopBarInner = Library:Create('Frame', {
                BackgroundColor3 = Color3.fromRGB(117, 22, 17);
                BorderColor3 = Color3.new();
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 6;
                Parent = TopBar;
            })

            TopBarHighlight = Library:Create('Frame', {
                BackgroundColor3 = Color3.fromRGB(255, 75, 75);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 7;
                Parent = TopBarInner;
            })

            TopBarScrollingFrame = Library:Create('ScrollingFrame', {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Size = UDim2.new(1, -8, 1, 0);
                CanvasSize = UDim2.new(0, 0, 0, 0);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollBarThickness = 3;
                ZIndex = 7;
                Parent = TopBarInner;
            })

            TopBarLabel = Library:Create('TextLabel', {
                BackgroundTransparency = 1;
                Font = Library.Font;
                TextStrokeTransparency = 0;
                RichText = true;
                Size = UDim2.new(1, 0, 0, 18);
                Position = UDim2.new(0, 4, 0, 2);
                TextSize = 14;
                Text = "文本";
                TextXAlignment = Enum.TextXAlignment.Left;
                TextColor3 = Color3.fromRGB(255, 55, 55);
                ZIndex = 7;
                Parent = TopBarScrollingFrame;
            })

            TopBarLabelStroke = Library:ApplyTextStroke(TopBarLabel)
            TopBarLabelStroke.Color = Color3.fromRGB(174, 3, 3)

            TopBarTextLabel = Library:CreateLabel({
                RichText = true;
                Position = UDim2.new(0, 4, 0, 20);
                Size = UDim2.new(1, 0, 0, 14);
                TextSize = 14;
                Text = "文本";
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Top;
                ZIndex = 7;
                Parent = TopBarScrollingFrame;
            })
            
            Library:Create('Frame', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 5);
                Visible = true;
                ZIndex = 1;
                Parent = TopBarInner;
            })
        end
        
        local LeftSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 7, 0, 7);
            Size = UDim2.new(0.5, -10, 1, -14);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 4;
            Parent = TabFrame;
        })

        local RightSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 5, 0, 7);
            Size = UDim2.new(0.5, -10, 1, -14);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 4;
            Parent = TabFrame;
        })

        Tab.LeftSideFrame = LeftSide
        Tab.RightSideFrame = RightSide

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = LeftSide;
        })

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 8);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = RightSide;
        })

        if Library.IsMobile then
            local SidesValues = {
                ["Left"] = tick(),
                ["Right"] = tick(),
            }

            LeftSide:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
                Library.CanDrag = false

                local ChangeTick = tick()
                SidesValues.Left = ChangeTick
                task.wait(0.15)

                if SidesValues.Left == ChangeTick then
                    Library.CanDrag = true
                end
            end)

            RightSide:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
                Library.CanDrag = false

                local ChangeTick = tick()
                SidesValues.Right = ChangeTick
                task.wait(0.15)
                
                if SidesValues.Right == ChangeTick then
                    Library.CanDrag = true
                end
            end)
        end

        for _, Side in next, { LeftSide, RightSide } do
            Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y)
            end)
        end

        function Tab:Resize()
            if TopBar.Visible == true then
                local MaximumSize = math.floor(TabFrame.AbsoluteSize.Y / 3.25)
                local Size = 27 + select(2, Library:GetTextBounds(TopBarTextLabel.Text, Library.Font, 14, Vector2.new(TopBarTextLabel.AbsoluteSize.X, math.huge)))

                if Tab.WarningBox.LockSize == true and Size >= MaximumSize then 
                    Size = MaximumSize
                end

                if Tab.WarningBox.Bottom == true then
                    TopBar.Position = UDim2.new(0, 7, 1, -(Size + 7))
                else
                    TopBar.Position = UDim2.new(0, 7, 0, 7)
                end

                TopBar.Size = UDim2.new(1, -13, 0, Size)
                Size = Size + 10
                
                if TopBar.Position.Y.Offset > 0 then
                    LeftSide.Position = UDim2.new(0, 7, 0, 7 + Size)
                    LeftSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
            
                    RightSide.Position = UDim2.new(0.5, 5, 0, 7 + Size)
                    RightSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
                else
                    LeftSide.Position = UDim2.new(0, 7, 0, 7)
                    LeftSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
            
                    RightSide.Position = UDim2.new(0.5, 5, 0, 7)
                    RightSide.Size = UDim2.new(0.5, -10, 1, -14 - Size)
                end
            else
                LeftSide.Position = UDim2.new(0, 7, 0, 7)
                LeftSide.Size = UDim2.new(0.5, -10, 1, -14)
        
                RightSide.Position = UDim2.new(0.5, 5, 0, 7)
                RightSide.Size = UDim2.new(0.5, -10, 1, -14)
            end
        end

        function Tab:UpdateWarningBox(Info)
            if typeof(Info.Bottom) == "boolean"     then Tab.WarningBox.Bottom      = Info.Bottom end
            if typeof(Info.IsNormal) == "boolean"   then Tab.WarningBox.IsNormal      = Info.IsNormal end
            if typeof(Info.LockSize) == "boolean"   then Tab.WarningBox.LockSize    = Info.LockSize end
            if typeof(Info.Visible) == "boolean"    then Tab.WarningBox.Visible     = Info.Visible end
            if typeof(Info.Title) == "string"       then Tab.WarningBox.Title       = Info.Title end
            if typeof(Info.Text) == "string"        then Tab.WarningBox.Text        = Info.Text end

            TopBar.Visible = Tab.WarningBox.Visible
            TopBarLabel.Text = Tab.WarningBox.Title
            TopBarTextLabel.Text = Tab.WarningBox.Text
            if TopBar.Visible then Tab:Resize() end

            TopBar.BorderColor3 = Tab.WarningBox.IsNormal == true and Color3.fromRGB(27, 42, 53) or Color3.fromRGB(248, 51, 51)
            TopBarInner.BorderColor3 = Tab.WarningBox.IsNormal == true and Library.OutlineColor or Color3.fromRGB(0, 0, 0)
            TopBarInner.BackgroundColor3 = Tab.WarningBox.IsNormal == true and Library.BackgroundColor or Color3.fromRGB(117, 22, 17)
            TopBarHighlight.BackgroundColor3 = Tab.WarningBox.IsNormal == true and Library.AccentColor or Color3.fromRGB(255, 75, 75)
             
            TopBarLabel.TextColor3 = Tab.WarningBox.IsNormal == true and Library.FontColor or Color3.fromRGB(255, 55, 55)
            TopBarLabelStroke.Color = Tab.WarningBox.IsNormal == true and Library.Black or Color3.fromRGB(174, 3, 3)

            if not Library.RegistryMap[TopBarInner] then Library:AddToRegistry(TopBarInner, {}) end
            if not Library.RegistryMap[TopBarHighlight] then Library:AddToRegistry(TopBarHighlight, {}) end
            if not Library.RegistryMap[TopBarLabel] then Library:AddToRegistry(TopBarLabel, {}) end
            if not Library.RegistryMap[TopBarLabelStroke] then Library:AddToRegistry(TopBarLabelStroke, {}) end

            Library.RegistryMap[TopBarInner].Properties.BorderColor3 = Tab.WarningBox.IsNormal == true and "OutlineColor" or nil
            Library.RegistryMap[TopBarInner].Properties.BackgroundColor3 = Tab.WarningBox.IsNormal == true and "BackgroundColor" or nil
            Library.RegistryMap[TopBarHighlight].Properties.BackgroundColor3 = Tab.WarningBox.IsNormal == true and "AccentColor" or nil

            Library.RegistryMap[TopBarLabel].Properties.TextColor3 = Tab.WarningBox.IsNormal == true and "FontColor" or nil
            Library.RegistryMap[TopBarLabelStroke].Properties.Color = Tab.WarningBox.IsNormal == true and "Black" or nil
        end

        function Tab.ShowTab()
            Library.ActiveTab = Name
            for _, Tab in next, Window.Tabs do
                Tab:HideTab()
            end

            Blocker.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Library.MainColor
            if Library.RegistryMap[TabButton] then
                Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor'
            end
            TabFrame.Visible = true

            Tab:Resize()
        end
        Tab.Show = Tab.ShowTab

        function Tab:HideTab()
            Blocker.BackgroundTransparency = 1
            TabButton.BackgroundColor3 = Library.BackgroundColor
            if Library.RegistryMap[TabButton] then
                Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor'
            end
            TabFrame.Visible = false
        end
        Tab.Hide = Tab.HideTab

        function Tab:SetLayoutOrder(Position)
            TabButton.LayoutOrder = Position
            TabListLayout:ApplyLayout()
        end

        function Tab:GetSides()
            return { ["Left"] = LeftSide, ["Right"] = RightSide }
        end

        function Tab:SetName(Name)
            if typeof(Name) == "string" then
                Tab.Name = Name

                local TabButtonWidth = Library:GetTextBounds(Tab.Name, Library.Font, 16)

                TabButton.Size = UDim2.new(0, TabButtonWidth + 12, 0.85, 0)
                TabButtonLabel.Text = Tab.Name
            end
        end

        function Tab:AddGroupbox(Info)
            local Groupbox = {
                Elements = {};
                Side = Info.Side;
                Tab = Tab;
                TableType = "Groupbox";
            }

            local sideFrame = Info.Side == 1 and Tab.LeftSideFrame or Tab.RightSideFrame
            if not sideFrame then
                warn("Side frame not found for groupbox")
                return nil
            end

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 50);
                ZIndex = 4;
                Parent = sideFrame;
            })

            local BoxUICorner = Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 8);
                Parent = BoxOuter;
            })

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            })

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 6;
                Parent = BoxOuter;
            })

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            })

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 7;
                Parent = BoxInner;
            })

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            })

            Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 18);
                Position = UDim2.new(0, 4, 0, 2);
                TextSize = 14;
                Text = Info.Name;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 7;
                Parent = BoxInner;
            })

            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 4, 0, 20);
                Size = UDim2.new(1, -4, 1, -20);
                ZIndex = 3;
                Parent = BoxInner;
            })

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Container;
            })

            function Groupbox:Resize()
                local Size = 0

                for _, Element in next, Groupbox.Container:GetChildren() do
                    if Element:IsA('GuiObject') and Element.Visible then
                        Size = Size + Element.Size.Y.Offset
                    end
                end

                BoxOuter.Size = UDim2.new(1, 0, 0, (20 * DPIScale + Size) + 2 + 2)
            end

            Groupbox.Container = Container
            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:AddBlank(3)
            Groupbox:Resize()

            Tab.Groupboxes[Info.Name] = Groupbox

            return Groupbox
        end

        function Tab:AddLeftGroupbox(Name)
            return Tab:AddGroupbox({ Side = 1; Name = Name; })
        end

        function Tab:AddRightGroupbox(Name)
            return Tab:AddGroupbox({ Side = 2; Name = Name; })
        end

        function Tab:AddTabbox(Info)
            local Tabbox = {
                Tabs = {};
            }

            local sideFrame = Info.Side == 1 and Tab.LeftSideFrame or Tab.RightSideFrame
            if not sideFrame then
                warn("Side frame not found for tabbox")
                return nil
            end

            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 0, 0);
                ZIndex = 4;
                Parent = sideFrame;
            })

            local BoxUICorner = Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 8);
                Parent = BoxOuter;
            })

            Library:AddToRegistry(BoxOuter, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            })

            local BoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                ZIndex = 6;
                Parent = BoxOuter;
            })

            Library:AddToRegistry(BoxInner, {
                BackgroundColor3 = 'BackgroundColor';
            })

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 12;
                Parent = BoxInner;
            })

            Library:AddToRegistry(Highlight, {
                BackgroundColor3 = 'AccentColor';
            })

            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 1);
                Size = UDim2.new(1, 0, 0, 18);
                ZIndex = 7;
                Parent = BoxInner;
            })

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TabboxButtons;
            })
            
            function Tabbox:AddTab(Name)
                local Tab = {
                    Elements = {};
                    Container = nil;
                    TableType = "TabboxTab";
                }

                local Button = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(0.5, 0, 1, 0);
                    ZIndex = 8;
                    Parent = TabboxButtons;
                })

                local ButtonUICorner = Library:Create('UICorner', {
                    CornerRadius = UDim.new(0, 6);
                    Parent = Button;
                })

                Library:AddToRegistry(Button, {
                    BackgroundColor3 = 'MainColor';
                })

                Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    TextSize = 14;
                    Text = Name;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    ZIndex = 9;
                    Parent = Button;
                    RichText = true;
                })

                local Block = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, 0);
                    Size = UDim2.new(1, 0, 0, 1);
                    Visible = false;
                    ZIndex = 11;
                    Parent = Button;
                })

                Library:AddToRegistry(Block, {
                    BackgroundColor3 = 'BackgroundColor';
                })

                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 4, 0, 20);
                    Size = UDim2.new(1, -4, 1, -20);
                    ZIndex = 3;
                    Visible = false;
                    Parent = BoxInner;
                })

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Container;
                })

                function Tab:Show()
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide()
                    end

                    Container.Visible = true
                    Block.Visible = true

                    Button.BackgroundColor3 = Library.BackgroundColor
                    if Library.RegistryMap[Button] then
                        Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor'
                    end

                    Tab:Resize()
                end

                function Tab:Hide()
                    Container.Visible = false
                    Block.Visible = false

                    Button.BackgroundColor3 = Library.MainColor
                    if Library.RegistryMap[Button] then
                        Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor'
                    end
                end

                function Tab:Resize()
                    local TabCount = 0

                    for _, Tab in next, Tabbox.Tabs do
                        TabCount = TabCount + 1
                    end

                    for _, Button in next, TabboxButtons:GetChildren() do
                        if Button:IsA('GuiObject') then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0)
                        end
                    end

                    if (not Container.Visible) then
                        return
                    end

                    local Size = 0

                    for _, Element in next, Tab.Container:GetChildren() do
                        if Element:IsA('GuiObject') and Element.Visible then
                            Size = Size + Element.Size.Y.Offset
                        end
                    end

                    BoxOuter.Size = UDim2.new(1, 0, 0, (20 * DPIScale + Size) + 2 + 2)
                end

                Button.InputBegan:Connect(function(Input)
                    if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame()) or Input.UserInputType == Enum.UserInputType.Touch then
                        Tab:Show()
                        Tab:Resize()
                    end
                end)

                Tab.Container = Container
                Tabbox.Tabs[Name] = Tab

                setmetatable(Tab, BaseGroupbox)

                Tab:AddBlank(3)
                Tab:Resize()

                if #TabboxButtons:GetChildren() == 2 then
                    Tab:Show()
                end

                return Tab
            end

            Tab.Tabboxes[Info.Name or ''] = Tabbox

            return Tabbox
        end

        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 1; })
        end

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Name = Name, Side = 2; })
        end

        TabButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Tab:ShowTab()
            end
        end)

        TopBar:GetPropertyChangedSignal("Visible"):Connect(function()
            Tab:Resize()
        end)

        Library.TotalTabs = Library.TotalTabs + 1
        if Library.TotalTabs == 1 then
            Tab:ShowTab()
        end

        Window.Tabs[Name] = Tab
        return Tab
    end

    local TransparencyCache = {}
    local Toggled = false
    local Fading = false
    
    function Library:Toggle(Toggling)
        if typeof(Toggling) == "boolean" and Toggling == Toggled then return end
        if Fading then return end

        local FadeTime = WindowInfo.MenuFadeTime
        Fading = true
        Toggled = (not Toggled)

        Library.Toggled = Toggled
        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = Library.Toggled
        end

        if Toggled then
            Outer.Visible = true

            if Library.BlurEnabled and not Library.IsMobile then
                local Blur = Instance.new("BlurEffect")
                Blur.Size = 8
                Blur.Name = "LinoriaBlur"
                Blur.Parent = Lighting
            end

            if DrawingLib.drawing_replaced ~= true and IsBadDrawingLib ~= true then
                IsBadDrawingLib = not (pcall(function()
                    local Cursor = DrawingLib.new("Triangle")
                    Cursor.Thickness = 1
                    Cursor.Filled = true
                    Cursor.Visible = Library.ShowCustomCursor

                    local CursorOutline = DrawingLib.new("Triangle")
                    CursorOutline.Thickness = 1
                    CursorOutline.Filled = false
                    CursorOutline.Color = Color3.new(0, 0, 0)
                    CursorOutline.Visible = Library.ShowCustomCursor
                    
                    local OldMouseIconState = InputService.MouseIconEnabled
                    pcall(function() RunService:UnbindFromRenderStep("LinoriaCursor") end)
                    RunService:BindToRenderStep("LinoriaCursor", Enum.RenderPriority.Camera.Value - 1, function()
                        InputService.MouseIconEnabled = not Library.ShowCustomCursor
                        local mPos = InputService:GetMouseLocation()
                        local X, Y = mPos.X, mPos.Y
                        Cursor.Color = Library.AccentColor
                        Cursor.PointA = Vector2.new(X, Y)
                        Cursor.PointB = Vector2.new(X + 16, Y + 6)
                        Cursor.PointC = Vector2.new(X + 6, Y + 16)
                        Cursor.Visible = Library.ShowCustomCursor
                        CursorOutline.PointA = Cursor.PointA
                        CursorOutline.PointB = Cursor.PointB
                        CursorOutline.PointC = Cursor.PointC
                        CursorOutline.Visible = Library.ShowCustomCursor

                        if not Toggled or (not ScreenGui or not ScreenGui.Parent) then
                            InputService.MouseIconEnabled = OldMouseIconState
                            if Cursor then Cursor:Destroy() end
                            if CursorOutline then CursorOutline:Destroy() end
                            RunService:UnbindFromRenderStep("LinoriaCursor")
                        end
                    end)
                end))
            end
        else
            if Lighting:FindFirstChild("LinoriaBlur") then
                Lighting.LinoriaBlur:Destroy()
            end
        end

        for _, Option in Options do
            task.spawn(function()
                if Option.Type == 'Dropdown' then
                    Option:CloseDropdown()

                elseif Option.Type == 'KeyPicker' then
                    Option:SetModePickerVisibility(false)

                elseif Option.Type == 'ColorPicker' then
                    Option.ContextMenu:Hide()
                    Option:Hide()
                end
            end)
        end

        for _, Desc in next, Outer:GetDescendants() do
            local Properties = {}

            if Desc:IsA('ImageLabel') then
                table.insert(Properties, 'ImageTransparency')
                table.insert(Properties, 'BackgroundTransparency')

            elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') then
                table.insert(Properties, 'TextTransparency')

            elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
                table.insert(Properties, 'BackgroundTransparency')
                
            elseif Desc:IsA('UIStroke') then
                table.insert(Properties, 'Transparency')
            end

            local Cache = TransparencyCache[Desc]

            if (not Cache) then
                Cache = {}
                TransparencyCache[Desc] = Cache
            end

            for _, Prop in next, Properties do
                if not Cache[Prop] then
                    Cache[Prop] = Desc[Prop]
                end

                if Cache[Prop] == 1 then
                    continue
                end

                TweenService:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { [Prop] = Toggled and Cache[Prop] or 1 }):Play()
            end
        end

        task.wait(FadeTime)
        Outer.Visible = Toggled
        Fading = false
    end

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
        if Library.Unloaded then
            return
        end
        
        if typeof(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            end

        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            task.spawn(Library.Toggle)
        end
    end))

    local DynamicIsland = {}
    do
        DynamicIsland.Outer = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0.5, 0);
            BackgroundColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0.5, 0, 0, 5);
            Size = UDim2.new(0, 120, 0, 30);
            ZIndex = 400;
            Parent = ScreenGui;
        })

        local UICorner3 = Library:Create('UICorner', {
            CornerRadius = UDim.new(1, 0);
            Parent = DynamicIsland.Outer;
        })

        DynamicIsland.Inner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.AccentColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 401;
            Parent = DynamicIsland.Outer;
        })

        local UICorner4 = Library:Create('UICorner', {
            CornerRadius = UDim.new(1, 0);
            Parent = DynamicIsland.Inner;
        })

        Library:AddToRegistry(DynamicIsland.Inner, {
            BorderColor3 = 'AccentColor';
        })

        DynamicIsland.Label = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            Text = "Janse UI";
            ZIndex = 402;
            Parent = DynamicIsland.Inner;
        })

        function DynamicIsland:Show()
            DynamicIsland.Outer.Visible = true
            TweenService:Create(DynamicIsland.Outer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0, 5)
            }):Play()
        end

        function DynamicIsland:Hide()
            TweenService:Create(DynamicIsland.Outer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0, -40)
            }):Play()
            task.delay(0.3, function()
                DynamicIsland.Outer.Visible = false
            end)
        end

        function DynamicIsland:SetText(Text)
            DynamicIsland.Label.Text = Text
            local X = Library:GetTextBounds(Text, Library.Font, 14)
            DynamicIsland.Outer.Size = UDim2.new(0, math.max(120, X + 40), 0, 30)
        end

        function DynamicIsland:Pulse()
            local OriginalSize = DynamicIsland.Outer.Size
            TweenService:Create(DynamicIsland.Outer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, OriginalSize.X.Offset * 1.1, 0, OriginalSize.Y.Offset * 1.1)
            }):Play()
            task.wait(0.2)
            TweenService:Create(DynamicIsland.Outer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = OriginalSize
            }):Play()
        end

        DynamicIsland:Show()
        task.delay(2, function()
            DynamicIsland:Hide()
        end)
    end
    Library.DynamicIsland = DynamicIsland

    if Library.IsMobile then
        local ControlPanelOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0.008, 0, 0.018, 0);
            Size = UDim2.new(0, 85, 0, 65);
            ZIndex = 400;
            Visible = true;
            Parent = ScreenGui;
        })
        
        local ControlPanelUICorner = Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 12);
            Parent = ControlPanelOuter;
        })
        
        local ControlPanelInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.AccentColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 401;
            Parent = ControlPanelOuter;
        })
        
        Library:AddToRegistry(ControlPanelInner, {
            BorderColor3 = 'AccentColor';
        })
        
        local ControlPanelInnerFrame = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 402;
            Parent = ControlPanelInner;
        })
        
        local ControlPanelGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
            Rotation = -90;
            Parent = ControlPanelInnerFrame;
        })
        
        Library:AddToRegistry(ControlPanelGradient, {
            Color = function()
                return ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                    ColorSequenceKeypoint.new(1, Library.MainColor),
                })
            end
        })
        
        local ToggleUIButton = Library:Create('TextButton', {
            Position = UDim2.new(0, 5, 0, 5);
            Size = UDim2.new(1, -10, 0, 20);
            BackgroundTransparency = 1;
            Font = Library.Font;
            Text = "最小化";
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextStrokeTransparency = 0;
            ZIndex = 403;
            Parent = ControlPanelInnerFrame;
        })
        
        local LockUIButton = Library:Create('TextButton', {
            Position = UDim2.new(0, 5, 0, 30);
            Size = UDim2.new(1, -10, 0, 20);
            BackgroundTransparency = 1;
            Font = Library.Font;
            Text = "锁定界面";
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextStrokeTransparency = 0;
            ZIndex = 403;
            Parent = ControlPanelInnerFrame;
        })

        Library:MakeDraggableUsingParent(ControlPanelInnerFrame, ControlPanelOuter)

        ToggleUIButton.MouseButton1Down:Connect(function()
            Library:Toggle()
            Library.DynamicIsland:SetText(if Library.Toggled then "UI 已打开" else "UI 已关闭")
            Library.DynamicIsland:Show()
            Library.DynamicIsland:Pulse()
            task.delay(2, function()
                Library.DynamicIsland:Hide()
            end)
        end)
        
        LockUIButton.MouseButton1Down:Connect(function()
            Library.CantDragForced = not Library.CantDragForced
            LockUIButton.Text = Library.CantDragForced and "解锁界面" or "锁定界面"
            
            if Library.CantDragForced then
                Library.DynamicIsland:SetText("界面已锁定")
                Library:Notify("界面已锁定", 2)
            else
                Library.DynamicIsland:SetText("界面已解锁")
                Library:Notify("界面已解锁", 2)
            end
            Library.DynamicIsland:Show()
            Library.DynamicIsland:Pulse()
            task.delay(2, function()
                Library.DynamicIsland:Hide()
            end)
        end)
    end

    if WindowInfo.AutoShow then task.spawn(Library.Toggle) end

    Window.Holder = Outer
    Library.Window = Window

    return Window
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(false, true), GetPlayers(true, true)
    local StringPlayerList, StringExcludedPlayerList = GetPlayers(false, false), GetPlayers(true, false)

    for _, Value in next, Options do
        if Value.SetValues and Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
            Value:SetValues(
                if Value.ReturnInstanceInstead then
                    (if Value.ExcludeLocalPlayer then ExcludedPlayerList else PlayerList)
                else
                    (if Value.ExcludeLocalPlayer then StringExcludedPlayerList else StringPlayerList)
            )
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end
    
    local TeamList = GetTeams(false)
    local StringTeamList = GetTeams(true)

    for _, Value in next, Options do
        if Value.SetValues and Value.Type == 'Dropdown' and Value.SpecialType == 'Team' then
            Value:SetValues(if Value.ReturnInstanceInstead then TeamList else StringTeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

local RainbowStep = 0
local Hue = 0

Library:GiveSignal(RunService.RenderStepped:Connect(function(Delta)
    if Library.Unloaded then
        return
    end

    RainbowStep = RainbowStep + Delta
    if RainbowStep >= (1 / 60) then
        RainbowStep = 0

        Hue = Hue + (1 / 400)

        if Hue > 1 then
            Hue = 0
        end

        Library.CurrentRainbowHue = Hue
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1)
    end
end))

function Library:SetTheme(ThemeName)
    if typeof(ThemeName) == "string" then
        local Theme = Library.Themes[ThemeName]
        if Theme then
            for Property, Value in next, Theme do
                Library[Property] = Value
            end
            Library:UpdateColorsUsingRegistry()
            Library:AttemptSave()
        end
    end
end

function Library:AddTheme(ThemeName, ThemeData)
    Library.Themes[ThemeName] = ThemeData
end

Library.Themes = {
    Default = {
        FontColor = Color3.fromRGB(240, 240, 240);
        MainColor = Color3.fromRGB(28, 28, 28);
        BackgroundColor = Color3.fromRGB(20, 20, 20);
        SecondaryColor = Color3.fromRGB(38, 38, 38);
        AccentColor = Color3.fromRGB(0, 122, 255);
        OutlineColor = Color3.fromRGB(60, 60, 60);
        RiskColor = Color3.fromRGB(255, 59, 48);
    },
    Dark = {
        FontColor = Color3.fromRGB(240, 240, 240);
        MainColor = Color3.fromRGB(18, 18, 18);
        BackgroundColor = Color3.fromRGB(10, 10, 10);
        SecondaryColor = Color3.fromRGB(28, 28, 28);
        AccentColor = Color3.fromRGB(0, 150, 235);
        OutlineColor = Color3.fromRGB(50, 50, 50);
        RiskColor = Color3.fromRGB(255, 40, 40);
    },
    Light = {
        FontColor = Color3.fromRGB(30, 30, 30);
        MainColor = Color3.fromRGB(245, 245, 245);
        BackgroundColor = Color3.fromRGB(230, 230, 230);
        SecondaryColor = Color3.fromRGB(220, 220, 220);
        AccentColor = Color3.fromRGB(0, 120, 215);
        OutlineColor = Color3.fromRGB(180, 180, 180);
        RiskColor = Color3.fromRGB(220, 30, 30);
    },
    Purple = {
        FontColor = Color3.fromRGB(255, 255, 255);
        MainColor = Color3.fromRGB(40, 20, 50);
        BackgroundColor = Color3.fromRGB(30, 15, 40);
        SecondaryColor = Color3.fromRGB(50, 25, 60);
        AccentColor = Color3.fromRGB(170, 0, 255);
        OutlineColor = Color3.fromRGB(70, 35, 80);
        RiskColor = Color3.fromRGB(255, 50, 50);
    },
    Green = {
        FontColor = Color3.fromRGB(255, 255, 255);
        MainColor = Color3.fromRGB(20, 40, 20);
        BackgroundColor = Color3.fromRGB(15, 30, 15);
        SecondaryColor = Color3.fromRGB(25, 50, 25);
        AccentColor = Color3.fromRGB(0, 255, 100);
        OutlineColor = Color3.fromRGB(35, 60, 35);
        RiskColor = Color3.fromRGB(255, 50, 50);
    }
}

local SaveManager = {}
do
    SaveManager.Folder = "LinoriaLibrary"
    SaveManager.Ignore = {}
    SaveManager.Parser = {
        Toggle = function(idx, val) return tostring(val) end,
        ColorPicker = function(idx, val)
            if typeof(val) == "Color3" and typeof(val.ToHex) == "function" then
                return val:ToHex()
            elseif typeof(val) == "table" and typeof(val.Value) == "Color3" and typeof(val.Value.ToHex) == "function" then
                return val.Value:ToHex()
            else
                return tostring(val)
            end
        end,
        KeyPicker = function(idx, val) return val end,
        Slider = function(idx, val) return tostring(val) end,
        Dropdown = function(idx, val)
            if typeof(val) == "table" then
                local result = ""
                for value, enabled in next, val do
                    if enabled then
                        result = result .. tostring(value) .. ", "
                    end
                end
                return result:sub(1, -3)
            else
                return tostring(val)
            end
        end,
        Input = function(idx, val) return tostring(val) end
    }

    SaveManager.Defaults = {}

    function SaveManager:SetFolder(Folder)
        self.Folder = Folder
    end

    function SaveManager:SetIgnore(idx)
        self.Ignore[idx] = true
    end

    function SaveManager:SetParser(Type, Parser)
        self.Parser[Type] = Parser
    end

    function SaveManager:Save(idx)
        if not isfolder or not writefile then return end

        local Data = {}
        local AllowSave = true

        for idx, Option in next, Options do
            if self.Ignore[idx] then continue end

            local Parser = self.Parser[Option.Type]
            if Parser then
                Data[idx] = Parser(idx, Option.Value)
            end
        end

        for idx, Toggle in next, Toggles do
            if self.Ignore[idx] then continue end
            Data[idx] = tostring(Toggle.Value)
        end

        local Success, Encoded = pcall(function()
            return game:GetService("HttpService"):JSONEncode(Data)
        end)

        if Success and AllowSave then
            if not isfolder(self.Folder) then
                makefolder(self.Folder)
            end

            writefile(self.Folder .. "/settings.txt", Encoded)
        end
    end

    function SaveManager:Load(idx)
        if not isfolder or not isfile then return end

        local File = self.Folder .. "/settings.txt"
        if not isfile(File) then return false end

        local Success, Decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(File))
        end)

        if not Success then return false end

        for idx, Value in next, Decoded do
            local Option = Options[idx]
            local Toggle = Toggles[idx]

            if Option then
                if Option.Type == "Toggle" then
                    Option:SetValue(Value == "true")

                elseif Option.Type == "ColorPicker" then
                    Option:SetValueRGB(Color3.fromHex(Value))

                elseif Option.Type == "KeyPicker" then
                    Option:SetValue({Value, Option.Mode, Option.Modifiers})

                elseif Option.Type == "Slider" then
                    Option:SetValue(tonumber(Value))

                elseif Option.Type == "Dropdown" then
                    if Option.Multi then
                        local Table = {}
                        for value in Value:gmatch("([^,]+)") do
                            Table[value] = true
                        end
                        Option:SetValue(Table)
                    else
                        Option:SetValue(Value)
                    end

                elseif Option.Type == "Input" then
                    Option:SetValue(Value)
                end
            elseif Toggle then
                Toggle:SetValue(Value == "true")
            end
        end

        return true
    end

    Library.SaveManager = SaveManager
end

local ThemeManager = {}
do
    ThemeManager.Folder = "LinoriaLibrary"
    ThemeManager.Themes = {}
    ThemeManager.Loaded = {}

    function ThemeManager:SetFolder(Folder)
        self.Folder = Folder
    end

    function ThemeManager:ApplyTheme(Theme)
        if Library.Themes[Theme] then
            Library:SetTheme(Theme)
            self.Loaded.Theme = Theme
        end
    end

    function ThemeManager:Save()
        if not isfolder or not writefile then return end

        local Data = {
            Theme = self.Loaded.Theme or "Default",
            AccentColor = Library.AccentColor:ToHex()
        }

        local Success, Encoded = pcall(function()
            return game:GetService("HttpService"):JSONEncode(Data)
        end)

        if Success then
            if not isfolder(self.Folder) then
                makefolder(self.Folder)
            end

            writefile(self.Folder .. "/theme.txt", Encoded)
        end
    end

    function ThemeManager:Load()
        if not isfolder or not isfile then return end

        local File = self.Folder .. "/theme.txt"
        if not isfile(File) then return false end

        local Success, Decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(File))
        end)

        if not Success then return false end

        if Decoded.Theme then
            self:ApplyTheme(Decoded.Theme)
        end

        if Decoded.AccentColor then
            Library.AccentColor = Color3.fromHex(Decoded.AccentColor)
            Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
            Library:UpdateColorsUsingRegistry()
        end

        return true
    end

    function ThemeManager:CreateThemePicker(Parent)
        local ThemePicker = Parent:AddDropdown("ThemePicker", {
            Text = "主题",
            Values = {"Default", "Dark", "Light", "Purple", "Green"},
            Default = "Default",
            Callback = function(Value)
                self:ApplyTheme(Value)
                self:Save()
            end
        })

        local ColorPicker = Parent:AddColorPicker("AccentColor", {
            Text = "强调色",
            Default = Library.AccentColor,
            Callback = function(Color)
                Library.AccentColor = Color
                Library.AccentColorDark = Library:GetDarkerColor(Color)
                Library:UpdateColorsUsingRegistry()
                self:Save()
            end
        })

        return ThemePicker, ColorPicker
    end

    Library.ThemeManager = ThemeManager
end

local AutoUpdate = {}
do
    AutoUpdate.Enabled = false
    AutoUpdate.Interval = 60
    AutoUpdate.LastCheck = 0
    AutoUpdate.Callbacks = {}

    function AutoUpdate:Enable()
        self.Enabled = true
        self:Start()
    end

    function AutoUpdate:Disable()
        self.Enabled = false
    end

    function AutoUpdate:SetInterval(Seconds)
        self.Interval = Seconds
    end

    function AutoUpdate:AddCallback(Callback)
        table.insert(self.Callbacks, Callback)
    end

    function AutoUpdate:Start()
        if not self.Enabled then return end

        task.spawn(function()
            while self.Enabled and not Library.Unloaded do
                local CurrentTime = tick()
                if CurrentTime - self.LastCheck >= self.Interval then
                    self.LastCheck = CurrentTime
                    
                    for _, Callback in next, self.Callbacks do
                        Library:SafeCallback(Callback)
                    end

                    Library:AttemptSave()
                end
                task.wait(1)
            end
        end)
    end

    Library.AutoUpdate = AutoUpdate
end

local Rainbow = {}
do
    Rainbow.Enabled = false
    Rainbow.Speed = 1
    Rainbow.Accent = true
    Rainbow.Hue = 0

    function Rainbow:Enable()
        self.Enabled = true
        self:Start()
    end

    function Rainbow:Disable()
        self.Enabled = false
    end

    function Rainbow:SetSpeed(Speed)
        self.Speed = Speed / 100
    end

    function Rainbow:ToggleAccent(State)
        self.Accent = State
    end

    function Rainbow:Start()
        if not self.Enabled then return end

        task.spawn(function()
            while self.Enabled and not Library.Unloaded do
                self.Hue = (self.Hue + (0.0001 * self.Speed)) % 1
                
                if self.Accent then
                    Library.AccentColor = Color3.fromHSV(self.Hue, 0.8, 1)
                    Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
                    Library:UpdateColorsUsingRegistry()
                end

                task.wait()
            end
        end)
    end

    Library.Rainbow = Rainbow
end

function Library:CreateEffect(Instance, EffectType, Properties)
    if not Library.AnimationsEnabled then return end

    local Effect = Instance:Clone()
    Effect.Parent = Instance.Parent
    Effect.ZIndex = Instance.ZIndex + 10
    
    if EffectType == "Ripple" then
        Effect.BackgroundTransparency = 0.8
        Effect.Size = UDim2.new(0, 0, 0, 0)
        Effect.Position = UDim2.new(0.5, 0, 0.5, 0)
        Effect.AnchorPoint = Vector2.new(0.5, 0.5)
        
        TweenService:Create(Effect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.delay(0.5, function()
            Effect:Destroy()
        end)
        
    elseif EffectType == "Pulse" then
        local OriginalSize = Effect.Size
        Effect.BackgroundTransparency = 0.5
        
        TweenService:Create(Effect, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = OriginalSize * 1.1,
            BackgroundTransparency = 1
        }):Play()
        
        task.delay(0.3, function()
            Effect:Destroy()
        end)
    end
    
    return Effect
end

function Library:CreateAdvancedNotification(Title, Description, Options)
    local DefaultOptions = {
        Time = 5,
        Sound = true,
        SoundId = 6672131910,
        Icon = nil,
        Color = Library.AccentColor,
        OnClick = nil,
        OnClose = nil
    }
    
    Options = Library:Validate(Options or {}, DefaultOptions)
    
    local Notification = Library:Notify({
        Title = Title,
        Description = Description,
        Time = Options.Time,
        SoundId = Options.Sound and Options.SoundId or nil,
        Icon = Options.Icon,
        Persist = Options.Time == 0
    })
    
    if Options.Color then
        task.spawn(function()
            task.wait(0.1)
            for _, Child in next, Notification.Tooltip:GetDescendants() do
                if Child:IsA("Frame") and Child.Name == "SideColor" then
                    Child.BackgroundColor3 = Options.Color
                end
            end
        end)
    end
    
    if Options.OnClick and typeof(Options.OnClick) == "function" then
        Notification.Tooltip.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Options.OnClick(Notification)
            end
        end)
    end
    
    if Options.OnClose and typeof(Options.OnClose) == "function" then
        local Connection
        Connection = Notification.Tooltip.AncestryChanged:Connect(function()
            if not Notification.Tooltip.Parent then
                Options.OnClose()
                if Connection then
                    Connection:Disconnect()
                end
            end
        end)
    end
    
    return Notification
end

function Library:CreateConfirmation(Title, Message, ConfirmText, CancelText, Callback)
    local Confirmation = {
        Result = nil,
        Closed = false
    }
    
    local Modal = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BackgroundTransparency = 0.5;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 300;
        Parent = ScreenGui;
    })
    
    local Container = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(0, 300, 0, 150);
        ZIndex = 301;
        Parent = Modal;
    })
    
    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 12);
        Parent = Container;
    })
    
    local UIStroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        Thickness = 1;
        Parent = Container;
    })
    
    local TitleLabel = Library:CreateLabel({
        Position = UDim2.new(0, 10, 0, 10);
        Size = UDim2.new(1, -20, 0, 30);
        Text = Title;
        TextSize = 18;
        TextXAlignment = Enum.TextXAlignment.Center;
        ZIndex = 302;
        Parent = Container;
    })
    
    local MessageLabel = Library:CreateLabel({
        Position = UDim2.new(0, 20, 0, 50);
        Size = UDim2.new(1, -40, 0, 50);
        Text = Message;
        TextSize = 14;
        TextWrapped = true;
        TextXAlignment = Enum.TextXAlignment.Center;
        ZIndex = 302;
        Parent = Container;
    })
    
    local ButtonContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 10, 1, -50);
        Size = UDim2.new(1, -20, 0, 40);
        ZIndex = 302;
        Parent = Container;
    })
    
    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDim.new(0, 10);
        Parent = ButtonContainer;
    })
    
    local ConfirmButton = Library:Create('TextButton', {
        BackgroundColor3 = Library.AccentColor;
        BorderColor3 = Library.AccentColorDark;
        Size = UDim2.new(0, 100, 0, 30);
        Text = ConfirmText or "确认";
        TextColor3 = Color3.new(1, 1, 1);
        TextSize = 14;
        ZIndex = 303;
        Parent = ButtonContainer;
    })
    
    local ConfirmUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = ConfirmButton;
    })
    
    local CancelButton = Library:Create('TextButton', {
        BackgroundColor3 = Library.SecondaryColor;
        BorderColor3 = Library.OutlineColor;
        Size = UDim2.new(0, 100, 0, 30);
        Text = CancelText or "取消";
        TextColor3 = Library.FontColor;
        TextSize = 14;
        ZIndex = 303;
        Parent = ButtonContainer;
    })
    
    local CancelUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = CancelButton;
    })
    
    local function Close(Result)
        if Confirmation.Closed then return end
        Confirmation.Result = Result
        Confirmation.Closed = true
        
        TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        TweenService:Create(Modal, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
        
        task.delay(0.3, function()
            Modal:Destroy()
            if Callback then
                Callback(Result)
            end
        end)
    end
    
    ConfirmButton.MouseButton1Click:Connect(function()
        Close(true)
    end)
    
    CancelButton.MouseButton1Click:Connect(function()
        Close(false)
    end)
    
    Modal.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local AbsPos, AbsSize = Container.AbsolutePosition, Container.AbsoluteSize
            local MousePos = Input.Position
            
            if MousePos.X < AbsPos.X or MousePos.X > AbsPos.X + AbsSize.X or
               MousePos.Y < AbsPos.Y or MousePos.Y > AbsPos.Y + AbsSize.Y then
                Close(false)
            end
        end
    end)
    
    Container.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 150)
    }):Play()
    
    return Confirmation
end

function Library:CreateTooltip(Text, Position, Options)
    local DefaultOptions = {
        Duration = 3,
        Color = Library.AccentColor,
        Offset = Vector2.new(15, 15)
    }
    
    Options = Library:Validate(Options or {}, DefaultOptions)
    
    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Options.Color;
        Position = Position or UDim2.fromOffset(Mouse.X + Options.Offset.X, Mouse.Y + Options.Offset.Y);
        ZIndex = 400;
        Parent = ScreenGui;
    })
    
    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = Tooltip;
    })
    
    local UIStroke = Library:Create('UIStroke', {
        Color = Options.Color;
        Thickness = 1;
        Parent = Tooltip;
    })
    
    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(8, 4);
        TextSize = 14;
        Text = Text;
        TextColor3 = Library.FontColor;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 401;
        Parent = Tooltip;
    })
    
    local X, Y = Library:GetTextBounds(Text, Library.Font, 14)
    Tooltip.Size = UDim2.fromOffset(X + 16, Y + 8)
    
    if Options.Duration > 0 then
        task.delay(Options.Duration, function()
            TweenService:Create(Tooltip, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1,
                BorderColor3 = Color3.new(0, 0, 0)
            }):Play()
            
            TweenService:Create(Label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 1
            }):Play()
            
            task.delay(0.3, function()
                Tooltip:Destroy()
            end)
        end)
    end
    
    return {
        Tooltip = Tooltip,
        Destroy = function()
            Tooltip:Destroy()
        end,
        UpdateText = function(NewText)
            Label.Text = NewText
            local X, Y = Library:GetTextBounds(NewText, Library.Font, 14)
            Tooltip.Size = UDim2.fromOffset(X + 16, Y + 8)
        end,
        UpdatePosition = function(NewPosition)
            Tooltip.Position = NewPosition
        end
    }
end

function Library:CreateProgressBar(Text, Total, Options)
    local DefaultOptions = {
        Color = Library.AccentColor,
        Height = 20,
        ShowPercentage = true,
        ShowText = true,
        Animated = true
    }
    
    Options = Library:Validate(Options or {}, DefaultOptions)
    
    local ProgressBar = {
        Value = 0,
        Total = Total or 100,
        Visible = true
    }
    
    local Container = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(1, -4, 0, Options.Height);
        ZIndex = 5;
        Parent = Options.Parent or ScreenGui;
    })
    
    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.SecondaryColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = Container;
    })
    
    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = Inner;
    })
    
    local Fill = Library:Create('Frame', {
        BackgroundColor3 = Options.Color;
        BorderColor3 = Library:GetDarkerColor(Options.Color);
        Size = UDim2.new(0, 0, 1, 0);
        ZIndex = 7;
        Parent = Inner;
    })
    
    local FillUICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 6);
        Parent = Fill;
    })
    
    local Label
    if Options.ShowText then
        Label = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 14;
            Text = Text or "";
            ZIndex = 8;
            Parent = Inner;
            RichText = true;
        })
    end
    
    function ProgressBar:SetValue(Value)
        ProgressBar.Value = math.clamp(Value, 0, ProgressBar.Total)
        local Percentage = ProgressBar.Value / ProgressBar.Total
        
        if Options.Animated then
            TweenService:Create(Fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(Percentage, 0, 1, 0)
            }):Play()
        else
            Fill.Size = UDim2.new(Percentage, 0, 1, 0)
        end
        
        if Label and Options.ShowPercentage then
            Label.Text = string.format("%s (%d%%)", Text or "", math.floor(Percentage * 100))
        end
    end
    
    function ProgressBar:SetTotal(Total)
        ProgressBar.Total = Total
        ProgressBar:SetValue(ProgressBar.Value)
    end
    
    function ProgressBar:SetVisible(Visible)
        ProgressBar.Visible = Visible
        Container.Visible = Visible
    end
    
    function ProgressBar:Destroy()
        Container:Destroy()
    end
    
    ProgressBar:SetValue(0)
    
    return ProgressBar
end

function Library:CreateLoadingSpinner(Options)
    local DefaultOptions = {
        Size = 30,
        Color = Library.AccentColor,
        Speed = 1,
        Thickness = 3
    }
    
    Options = Library:Validate(Options or {}, DefaultOptions)
    
    local Spinner = {
        Spinning = true,
        Speed = Options.Speed
    }
    
    local Container = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, Options.Size, 0, Options.Size);
        ZIndex = 5;
        Parent = Options.Parent or ScreenGui;
    })
    
    local Circle = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = Container;
    })
    
    local UIStroke = Library:Create('UIStroke', {
        Color = Options.Color;
        Thickness = Options.Thickness;
        Transparency = 0.5;
        Parent = Circle;
    })
    
    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(1, 0);
        Parent = Circle;
    })
    
    local ProgressCircle = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 7;
        Parent = Container;
    })
    
    local ProgressStroke = Library:Create('UIStroke', {
        Color = Options.Color;
        Thickness = Options.Thickness;
        Parent = ProgressCircle;
    })
    
    local ProgressCorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(1, 0);
        Parent = ProgressCircle;
    })
    
    local Rotation = 0
    
    local function Update()
        if not Spinner.Spinning then return end
        
        Rotation = (Rotation + (2 * Spinner.Speed)) % 360
        ProgressCircle.Rotation = Rotation
        
        RunService.RenderStepped:Wait()
        Update()
    end
    
    task.spawn(Update)
    
    function Spinner:Start()
        Spinner.Spinning = true
        Update()
    end
    
    function Spinner:Stop()
        Spinner.Spinning = false
    end
    
    function Spinner:SetSpeed(Speed)
        Spinner.Speed = Speed
    end
    
    function Spinner:SetColor(Color)
        ProgressStroke.Color = Color
        UIStroke.Color = Color
    end
    
    function Spinner:Destroy()
        Spinner.Spinning = false
        Container:Destroy()
    end
    
    return Spinner
end

function Library:CreateContextMenu(Items, Options)
    local DefaultOptions = {
        Position = UDim2.fromOffset(Mouse.X, Mouse.Y),
        Width = 150,
        CloseOnClick = true
    }
    
    Options = Library:Validate(Options or {}, DefaultOptions)
    
    local ContextMenu = {
        IsOpen = false
    }
    
    local Container = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = Options.Position;
        Size = UDim2.new(0, Options.Width, 0, 0);
        ZIndex = 500;
        Visible = false;
        Parent = ScreenGui;
    })
    
    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 8);
        Parent = Container;
    })
    
    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 501;
        Parent = Container;
    })
    
    local UIStroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        Thickness = 1;
        Parent = Inner;
    })
    
    local ListLayout = Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Inner;
    })
    
    local Padding = Library:Create('UIPadding', {
        PaddingTop = UDim.new(0, 4);
        PaddingBottom = UDim.new(0, 4);
        Parent = Inner;
    })
    
    local ItemsByButton = {}
    
    for _, Item in next, Items do
        if Item.Separator then
            local Separator = Library:Create('Frame', {
                BackgroundColor3 = Library.OutlineColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, -8, 0, 1);
                ZIndex = 502;
                Parent = Inner;
            })
            
            Separator.Position = UDim2.new(0, 4, 0, 0)
        else
            local Button = Library:Create('TextButton', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 25);
                Text = "";
                ZIndex = 502;
                Parent = Inner;
            })
            
            local Label = Library:CreateLabel({
                Position = UDim2.new(0, 8, 0, 0);
                Size = UDim2.new(1, -16, 1, 0);
                Text = Item.Text or "";
                TextSize = 14;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 503;
                Parent = Button;
            })
            
            if Item.Icon then
                local Icon = Library:GetCustomIcon(Item.Icon)
                if Icon then
                    local IconLabel = Library:Create('ImageLabel', {
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0, 4, 0, 4);
                        Size = UDim2.new(0, 16, 0, 16);
                        Image = Icon.Url;
                        ImageRectOffset = Icon.ImageRectOffset;
                        ImageRectSize = Icon.ImageRectSize;
                        ImageColor3 = Library.AccentColor;
                        ZIndex = 503;
                        Parent = Button;
                    })
                    
                    Label.Position = UDim2.new(0, 24, 0, 0)
                    Label.Size = UDim2.new(1, -28, 1, 0)
                end
            end
            
            if Item.Shortcut then
                local ShortcutLabel = Library:CreateLabel({
                    AnchorPoint = Vector2.new(1, 0);
                    Position = UDim2.new(1, -4, 0, 0);
                    Size = UDim2.new(0, 50, 1, 0);
                    Text = Item.Shortcut;
                    TextSize = 12;
                    TextColor3 = Library.DisabledTextColor;
                    TextXAlignment = Enum.TextXAlignment.Right;
                    ZIndex = 503;
                    Parent = Button;
                })
            end
            
            Library:OnHighlight(Button, Label,
                { TextColor3 = 'AccentColor' },
                { TextColor3 = 'FontColor' }
            )
            
            if Item.Disabled then
                Label.TextColor3 = Library.DisabledTextColor
            else
                Button.MouseButton1Click:Connect(function()
                    if Item.Callback then
                        Item.Callback()
                    end
                    
                    if Options.CloseOnClick then
                        ContextMenu:Close()
                    end
                end)
            end
            
            ItemsByButton[Button] = Item
        end
    end
    
    ListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        Container.Size = UDim2.new(0, Options.Width, 0, ListLayout.AbsoluteContentSize.Y + 8)
    end)
    
    function ContextMenu:Open(Position)
        if ContextMenu.IsOpen then return end
        
        ContextMenu.IsOpen = true
        Container.Visible = true
        Container.Position = Position or Options.Position
        
        for Button, Item in next, ItemsByButton do
            if Item.Disabled then
                Button.TextButton.TextColor3 = Library.DisabledTextColor
            end
        end
    end
    
    function ContextMenu:Close()
        if not ContextMenu.IsOpen then return end
        
        ContextMenu.IsOpen = false
        Container.Visible = false
    end
    
    function ContextMenu:Toggle(Position)
        if ContextMenu.IsOpen then
            ContextMenu:Close()
        else
            ContextMenu:Open(Position)
        end
    end
    
    function ContextMenu:Destroy()
        Container:Destroy()
    end
    
    Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
        if ContextMenu.IsOpen and Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local AbsPos, AbsSize = Container.AbsolutePosition, Container.AbsoluteSize
            local MousePos = Input.Position
            
            if MousePos.X < AbsPos.X or MousePos.X > AbsPos.X + AbsSize.X or
               MousePos.Y < AbsPos.Y or MousePos.Y > AbsPos.Y + AbsSize.Y then
                ContextMenu:Close()
            end
        end
    end))
    
    return ContextMenu
end

function Library:CreateHotkey(Key, Callback, Options)
    local DefaultOptions = {
        Enabled = true,
        Description = "",
        Hold = false
    }
    
    Options = Library:Validate(Options or {}, DefaultOptions)
    
    local Hotkey = {
        Key = Key,
        Callback = Callback,
        Enabled = Options.Enabled,
        Description = Options.Description,
        Hold = Options.Hold,
        Pressed = false
    }
    
    local function OnInput(Input, GameProcessed)
        if GameProcessed or not Hotkey.Enabled then return end
        
        if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Hotkey.Key then
            if Hotkey.Hold then
                if Input.UserInputState == Enum.UserInputState.Begin then
                    Hotkey.Pressed = true
                    Library:SafeCallback(Hotkey.Callback, true)
                elseif Input.UserInputState == Enum.UserInputState.End then
                    Hotkey.Pressed = false
                    Library:SafeCallback(Hotkey.Callback, false)
                end
            else
                if Input.UserInputState == Enum.UserInputState.Begin then
                    Library:SafeCallback(Hotkey.Callback)
                end
            end
        end
    end
    
    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, GameProcessed)
        OnInput(Input, GameProcessed)
    end))
    
    Library:GiveSignal(InputService.InputEnded:Connect(function(Input, GameProcessed)
        OnInput(Input, GameProcessed)
    end))
    
    function Hotkey:Enable()
        Hotkey.Enabled = true
    end
    
    function Hotkey:Disable()
        Hotkey.Enabled = false
    end
    
    function Hotkey:SetKey(NewKey)
        Hotkey.Key = NewKey
    end
    
    function Hotkey:SetCallback(NewCallback)
        Hotkey.Callback = NewCallback
    end
    
    return Hotkey
end

function Library:CreateValueDisplay(Values, Options)
    local DefaultOptions = {
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 200, 0, 0),
        Title = "数值显示",
        UpdateInterval = 0.1,
        AutoSize = true
    }
    
    Options = Library:Validate(Options or {}, DefaultOptions)
    
    local Display = {
        Values = Values or {},
        Visible = true,
        Updating = true
    }
    
    local Container = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Position = Options.Position;
        Size = Options.Size;
        ZIndex = 100;
        Parent = ScreenGui;
    })
    
    local UICorner = Library:Create('UICorner', {
        CornerRadius = UDim.new(0, 8);
        Parent = Container;
    })
    
    local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = Container;
    })
    
    local UIStroke = Library:Create('UIStroke', {
        Color = Library.AccentColor;
        Thickness = 1;
        Parent = Inner;
    })
    
    local TitleLabel = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 2);
        Size = UDim2.new(1, -10, 0, 20);
        Text = Options.Title;
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 102;
        Parent = Inner;
    })
    
    local ValueContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 24);
        Size = UDim2.new(1, 0, 1, -24);
        ZIndex = 102;
        Parent = Inner;
    })
    
    local ListLayout = Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = ValueContainer;
    })
    
    local Padding = Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5);
        PaddingRight = UDim.new(0, 5);
        Parent = ValueContainer;
    })
    
    local ValueLabels = {}
    
    local function UpdateValues()
        for Name, Value in next, Display.Values do
            if not ValueLabels[Name] then
                local Label = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    Text = string.format("%s: %s", Name, tostring(Value));
                    TextSize = 12;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 103;
                    Parent = ValueContainer;
                })
                
                ValueLabels[Name] = Label
            else
                ValueLabels[Name].Text = string.format("%s: %s", Name, tostring(Value))
            end
        end
        
        if Options.AutoSize then
            Container.Size = UDim2.new(0, Options.Size.X.Offset, 0, 24 + (#Display.Values * 18) + 4)
        end
    end
    
    task.spawn(function()
        while Display.Updating and not Library.Unloaded do
            UpdateValues()
            task.wait(Options.UpdateInterval)
        end
    end)
    
    function Display:SetValue(Name, Value)
        Display.Values[Name] = Value
    end
    
    function Display:RemoveValue(Name)
        Display.Values[Name] = nil
        if ValueLabels[Name] then
            ValueLabels[Name]:Destroy()
            ValueLabels[Name] = nil
        end
    end
    
    function Display:SetVisible(Visible)
        Display.Visible = Visible
        Container.Visible = Visible
    end
    
    function Display:StopUpdating()
        Display.Updating = false
    end
    
    function Display:Destroy()
        Display.Updating = false
        Container:Destroy()
    end
    
    Library:MakeDraggable(Container)
    
    return Display
end

Library:GiveSignal(ScreenGui.DescendantAdded:Connect(function(Instance)
    if Library.Unloaded then return end
    
    if Instance:IsA("Frame") or Instance:IsA("ScrollingFrame") then
        if not Instance:FindFirstChild("UICorner") and not Instance.Name:match("Cursor") then
            local UICorner = Instance:FindFirstChildOfClass("UICorner")
            if not UICorner then
                Library:Create('UICorner', {
                    CornerRadius = UDim.new(0, 6);
                    Parent = Instance;
                })
            end
        end
    end
end))

Library:GiveSignal(RunService.RenderStepped:Connect(function()
    if Library.Unloaded then return end
    
    if Library.CurrentRainbowColor and Library.GlowEnabled then
        for _, Instance in next, Library.Registry do
            if Instance.Instance:IsA("UIStroke") and Instance.Properties.Color == 'AccentColor' then
                Instance.Instance.Color = Library.CurrentRainbowColor
            elseif Instance.Instance:IsA("Frame") and Instance.Properties.BackgroundColor3 == 'AccentColor' then
                Instance.Instance.BackgroundColor3 = Library.CurrentRainbowColor
            elseif Instance.Instance:IsA("ImageLabel") and Instance.Properties.ImageColor3 == 'AccentColor' then
                Instance.Instance.ImageColor3 = Library.CurrentRainbowColor
            end
        end
    end
end))

getgenv().Linoria = Library
if getgenv().skip_getgenv_linoria ~= true then 
    getgenv().Library = Library 
end

return Library
