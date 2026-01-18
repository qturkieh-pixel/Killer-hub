local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local saveFile = "MinimalStats_Pos.json"

local function loadPos()
    if isfile(saveFile) then
        local d = HttpService:JSONDecode(readfile(saveFile))
        return UDim2.new(d.XS, d.XO, d.YS, d.YO)
    end
end

local function savePos(p)
    writefile(saveFile, HttpService:JSONEncode({
        XS = p.X.Scale,
        XO = p.X.Offset,
        YS = p.Y.Scale,
        YO = p.Y.Offset
    }))
end

local sg = Instance.new("ScreenGui")
sg.Name = "MinimalStats"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0,100,0,40)
main.Position = loadPos() or UDim2.new(0.5,-50,0.1,0)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0
main.Active = true
main.Parent = sg
main.Visible = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0,9)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 1.2
stroke.Color = Color3.new(1,1,1)
stroke.Transparency = 0.8

local layout = Instance.new("UIListLayout", main)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0,1)

local function label()
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,15)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = 10
    l.Parent = main
    return l
end

local fpsLabel = label()
local pingLabel = label()

local dragging, dragInput, dragStart, startPos

main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPos = main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                dragging = false
                savePos(main.Position)
            end
        end)
    end
end)

main.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        dragInput = i
    end
end)

UIS.InputChanged:Connect(function(i)
    if i == dragInput and dragging then
        local d = i.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + d.X,
            startPos.Y.Scale,
            startPos.Y.Offset + d.Y
        )
    end
end)

local frames = 0
local last = tick()

RS.RenderStepped:Connect(function()
    frames += 1
    local now = tick()

    if now - last >= 1 then
        local fps = frames
        local ping = Stats.PerformanceStats.Ping:GetValue()
        
        fpsLabel.Text = "FPS: "..fps
        pingLabel.Text = "PING: "..string.format("%.0f", ping).."ms"

        if fps >= 50 then
            fpsLabel.TextColor3 = Color3.fromRGB(120,255,120)
        elseif fps >= 30 then
            fpsLabel.TextColor3 = Color3.fromRGB(255,200,80)
        else
            fpsLabel.TextColor3 = Color3.fromRGB(255,80,80)
        end

        frames = 0
        last = now
    end
end)
