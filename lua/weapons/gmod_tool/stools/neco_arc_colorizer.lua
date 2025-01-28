
TOOL.Category = "Neco Arc"
TOOL.Name = "#tool.neco_arc_colorizer.name"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
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

for name, color in pairs(TOOL.DefaultColors) do
    name = name:lower()

    TOOL.ClientConVar[name .. '_r'] = color.r
    TOOL.ClientConVar[name .. '_g'] = color.g
    TOOL.ClientConVar[name .. '_b'] = color.b
end

local defaultColors = TOOL.DefaultColors

if CLIENT then
    language.Add('tool.neco_arc_colorizer.name', 'Colorizer')
    language.Add('tool.neco_arc_colorizer.desc', 'Neco Arc NextBot: Colorize separate parts')

    language.Add('tool.neco_arc_colorizer.left', 'Apply colors')
    language.Add('tool.neco_arc_colorizer.right', 'Copy colors')
    language.Add('tool.neco_arc_colorizer.reload', 'Reset colors back to default')
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

local defaultConVars = TOOL:BuildConVarList()

function TOOL.BuildCPanel(panel)
	panel:Help('#tool.neco_arc_colorizer.desc')
	panel:ToolPresets('neco_arc_colorizer', defaultConVars)

    for name, color in pairs(defaultColors) do
        local conVarName = 'neco_arc_colorizer_' .. name:lower()

        local picker = panel:ColorPicker(name, conVarName .. '_r', conVarName .. '_g', conVarName .. '_b')
        local mixer = picker.Mixer

        mixer:SetAlphaBar(false)
        picker:SetTall(200)

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
    end
end