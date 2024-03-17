--[[

Copyright (c) 2024, Neil J. Tan
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--]]

local function readData(filename)
    return json.decode(LoadResourceFile(GetCurrentResourceName(), filename))
end

local function writeData(filename, data)
    return 1 == SaveResourceFile(GetCurrentResourceName(), filename, json.encode(data), -1)
end

local locationsDataFileName <const> = "locationsData.json"

local locations = readData(locationsDataFileName) or {}

local function notifyPlayer(source, msg)
    TriggerClientEvent("chat:addMessage", source, {
        color = {255, 0, 0},
        multiline = true,
        args = {"[teleport:server]", msg}
    })
end

local function saveLocations()
    if false == writeData(locationsDataFileName, locations) then
        notifyPlayer(source, "saveLocations: Error writing file '" .. locationsDataFileName .. "'\n")
    end
end

RegisterNetEvent("teleport:add")
AddEventHandler("teleport:add", function(name, coord)
    local source = source
    if nil == name or nil == coord then
        notifyPlayer(source, "Invalid parameters.\n")
    elseif locations[name] ~= nil then
        notifyPlayer(source, "Location '" .. name .. "' already exists.\n")
    else
        locations[name] = coord
        saveLocations()
        notifyPlayer(source, "Location '" .. name .. "' added.\n")
    end
end)

RegisterNetEvent("teleport:del")
AddEventHandler("teleport:del", function(name)
    local source = source
    if nil == name then
        notifyPlayer(source, "Name required.\n")
    elseif nil == locations[name] then
        notifyPlayer(source, "Location '" .. name .. "' does not exist.\n")
    else
        locations[name] = nil
        saveLocations()
        notifyPlayer(source, "Location '" .. name .. "' deleted.\n")
    end
end)

RegisterNetEvent("teleport:lst")
AddEventHandler("teleport:lst", function()
    local source = source
    local names = {}
    for name in pairs(locations) do
        names[#names + 1] = name
    end
    if 0 == #names then
        notifyPlayer(source, "No locations saved.\n")
    else
        table.sort(names)
        local msg = ""
        for _, name in pairs(names) do
            local coord = locations[name]
            msg = msg .. ("%s : %f, %f, %f\n"):format(name, coord.x, coord.y, coord.z)
        end
        notifyPlayer(source, msg)
    end
end)

RegisterNetEvent("teleport:tp")
AddEventHandler("teleport:tp", function(name)
    local source = source
    if nil == name then
        notifyPlayer(source, "Name required.\n")
    else
        local coord = locations[name]
        if nil == coord then
            notifyPlayer(source, "Location '" .. name .. "' does not exist.\n")
        else
            TriggerClientEvent("teleport:tp", source, coord.x, coord.y, coord.z)
        end
    end
end)
