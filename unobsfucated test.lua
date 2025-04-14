local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local topServices = {
    Workspace,
    ReplicatedStorage,
    StarterPlayer,
    Players,
}
local gui = Instance.new("ScreenGui")
gui.Name = "FolderedExplorer"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0.8, 0)
mainFrame.Position = UDim2.new(1, -360, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
local UserInputService = game:GetService("UserInputService")
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Super Duper Explorer"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansSemibold
titleLabel.TextSize = 22
titleLabel.Parent = mainFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -30)
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.Parent = mainFrame

local mainList = Instance.new("UIListLayout")
mainList.Padding = UDim.new(0, 4)
mainList.SortOrder = Enum.SortOrder.LayoutOrder
mainList.Parent = scrollFrame

mainList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, mainList.AbsoluteContentSize.Y)
end)
local function createNode(object, indent)
    indent = indent or 0
    local nodeFrame = Instance.new("Frame")
    nodeFrame.Size = UDim2.new(1, 0, 0, 0)
    nodeFrame.BackgroundTransparency = 1
    nodeFrame.AutomaticSize = Enum.AutomaticSize.Y
    local nodeLayout = Instance.new("UIListLayout", nodeFrame)
    nodeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 22)
    header.BackgroundTransparency = 1
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Font = Enum.Font.Code
    header.TextSize = 14
    header.TextColor3 = Color3.fromRGB(200, 200, 200)
    header.AutoButtonColor = false
    header.Parent = nodeFrame

    local hasChildren = #object:GetChildren() > 0
    local collapsedIndicator = "►"
    local expandedIndicator = "▼"

    local function updateHeader(expanded)
        local indicator = ""
        if hasChildren then
            indicator = expanded and expandedIndicator or collapsedIndicator
        end
        header.Text = string.rep("    ", indent) .. indicator .. " " .. object.Name .. " [" .. object.ClassName .. "]"
    end

    updateHeader(false)
    local childrenContainer = Instance.new("Frame")
    childrenContainer.Size = UDim2.new(1, 0, 0, 0)
    childrenContainer.BackgroundTransparency = 1
    childrenContainer.AutomaticSize = Enum.AutomaticSize.Y
    childrenContainer.Visible = false
    childrenContainer.Parent = nodeFrame

    local childrenLayout = Instance.new("UIListLayout", childrenContainer)
    childrenLayout.Padding = UDim.new(0, 4)
    childrenLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local expanded = false

    if hasChildren then
        header.MouseButton1Click:Connect(function()
            expanded = not expanded
            if expanded then
                updateHeader(expanded)
                childrenContainer.Visible = true
                for _, child in ipairs(object:GetChildren()) do
                    local childNode = createNode(child, indent + 1)
                    childNode.Parent = childrenContainer
                end
            else
                updateHeader(expanded)
                for _, childNode in ipairs(childrenContainer:GetChildren()) do
                    if childNode:IsA("Frame") then
                        childNode:Destroy()
                    end
                end
                childrenContainer.Visible = false
            end
        end)
    else
        header.MouseButton1Click:Connect(function()
            print("Selected:", object:GetFullName(), object)
        end)
    end

    return nodeFrame
end
local function buildTree(rootObject, parentContainer)
    local node = createNode(rootObject, 0)
    node.Parent = parentContainer
end
for _, obj in ipairs(topServices) do
    buildTree(obj, scrollFrame)
end
