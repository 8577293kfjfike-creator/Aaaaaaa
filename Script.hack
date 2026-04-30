-- HACKER SCRIPT V13 - @Pedrohe_285 (ESP SEMPRE VERMELHO + 360° AIMBOT COM ANTI-WALL)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local char, hum, root
local camera = workspace.CurrentCamera

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
    platformSize = 50,
    aimPower = 50,
    aimRadius = 120,
    autoShoot = true,
    shootDelay = 0.08
}

-- STATES
local hacks = {
    fly = false,
    speed = false,
    noclip = false,
    infjump = false,
    aimbot = false,
    autofarm = false,
    tpAura = false,
    platform = nil,
    esp = false
}

local espObjects = {}

local lockedTarget = nil
local lastShootTime = 0

-- FOV CIRCLE
local sg = Instance.new("ScreenGui", plr.PlayerGui)
sg.ResetOnSpawn = false

local FOV = Instance.new("Frame", sg)
FOV.Size = UDim2.new(0, 240, 0, 240)
FOV.Position = UDim2.new(0.5, -120, 0.5, -120)
FOV.BackgroundTransparency = 1
FOV.Visible = false

local stroke = Instance.new("UIStroke", FOV)
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 2

local corner = Instance.new("UICorner", FOV)
corner.CornerRadius = UDim.new(1, 0)

-- RESPAWN
plr.CharacterAdded:Connect(function(c)
    setupCharacter(c)
    task.wait(1)
    if hacks.speed then hum.WalkSpeed = config.speed end
end)

-- DRAG BUTTON
local ball = Instance.new("TextButton", sg)
ball.Size = UDim2.new(0, 70, 0, 70)
ball.Position = UDim2.new(0.02, 0, 0.2, 0)
ball.Text = "@pedrohe_285"
ball.TextSize = 12
ball.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ball.TextColor3 = Color3.fromRGB(255, 0, 0)
ball.TextWrapped = true
ball.Draggable = true
Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

-- MAIN GUI
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 380, 0, 520)
main.Position = UDim2.new(0.05, 0, 0.1, 0)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.Visible = false
Instance.new("UICorner", main)

ball.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- UI FUNCTIONS
local function toggleBtn(p, text, y, callback)
    local state = false
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    b.TextColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UICorner", b)

    local function update()
        b.Text = text .. " : " .. (state and "ON" or "OFF")
    end

    update()

    b.MouseButton1Click:Connect(function()
        state = not state
        update()
        callback(state)
    end)
end

local function box(p, txt, y, callback)
    local t = Instance.new("TextBox", p)
    t.Size = UDim2.new(0.9, 0, 0, 35)
    t.Position = UDim2.new(0.05, 0, 0, y)
    t.PlaceholderText = txt
    t.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    t.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", t)

    t.FocusLost:Connect(function()
        local num = tonumber(t.Text)
        if num then callback(num) end
    end)
end

-- TABS
local function tab(nome, x)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.32, 0, 0, 40)
    b.Position = UDim2.new(x, 0, 0, 0)
    b.Text = nome
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.TextColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UICorner", b)
    return b
end

local t1 = tab("PLAYER", 0)
local t2 = tab("COMBAT", 0.34)
local t3 = tab("FARM", 0.68)

local function makeFrame()
    local f = Instance.new("Frame", main)
    f.Size = UDim2.new(1, 0, 1, -50)
    f.Position = UDim2.new(0, 0, 0, 50)
    f.Visible = false
    f.BackgroundTransparency = 1
    return f
end

local c1 = makeFrame()
local c2 = makeFrame()
local c3 = makeFrame()

local function show(f)
    c1.Visible = false; c2.Visible = false; c3.Visible = false
    f.Visible = true
end

t1.MouseButton1Click:Connect(function() show(c1) end)
t2.MouseButton1Click:Connect(function() show(c2) end)
t3.MouseButton1Click:Connect(function() show(c3) end)

show(c1)

-- CROSSHAIR "+"
local function createLine(x, y, w, h)
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, w, 0, h)
    f.Position = UDim2.new(0.5 + x, 0, 0.5 + y, 0)
    f.BackgroundColor3 = Color3.new(1, 0, 0)
    return f
end

local cross1 = createLine(-10, 0, 20, 2)
local cross2 = createLine(0, -10, 2, 20)
cross1.Visible = false
cross2.Visible = false

-- ESP FUNCTION
local function createESP(player)
    if player == plr or espObjects[player] then return end

    local esp = {
        box = nil,
        name = nil,
        distance = nil,
        player = player,
        connections = {}
    }

    esp.box = Instance.new("BoxHandleAdornment")
    esp.box.Size = Vector3.new(4, 6, 2)
    esp.box.Color3 = Color3.fromRGB(255, 0, 0)
    esp.box.Transparency = 0.5
    esp.box.AlwaysOnTop = true
    esp.box.ZIndex = 10
    esp.box.Parent = sg

    esp.name = Instance.new("BillboardGui")
    esp.name.Size = UDim2.new(0, 100, 0, 50)
    esp.name.AlwaysOnTop = true
    esp.name.StudsOffset = Vector3.new(0, 2, 0)
    esp.name.Parent = sg

    local nameLabel = Instance.new("TextLabel", esp.name)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold

    esp.distance = Instance.new("TextLabel", esp.name)
    esp.distance.Size = UDim2.new(1, 0, 0.5, 0)
    esp.distance.Position = UDim2.new(0, 0, 0.5, 0)
    esp.distance.BackgroundTransparency = 1
    esp.distance.Text = "0m"
    esp.distance.TextColor3 = Color3.new(1, 1, 1)
    esp.distance.TextScaled = true
    esp.distance.Font = Enum.Font.SourceSans

    espObjects[player] = esp

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

-- PLAYER TAB
toggleBtn(c1, "FLY", 10, function(v) hacks.fly = v end)
toggleBtn(c1, "SPEED", 60, function(v)
    hacks.speed = v
    hum.WalkSpeed = v and config.speed or 16
end)
toggleBtn(c1, "NOCLIP", 110, function(v) hacks.noclip = v end)
toggleBtn(c1, "INFINITE JUMP", 160, function(v) hacks.infjump = v end)

box(c1, "Speed", 210, function(v) config.speed = v end)
box(c1, "Fly Speed", 260, function(v) config.flyspeed = v end)

-- COMBAT TAB
toggleBtn(c2, "TP AURA", 10, function(v) hacks.tpAura = v end)

toggleBtn(c2, "CROSSHAIR", 60, function(v)
    cross1.Visible = v
    cross2.Visible = v
end)

toggleBtn(c2, "ESP", 110, function(v)
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

toggleBtn(c2, "AIMBOT", 160, function(v)
    hacks.aimbot = v
    FOV.Visible = v
    if not v then
        lockedTarget = nil
    end
end)

toggleBtn(c2, "AUTO SHOOT", 210, function(v)
    config.autoShoot = v
end)

box(c2, "Aim Power (0-100)", 260, function(v)
    config.aimPower = math.clamp(v, 0, 100)
end)

box(c2, "FOV Size", 310, function(v)
    config.aimRadius = v
    FOV.Size = UDim2.new(0, v * 2, 0, v * 2)
    FOV.Position = UDim2.new(0.5, -v, 0.5, -v)
end)

-- FARM TAB
toggleBtn(c3, "AUTO FARM", 10, function(v) hacks.autofarm = v end)

toggleBtn(c3, "PLATFORM", 60, function(v)
    if v then
        local p = Instance.new("Part")
        p.Size = Vector3.new(config.platformSize, 1, config.platformSize)
        p.Anchored = true
        p.Position = root.Position - Vector3.new(0, 5, 0)
        p.Parent = workspace
        hacks.platform = p
    else
        if hacks.platform then hacks.platform:Destroy() hacks.platform = nil end
    end
end)

box(c3, "Platform Size", 110, function(v)
    config.platformSize = v
    if hacks.platform then
        hacks.platform.Size = Vector3.new(v, 1, v)
    end
end)

-- PLAYER JOIN/LEAVE
Players.PlayerAdded:Connect(function(player)
    if hacks.esp then createESP(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    if lockedTarget == player then lockedTarget = nil end
end)

-- TRACK DEATHS
for _, player in pairs(Players:GetPlayers()) do
    if player ~= plr then
        spawn(function()
            player.CharacterAdded:Connect(function()
                wait(0.1)
                if lockedTarget == player then lockedTarget = nil end
            end)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Died:Connect(function()
                    if lockedTarget == player then lockedTarget = nil end
                end)
            end
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    spawn(function()
        player.CharacterAdded:Connect(function()
            wait(0.1)
            if lockedTarget == player then lockedTarget = nil end
        end)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Died:Connect(function()
                if lockedTarget == player then lockedTarget = nil end
            end)
        end
    end)
end)

-- VISIBILITY CHECK (ANTI-WALL)
local function isVisible(part)
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 1000

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {plr.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local ray = workspace:Raycast(origin, direction, params)

    if ray and ray.Instance then
        return ray.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

-- ============================================
-- AIMBOT 360° COM ANTI-WALL E TIRO NA MIRA
-- ============================================

-- SÓ considera inimigos VISÍVEIS (não passa por parede)
local function getClosestVisibleTarget()
    local closest = nil
    local shortestDist = config.aimRadius

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            local humanoid = v.Character.Humanoid
            local part = v.Character.HumanoidRootPart

            if humanoid.Health > 0 and isVisible(part) then
                local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude

                if dist < shortestDist then
                    shortestDist = dist
                    closest = v
                end
            end
        end
    end
    return closest
end

local function isValid(t)
    if not t then return false end
    if not t.Character then return false end
    local hrp = t.Character:FindFirstChild("HumanoidRootPart")
    local hum = t.Character:FindFirstChild("Humanoid")
    if not hrp or not hum then return false end
    if hum.Health <= 0 then return false end
    -- ANTI-WALL: verifica visibilidade mesmo no target atual
    return isVisible(hrp)
end

-- Verifica se o inimigo está DENTRO da crosshair (centro da tela)
local function isInCrosshair(part, threshold)
    threshold = threshold or 30 -- pixels de tolerância
    local pos, onScreen = camera:WorldToViewportPoint(part.Position)
    if not onScreen then return false end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
    return dist < threshold
end

-- AUTO SHOOT SÓ QUANDO NA MIRA
local function tryShoot()
    if not config.autoShoot then return end
    if not lockedTarget then return end
    if not lockedTarget.Character then return end
    local hrp = lockedTarget.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- SÓ ATIRA SE O INIMIGO ESTIVER DENTRO DA CROSSHAIR
    if isInCrosshair(hrp, 35) then
        if tick() - lastShootTime > config.shootDelay then
            keypress(0x01)
            wait(0.01)
            keyrelease(0x01)
            lastShootTime = tick()
        end
    end
end

-- MAIN LOOP (Physics)
RunService.Heartbeat:Connect(function()
    if not root or not hum then return end

    if hacks.speed then
        hum.WalkSpeed = config.speed
    end

    if hacks.fly then
        root.Velocity = camera.CFrame.LookVector * config.flyspeed
    end

    if hacks.noclip and char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- ESP UPDATE
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
                esp.box.Color3 = Color3.fromRGB(255, 0, 0)
            end
        end
    end

    -- TP AURA
    if hacks.tpAura then
        local closest, dist = nil, math.huge
        for _, v in pairs(Players:GetPlayers()) do
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
            root.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
        end
    end

    -- AUTO FARM
    if hacks.autofarm then
        local closest, dist = nil, math.huge
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local name = v.Name:lower()
                if name:find("og") or name:find("secret") then
                    local d = (root.Position - v.Position).Magnitude
                    if d < dist then
                        dist = d
                        closest = v
                    end
                end
            end
        end
        if closest then
            root.CFrame = closest.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- AIMBOT LOOP (360° - VIRA PRA ATRÁS + ANTI-WALL + TIRO NA MIRA)
RunService.RenderStepped:Connect(function()
    if not hacks.aimbot or not camera then return end

    -- Busca novo alvo apenas VISÍVEL (anti-wall ativado)
    if not isValid(lockedTarget) then
        lockedTarget = getClosestVisibleTarget()
    end

    if isValid(lockedTarget) then
        local part = lockedTarget.Character.HumanoidRootPart

        -- 360°: calcula direção e vira a câmera mesmo se tiver atrás
        local dir = (part.Position - camera.CFrame.Position).Unit
        local newCF = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + dir)

        -- SMOOTH: vira suavemente pra qualquer direção (inclusive 180°)
        camera.CFrame = camera.CFrame:Lerp(newCF, config.aimPower / 150)

        -- TENTA ATIRAR: só dispara se o inimigo estiver na crosshair
        tryShoot()
    end
end)

-- INFINITE JUMP
UIS.JumpRequest:Connect(function()
    if hacks.infjump then
        hum:ChangeState("Jumping")
    end
end)

print("🔥 V13 @pedrohe_285 - AIMBOT 360° ANTI-WALL + TIRO NA MIRA!")
