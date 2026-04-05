-- HACKER SCRIPT V13 - @Pedrohe_285 (ESP SEMPRE VERMELHO + AUTO-RESTART)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local char, hum, root

local function setupCharacter(c)
    char = c
    hum = c:WaitForChild("Humanoid")
    root = c:WaitForChild("HumanoidRootPart")
end

setupCharacter(plr.Character or plr.CharacterAdded:Wait())

-- CONFIG
local config = {
    speed = 40,
    flyspeed = 60,
    platformSize = 50
}

-- ESTADOS
local hacks = {
    fly=false,
    speed=false,
    noclip=false,
    infjump=false,
    aimbot=false,
    autofarm=false,
    tpAura=false,
    platform=nil,
    esp=false
}

-- ESP TABLE
local espObjects = {}

-- RESPAWN FIX
plr.CharacterAdded:Connect(function(c)
    setupCharacter(c)
    task.wait(1)
    if hacks.speed then hum.WalkSpeed = config.speed end
end)

-- GUI
local sg = Instance.new("ScreenGui", plr.PlayerGui)
sg.ResetOnSpawn = false

-- BOLA
local ball = Instance.new("TextButton", sg)
ball.Size = UDim2.new(0,70,0,70)
ball.Position = UDim2.new(0.02,0,0.2,0)
ball.Text = "V13"
ball.BackgroundColor3 = Color3.fromRGB(15,15,15)
ball.TextColor3 = Color3.fromRGB(255,0,0)
ball.TextScaled = true
ball.Draggable = true
Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)

-- MAIN
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0,380,0,520)
main.Position = UDim2.new(0.05,0,0.1,0)
main.BackgroundColor3 = Color3.fromRGB(10,10,10)
main.Visible = false
Instance.new("UICorner", main)

ball.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- FUNÇÕES UI
local function toggleBtn(p,text,y,callback)
    local state = false
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(0.9,0,0,40)
    b.Position = UDim2.new(0.05,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(25,25,25)
    b.TextColor3 = Color3.fromRGB(255,0,0)
    Instance.new("UICorner", b)

    local function update()
        b.Text = text.." : "..(state and "ON" or "OFF")
    end

    update()

    b.MouseButton1Click:Connect(function()
        state = not state
        update()
        callback(state)
    end)
end

local function box(p,txt,y,callback)
    local t = Instance.new("TextBox", p)
    t.Size = UDim2.new(0.9,0,0,35)
    t.Position = UDim2.new(0.05,0,0,y)
    t.PlaceholderText = txt
    t.BackgroundColor3 = Color3.fromRGB(15,15,15)
    t.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", t)

    t.FocusLost:Connect(function()
        local num = tonumber(t.Text)
        if num then callback(num) end
    end)
end

-- TABS
local function tab(name,x)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.32,0,0,40)
    b.Position = UDim2.new(x,0,0,0)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(20,20,20)
    b.TextColor3 = Color3.fromRGB(255,0,0)
    Instance.new("UICorner", b)
    return b
end

local t1 = tab("PLAYER",0)
local t2 = tab("COMBAT",0.34)
local t3 = tab("FARM",0.68)

local function makeFrame()
    local f = Instance.new("Frame", main)
    f.Size = UDim2.new(1,0,1,-50)
    f.Position = UDim2.new(0,0,0,50)
    f.Visible = false
    f.BackgroundTransparency = 1
    return f
end

local c1 = makeFrame()
local c2 = makeFrame()
local c3 = makeFrame()

local function show(f)
    c1.Visible=false c2.Visible=false c3.Visible=false
    f.Visible=true
end

t1.MouseButton1Click:Connect(function() show(c1) end)
t2.MouseButton1Click:Connect(function() show(c2) end)
t3.MouseButton1Click:Connect(function() show(c3) end)

show(c1)

-- MIRA "+"
local function line(x,y,w,h)
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0,w,0,h)
    f.Position = UDim2.new(0.5 + x,0,0.5 + y,0)
    f.BackgroundColor3 = Color3.new(1,0,0)
    return f
end

local cross1 = line(-10,0,20,2)
local cross2 = line(0,-10,2,20)
cross1.Visible = false
cross2.Visible = false

-- ESP FUNCTION (SEMPRE VERMELHO)
local function createESP(player)
    if player == plr or espObjects[player] then return end
    
    local esp = {
        box = nil,
        name = nil,
        distance = nil,
        player = player,
        connections = {}
    }
    
    -- BOX ESP SEMPRE VERMELHO
    esp.box = Instance.new("BoxHandleAdornment")
    esp.box.Size = Vector3.new(4,6,2)
    esp.box.Color3 = Color3.fromRGB(255,0,0) -- SEMPRE VERMELHO
    esp.box.Transparency = 0.5
    esp.box.AlwaysOnTop = true
    esp.box.ZIndex = 10
    esp.box.Parent = sg
    
    -- NAME ESP
    esp.name = Instance.new("BillboardGui")
    esp.name.Size = UDim2.new(0,100,0,50)
    esp.name.Adornee = nil
    esp.name.AlwaysOnTop = true
    esp.name.StudsOffset = Vector3.new(0,2,0)
    esp.name.Parent = sg
    
    local nameLabel = Instance.new("TextLabel", esp.name)
    nameLabel.Size = UDim2.new(1,0,0.5,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    
    esp.distance = Instance.new("TextLabel", esp.name)
    esp.distance.Size = UDim2.new(1,0,0.5,0)
    esp.distance.Position = UDim2.new(0,0,0.5,0)
    esp.distance.BackgroundTransparency = 1
    esp.distance.Text = "0m"
    esp.distance.TextColor3 = Color3.new(1,1,1)
    esp.distance.TextScaled = true
    esp.distance.Font = Enum.Font.SourceSans
    
    espObjects[player] = esp
    
    -- AUTO-RESTART QUANDO MORRER
    local function onCharacterAdded(character)
        task.wait(0.1)
        if espObjects[player] and player.Character == character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            
            if hrp and head then
                esp.box.Adornee = hrp
                esp.box.Size = hrp.Size
                esp.name.Adornee = head
            end
        end
    end
    
    esp.connections.characterAdded = player.CharacterAdded:Connect(onCharacterAdded)
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

local function removeESP(player)
    local esp = espObjects[player]
    if esp then
        for _, conn in pairs(esp.connections) do
            if conn then conn:Disconnect() end
        end
        if esp.box then esp.box:Destroy() end
        if esp.name then esp.name:Destroy() end
        espObjects[player] = nil
    end
end

-- PLAYER
toggleBtn(c1,"FLY",10,function(v) hacks.fly=v end)
toggleBtn(c1,"SPEED",60,function(v)
    hacks.speed=v
    hum.WalkSpeed = v and config.speed or 16
end)
toggleBtn(c1,"NOCLIP",110,function(v) hacks.noclip=v end)
toggleBtn(c1,"INF JUMP",160,function(v) hacks.infjump=v end)

box(c1,"Velocidade",210,function(v) config.speed=v end)
box(c1,"Fly Speed",260,function(v) config.flyspeed=v end)

-- COMBAT
toggleBtn(c2,"AIMBOT",10,function(v) hacks.aimbot=v end)
toggleBtn(c2,"TP AURA",60,function(v) hacks.tpAura = v end)

toggleBtn(c2,"MIRA",110,function(v)
    cross1.Visible=v
    cross2.Visible=v
end)

toggleBtn(c2,"ESP PLAYERS",160,function(v)
    hacks.esp = v
    if v then
        for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
        end
    else
        for player, _ in pairs(espObjects) do
            removeESP(player)
        end
    end
end)

-- FARM
toggleBtn(c3,"AUTO FARM",10,function(v) hacks.autofarm=v end)

toggleBtn(c3,"PLATAFORMA",60,function(v)
    if v then
        local p = Instance.new("Part")
        p.Size = Vector3.new(config.platformSize,1,config.platformSize)
        p.Anchored = true
        p.Position = root.Position - Vector3.new(0,5,0)
        p.Parent = workspace
        hacks.platform = p
    else
        if hacks.platform then hacks.platform:Destroy() hacks.platform=nil end
    end
end)

box(c3,"Tamanho da Plataforma",110,function(v)
    config.platformSize = v
    if hacks.platform then
        hacks.platform.Size = Vector3.new(v,1,v)
    end
end)

-- PLAYER JOIN/LEAVE
Players.PlayerAdded:Connect(function(player)
    if hacks.esp then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- LOOP PRINCIPAL
RunService.Heartbeat:Connect(function()
    if not root then return end
    
    if hacks.speed and hum then
        hum.WalkSpeed = config.speed
    end

    if hacks.fly then
        local cam = workspace.CurrentCamera
        root.Velocity = cam.CFrame.LookVector * config.flyspeed
    end

    if hacks.noclip and char then
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end

    -- ESP UPDATE (SEMPRE VERMELHO)
    if hacks.esp then
        for player, esp in pairs(espObjects) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
                local hrp = player.Character.HumanoidRootPart
                local head = player.Character.Head
                
                esp.box.Adornee = hrp
                esp.box.Size = hrp.Size
                esp.name.Adornee = head
                
                local distance = (root.Position - hrp.Position).Magnitude
                esp.distance.Text = math.floor(distance) .. "m"
                
                -- SEMPRE VERMELHO
                esp.box.Color3 = Color3.fromRGB(255,0,0)
            end
        end
    end

    -- RESTO DO CÓDIGO (AIMBOT, TP AURA, AUTO FARM) igual...
    if hacks.aimbot then
        local closest, dist = nil, math.huge
        for _,v in pairs(Players:GetPlayers()) do
            if v ~= plr and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                local d = (root.Position - head.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = head
                end
            end
        end
        if closest then
            root.CFrame = root.CFrame:Lerp(CFrame.new(root.Position, closest.Position), 0.2)
        end
    end

    if hacks.tpAura then
        local closest, dist = nil, math.huge
        for _,v in pairs(Players:GetPlayers()) do
            if v ~= plr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                local d = (root.Position - hrp.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = v.Character
                end
            end
        end
        if closest and closest:FindFirstChild("HumanoidRootPart") then
            root.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
        end
    end

    if hacks.autofarm then
        local closest, dist = nil, math.huge
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local name = v.Name:lower()
                if name:find("og") or name:find("segredo") then
                    local d = (root.Position - v.Position).Magnitude
                    if d < dist then
                        dist = d
                        closest = v
                    end
                end
            end
        end
        if closest then
            root.CFrame = closest.CFrame + Vector3.new(0,3,0)
        end
    end
end)

-- INF JUMP
UIS.JumpRequest:Connect(function()
    if hacks.infjump then
        hum:ChangeState("Jumping")
    end
end)

print("🔥 @pedrohe_285 - ESP SEMPRE VERMELHO + AUTO-RESTART NA MORTE!")
