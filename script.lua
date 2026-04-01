-- AUTO TELEPORT COMPLETO - DRAGGABLE + MINIMIZE
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local TeleportGui = Instance.new("ScreenGui")
TeleportGui.Name = "AutoTeleportGui"
TeleportGui.Parent = player:WaitForChild("PlayerGui")
TeleportGui.ResetOnSpawn = false

local savePoint = nil
local autoLoop = nil
local teleportCount = 0
local timeLeft = 20
local isAutoRunning = false
local isMinimized = false

-- Frame principal (ARRÁSTAVEL)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 420)
mainFrame.Position = UDim2.new(0.5, -100, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = TeleportGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15)
frameCorner.Parent = mainFrame

-- Título com botões minimize/close
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -70, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ AUTO TP"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.Parent = titleBar

-- Botão MINIMIZE
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -65, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minimizeBtn

-- Botão CLOSE
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeBtn

-- Conteúdo (que some quando minimizado)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Contador
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, 0, 0, 40)
countLabel.Position = UDim2.new(0, 0, 0, 0)
countLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
countLabel.Text = "Teleportes: 0"
countLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
countLabel.TextScaled = true
countLabel.Font = Enum.Font.GothamBold
countLabel.Parent = contentFrame

local countCorner = Instance.new("UICorner")
countCorner.CornerRadius = UDim.new(0, 8)
countCorner.Parent = countLabel

-- Timer
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 40)
timerLabel.Position = UDim2.new(0, 0, 0, 45)
timerLabel.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
timerLabel.Text = "20s ⏱️"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Parent = contentFrame

local timerCorner = Instance.new("UICorner")
timerCorner.CornerRadius = UDim.new(0, 8)
timerCorner.Parent = timerLabel

-- Função criar botão
local function createButton(name, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -10, 0, 50)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.Parent = contentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Botões
local markBtn = createButton("MarkBtn", "🎯 MARCAR & INICIAR", UDim2.new(0, 5, 0, 95), function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savePoint = char.HumanoidRootPart.CFrame
        startAutoTeleport()
        markBtn.Text = "✅ AUTO RODANDO"
        markBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    end
end)

local stopBtn = createButton("StopBtn", "⏹️ PARAR AUTO", UDim2.new(0, 5, 0, 155), function()
    stopAutoTeleport()
    stopBtn.Text = "⏹️ PARADO"
    stopBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    wait(1)
    stopBtn.Text = "⏹️ PARAR AUTO"
    stopBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end)

local tpBtn = createButton("TpBtn", "✨ TP MANUAL", UDim2.new(0, 5, 0, 215), function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and savePoint then
        char.HumanoidRootPart.CFrame = savePoint
        teleportCount = teleportCount + 1
        countLabel.Text = "Teleportes: " .. teleportCount
    end
end)

local mouseBtn = createButton("MouseBtn", "🖱️ MOUSE CLICK", UDim2.new(0, 5, 0, 275), function()
    local conn
    conn = mouse.Button1Down:Connect(function()
        savePoint = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
        print("Ponto mouse marcado!")
        conn:Disconnect()
    end)
end)

-- FUNÇÕES MINIMIZE/CLOSE
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 40)}):Play()
        minimizeBtn.Text = "+"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 420)}):Play()
        minimizeBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if autoLoop then stopAutoTeleport() end
    TeleportGui:Destroy()
end)

-- AUTO TELEPORT
function startAutoTeleport()
    if autoLoop then return end
    isAutoRunning = true
    autoLoop = true
    spawn(function()
        while autoLoop do
            wait(1)
            timeLeft = timeLeft - 1
            timerLabel.Text = timeLeft .. "s ⏱️"
            if timeLeft <= 0 then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and savePoint then
                    char.HumanoidRootPart.CFrame = savePoint
                    teleportCount = teleportCount + 1
                    countLabel.Text = "Teleportes: " .. teleportCount
                end
                timeLeft = 20
            end
        end
    end)
end

function stopAutoTeleport()
    autoLoop = false
    isAutoRunning = false
    timeLeft = 20
    timerLabel.Text = "20s ⏱️"
end

-- Teclas
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.T and savePoint then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = savePoint
            teleportCount = teleportCount + 1
            countLabel.Text = "Teleportes: " .. teleportCount
        end
    elseif input.KeyCode == Enum.KeyCode.X then
        if isAutoRunning then stopAutoTeleport() else startAutoTeleport() end
    end
end)

print("🎉 AUTO TELEPORT COMPLETO CARREGADO!")
print("🖱️ ARRASTE pela barra azul")
print("− Minimizar / ✕ Fechar / T=TP / X=Auto")
