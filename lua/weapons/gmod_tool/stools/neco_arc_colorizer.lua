TOOL.Category = 'Neco Arc'
TOOL.Name = '#tool.neco_arc_colorizer.name'

TOOL.Information = {
	{ name = 'left' },
	{ name = 'right' },
	{ name = 'reload' }
}

TOOL.DefaultColors = {
    Eyes = Color(255, 255, 255),
    Shirt = Color(255, 255, 255),
    Pupils = Color(180, 0, 0),
    Legs = Color(0, 0, 0),
    Skirt = Color(107, 57, 91),
    Ears = Color(237, 156, 155),
    Hair = Color(235, 187, 123),
    Tail = Color(235, 187, 123),
    Skin = Color(240, 215 ,192),
}

local defaultColors = TOOL.DefaultColors

for name, color in pairs(defaultColors) do
    name = name:lower()

    TOOL.ClientConVar[name .. '_r'] = color.r
    TOOL.ClientConVar[name .. '_g'] = color.g
    TOOL.ClientConVar[name .. '_b'] = color.b
end

function TOOL:LeftClick(tr)
    local ent = tr.Entity

    if not IsValid(ent) or ent:GetClass() ~= 'l55_necoarc_drg' then return false end
    if CLIENT then return true end

    for name, color in pairs(defaultColors) do
        local conVarName = name:lower() .. '_'

        local r = self:GetClientNumber(conVarName .. 'r', 0)
        local g = self:GetClientNumber(conVarName .. 'g', 0)
        local b = self:GetClientNumber(conVarName .. 'b', 0)

        ent:SetNWVector('Neco' .. name .. 'Color', Color(r, g, b):ToVector())
    end

	return true
end

function TOOL:RightClick(tr)
    local ent = tr.Entity

    if not IsValid(ent) or ent:GetClass() ~= 'l55_necoarc_drg' then return false end
    if CLIENT then return true end

    local owner = self:GetOwner()
    if not owner:IsValid() then return end -- what the fudge

    for name, color in pairs(defaultColors) do
        local setColor = ent:GetNWVector('Neco' .. name .. 'Color', false)

        if not setColor then
            setColor = color
        else
            setColor = setColor:ToColor()
        end

        local conVarName = 'neco_arc_colorizer_' .. name:lower()

        owner:ConCommand(conVarName .. '_r ' .. setColor.r)
        owner:ConCommand(conVarName .. '_g ' .. setColor.g)
        owner:ConCommand(conVarName .. '_b ' .. setColor.b)
    end

	return true
end

function TOOL:Reload(tr)
    local ent = tr.Entity

    if not IsValid(ent) or ent:GetClass() ~= 'l55_necoarc_drg' then return false end
    if CLIENT then return true end

    for name, color in pairs(defaultColors) do
        ent:SetNWVector('Neco' .. name .. 'Color', color:ToVector())
    end

	return true
end

if SERVER then return end

CreateConVar(
    'dhzz_neco_arc_preset_spawn', 
    '0', 
    FCVAR_ARCHIVE,
    "Determines whether or not Neco Arc's you spawn will have a random preset you created with the Neco Arc Colorizer tool."
)

language.Add('tool.neco_arc_colorizer.name', 'Colorizer')
language.Add('tool.neco_arc_colorizer.desc', 'Neco Arc NextBot: Colorize separate parts')

language.Add('tool.neco_arc_colorizer.left', 'Apply colors')
language.Add('tool.neco_arc_colorizer.right', 'Copy colors')
language.Add('tool.neco_arc_colorizer.reload', 'Reset colors back to default')

local defaultConVars = TOOL:BuildConVarList()

function TOOL.BuildCPanel(panel)
	panel:Help('Presets:')
	
    local presets = panel:ToolPresets('neco_arc_colorizer', defaultConVars)
    local randomizeButton = panel:Button('Randomize All')

    function randomizeButton:DoClick()
        presets.DropDown:SetText('')

        for name, color in pairs(defaultColors) do
            local conVarName = 'neco_arc_colorizer_' .. name:lower()
            local r, g, b = math.random(255), math.random(255), math.random(255)

            RunConsoleCommand(conVarName .. '_r', r)
            RunConsoleCommand(conVarName .. '_g', g)
            RunConsoleCommand(conVarName .. '_b', b)
        end
    end

    local resetButton = panel:Button('Reset All')

    function resetButton:DoClick()
        presets.DropDown:SetText('Default')

        for name, color in pairs(defaultColors) do
            local conVarName = 'neco_arc_colorizer_' .. name:lower()

            RunConsoleCommand(conVarName .. '_r', color.r)
            RunConsoleCommand(conVarName .. '_g', color.g)
            RunConsoleCommand(conVarName .. '_b', color.b)
        end
    end

    local checkBox = vgui.Create('DCheckBoxLabel', panel)

    checkBox:SetConVar('dhzz_neco_arc_preset_spawn')
    checkBox:SetText("Spawn with random color preset")
    checkBox:SetTooltip("Neco Arc's that you spawn will have a random color preset you have added.")

    panel:AddItem(checkBox)

    panel:Help('\nModel Preview:')

    local modelPreview = vgui.Create("DModelPanel", modelPreviewBG)
    local camPos = Vector(20, 150, 20)

    modelPreview:SetModel("models/zaurzo_dughoo/necoarc_animated/necoarc1.mdl")
    modelPreview:SetSize(200, 225)
    modelPreview:SetCamPos(camPos)
    modelPreview:SetLookAt(Vector(0, 0, 20))
    modelPreview:SetFOV(20)
    modelPreview:SetMouseInputEnabled(true)

    function modelPreview:Think()
        camPos.y = self:GetWide() / 1.8
    end

    local Paint = modelPreview.Paint

    function modelPreview:Paint(w, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)

        Paint(self, w, h)
    end

    local ent = modelPreview:GetEntity()
    local ang = Angle(0, 80, 0)

    ent:SetSequence(17)

    local isHolding = false
    local lastMouseX = 0

    function ent:RenderOverride()
        render.SuppressEngineLighting(true)

        self:DrawModel()

        render.SuppressEngineLighting(false)
    end

    function modelPreview:LayoutEntity(ent)
        if isHolding then
            if not self:IsHovered() then
                isHolding = false
            end

            local x = gui.MouseX()

            ang.y = ang.y + (x - lastMouseX) 

            lastMouseX = x
        end

        ent:SetAngles(ang)
    end

    function modelPreview:OnMousePressed(code)
        if code ~= MOUSE_LEFT then return end

        isHolding = true
        lastMouseX = gui.MouseX()
    end

    function modelPreview:OnMouseReleased(code)
        if isHolding and code == MOUSE_LEFT then
            isHolding = false
        end
    end

    panel:AddItem(modelPreview)

    for name, color in pairs(defaultColors) do
        local conVarName = 'neco_arc_colorizer_' .. name:lower()

        local picker = panel:ColorPicker(name, conVarName .. '_r', conVarName .. '_g', conVarName .. '_b')
        local mixer = picker.Mixer

        mixer:SetAlphaBar(false)
        mixer:UpdateDefaultColor()

        picker:SetTall(200)

        local prevModelColor = mixer:GetColor():ToVector()

        ent['Get' .. name .. 'Color'] = function()
            return prevModelColor
        end

        function mixer:ValueChanged(col)
            local r = col.r / 255
            local g = col.g / 255
            local b = col.b / 255

            prevModelColor:SetUnpacked(r, g, b)
        end

        local colorPreview = vgui.Create('DPanel', panel)

        colorPreview:SetTall(20)

        panel:AddItem(colorPreview)

        function colorPreview:Paint(w, h)
            local color = mixer:GetColor()

            surface.SetDrawColor(color.r, color.g, color.b)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(0, 0, 0)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        local randomizeButton = panel:Button('Randomize')

        function randomizeButton:DoClick()
            local r, g, b = math.random(255), math.random(255), math.random(255)

            RunConsoleCommand(conVarName .. '_r', r)
            RunConsoleCommand(conVarName .. '_g', g)
            RunConsoleCommand(conVarName .. '_b', b)
        end

        local resetButton = panel:Button('Reset')

        function resetButton:DoClick()
            RunConsoleCommand(conVarName .. '_r', color.r)
            RunConsoleCommand(conVarName .. '_g', color.g)
            RunConsoleCommand(conVarName .. '_b', color.b)
        end
    end
end