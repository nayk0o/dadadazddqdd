-- Services
local Players = game:GetService("Players")

-- Local player
local LocalPlayer = Players.LocalPlayer

-- Replace the current Humanoid with a clean copy
local function replaceHumanoid(character)
    local oldHumanoid = character:FindFirstChildOfClass("Humanoid")

    if not oldHumanoid then
        return
    end

    -- Save important properties
    local walkSpeed = oldHumanoid.WalkSpeed
    local jumpPower = oldHumanoid.JumpPower
    local jumpHeight = oldHumanoid.JumpHeight
    local health = oldHumanoid.Health
    local maxHealth = oldHumanoid.MaxHealth

    -- Save the current camera
    local camera = workspace.CurrentCamera

    -- Find the animation script
    local animateScript = character:FindFirstChild("Animate")

    -- Temporarily disable animations
    if animateScript and animateScript:IsA("LocalScript") then
        animateScript.Disabled = true
    end

    -- Stop currently playing animations
    local animator = oldHumanoid:FindFirstChildOfClass("Animator")

    if animator then
        for _, animationTrack in next, animator:GetPlayingAnimationTracks() do
            animationTrack:Stop(0)
        end
    end

    -- Allow the Humanoid to be cloned
    oldHumanoid.Archivable = true

    -- Clone the Humanoid
    local newHumanoid = oldHumanoid:Clone()

    -- Remove the old Animator from the clone
    for _, child in next, newHumanoid:GetChildren() do
        if child:IsA("Animator") then
            child:Destroy()
        end
    end

    -- Replace the old Humanoid
    oldHumanoid.Name = "_OldHumanoid"
    newHumanoid.Name = "Humanoid"
    newHumanoid.Parent = character

    -- Create a new Animator
    local newAnimator = Instance.new("Animator")
    newAnimator.Parent = newHumanoid

    -- Restore the saved properties
    newHumanoid.WalkSpeed = walkSpeed
    newHumanoid.JumpPower = jumpPower
    newHumanoid.JumpHeight = jumpHeight
    newHumanoid.MaxHealth = maxHealth
    newHumanoid.Health = math.min(health, maxHealth)

    -- Make the camera follow the new Humanoid
    if camera then
        camera.CameraSubject = newHumanoid
    end

    -- Remove the old Humanoid
    oldHumanoid:Destroy()

    -- Re-enable the animation script
    if animateScript and animateScript:IsA("LocalScript") then
        task.wait()
        animateScript.Disabled = false

        task.defer(function()
            if animateScript.Parent then
                animateScript.Disabled = true
                task.wait()
                animateScript.Disabled = false
            end
        end)
    end

    -- Put the new Humanoid into the Running state
    task.defer(function()
        if newHumanoid.Parent then
            newHumanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)

    return newHumanoid
end

-- Setup a newly spawned character
local function setupCharacter(character)
    character:WaitForChild("Humanoid")
    task.wait()
    replaceHumanoid(character)
end

-- Handle the current character
if LocalPlayer.Character then
    task.spawn(setupCharacter, LocalPlayer.Character)
end

-- Handle future respawns
LocalPlayer.CharacterAdded:Connect(function(character)
    task.spawn(setupCharacter, character)
end)
