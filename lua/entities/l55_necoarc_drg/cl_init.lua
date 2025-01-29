include('shared.lua')

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

net.Receive('dhzz_neco_arc_request_preset', function()
    local necoArc = net.ReadEntity()
    if not necoArc:IsValid() then return end

    local group = table.Copy(presets.GetTable('neco_arc_colorizer'))

    -- Add default preset
    local defaultGroup = {}

    for name, color in pairs(defaultColors) do
        local presetKeyName = 'neco_arc_colorizer_' .. name:lower()

        defaultGroup[presetKeyName .. '_r'] = color.r
        defaultGroup[presetKeyName .. '_g'] = color.g
        defaultGroup[presetKeyName .. '_b'] = color.b
    end

    group.Default = defaultGroup

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
    net.WriteEntity(necoArc)
    net.WriteString(util.TableToJSON(list))
    net.SendToServer()
end)