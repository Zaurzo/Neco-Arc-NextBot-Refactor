include('shared.lua')

local defaultPreset = {}

local defaultColors = {
    Eyes = Color(255, 255, 255),
    Shirt = Color(255, 255, 255),
    Pupils = Color(180, 0, 0),
    Legs = Color(0, 0, 0),
    Skirt = Color(107, 57, 91),
    Ears = Color(237, 156, 155),
    Hair = Color(235, 187, 123),
    Tail = Color(235, 187, 123),
    Skin = Color(240, 215 ,192)
}

local spawnWithPreset = CreateConVar(
    'dhzz_neco_arc_preset_spawn', 
    '0', 
    FCVAR_ARCHIVE,
    "Determines whether or not Neco Arc's you spawn will have a random preset you created with the Neco Arc Colorizer tool."
)

for name, color in pairs(defaultColors) do
    local presetKeyName = 'neco_arc_colorizer_' .. name:lower()

    defaultPreset[presetKeyName .. '_r'] = color.r
    defaultPreset[presetKeyName .. '_g'] = color.g
    defaultPreset[presetKeyName .. '_b'] = color.b
end

function ENT:CustomInitialize()
    if not spawnWithPreset:GetBool() then return end

    local group = table.Copy(presets.GetTable('neco_arc_colorizer'))

    group.Default = defaultPreset

    local preset = table.Random(group)
    local list = {}

    for keyName in pairs(defaultColors) do
        local presetKeyName = 'neco_arc_colorizer_' .. keyName:lower()

        local r = preset[presetKeyName .. '_r'] 
        local g = preset[presetKeyName .. '_g'] 
        local b = preset[presetKeyName .. '_b'] 

        list[keyName] = Color(r, g, b):ToVector()
    end 

    net.Start('dhzz_neco_arc_request_preset')
    net.WriteEntity(self)
    net.WriteString(util.TableToJSON(list))
    net.SendToServer()
end