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

local function notifyPlayer(msg)
    TriggerEvent("chat:addMessage", {
        color = {255, 0, 0},
        multiline = true,
        args = {"[teleport:client]", msg}
    })
end

local function show()
    local coord = GetEntityCoords(PlayerPedId())
    notifyPlayer(coord.x .. ", " .. coord.y .. ", " .. coord.z)
end

local function add(name)
    if nil == name then
        notifyPlayer("Name required.\n")
    else
        TriggerServerEvent("teleport:add", name, GetEntityCoords(PlayerPedId()))
    end
end

local function del(name)
    if nil == name then
        notifyPlayer("Name required.\n")
    else
        TriggerServerEvent("teleport:del", name)
    end
end

local function lst()
    TriggerServerEvent("teleport:lst")
end

local function to(x, y, z)
    x = tonumber(x)
    y = tonumber(y)
    z = tonumber(z)
    if fail == x or fail == y or fail == z then
        notifyPlayer("Invalid parameters.\n")
    else
        SetEntityCoords(PlayerPedId(), x * 1.0, y * 1.0, z * 1.0, false, false, false, true)
    end
end

local function wp()
    if false == IsWaypointActive() then
        notifyPlayer("Waypoint not set on waypoint map.\n")
    else
        local coord = GetBlipCoords(GetFirstBlipInfoId(8))
        for height = 1000.0, 0.0, -50.0 do
            RequestAdditionalCollisionAtCoord(coord.x, coord.y, height)
            Citizen.Wait(0)
            local foundZ, groundZ = GetGroundZFor_3dCoord(coord.x, coord.y, height, true)
            if 1 == foundZ then
                to(coord.x, coord.y, groundZ + 1.0)
                return
            end
        end
        notifyPlayer("Could not teleport to waypoint set on waypoint map.\n")
    end
end

local function tp(name)
    if nil == name then
        notifyPlayer("Name required.\n")
    else
        TriggerServerEvent("teleport:tp", name)
    end
end

RegisterCommand("tp", function(_, args)
    if nil == args[1] then
        notifyPlayer(
            "\n" ..
            "Commands:\n" ..
            "Required arguments are in square brackets.\n" ..
            "/tp - display list of available /tp commands\n" ..
            "/tp show - show current coordinates\n" ..
            "/tp add [name] - add current coordinates as location named [name]\n" ..
            "/tp del [name] - delete location named [name]\n" ..
            "/tp lst - list all saved locations\n" ..
            "/tp to [x] [y] [z] - teleport to coordinates [x], [y], [z]\n" ..
            "/tp wp - teleport to waypoint set on waypoint map\n" ..
            "/tp [name] - teleport to location named [name]\n"
        )
    elseif "show" == args[1] then
        show()
    elseif "add" == args[1] then
        add(args[2])
    elseif "del" == args[1] then
        del(args[2])
    elseif "lst" == args[1] then
        lst()
    elseif "to" == args[1] then
        to(args[2], args[3], args[4])
    elseif "wp" == args[1] then
        wp()
    else
        tp(args[1])
    end
end)

RegisterNetEvent("teleport:tp")
AddEventHandler("teleport:tp", function(coord)
    to(coord.x, coord.y, coord.z)
end)
