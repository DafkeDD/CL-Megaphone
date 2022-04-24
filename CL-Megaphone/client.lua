local QBCore = exports['qb-core']:GetCoreObject()

PlayerJob = {}

local AnimFinished = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

AddEventHandler('onClientResourceStart',function()
    Citizen.CreateThread(function()
        while true do
            if QBCore ~= nil and QBCore.Functions.GetPlayerData ~= nil then
                QBCore.Functions.GetPlayerData(function(PlayerData)
                    if PlayerData.job then
                        PlayerJob = PlayerData.job
                    end
                end)
                break
            end
        end
        Citizen.Wait(1)
    end)
end)

RegisterNetEvent("CL-Megaphone:Use", function()
    if PlayerJob.name == 'police' then
        local MegaphoneMenu = {
            {
                header = "Options",
                isMenuHeader = true,
            }
        }
        for k, v in pairs(Config.MegaphoneOptions) do
            MegaphoneMenu[#MegaphoneMenu+1] = {
                header = v.optionname,
                txt = "Play: "..v.optionname,
                params = {
                    event = "CL-BoatShop:PlaySound",
                    args = {
                        sound = v.sound,
                        optionname = v.optionname,
                    }
                }
            }
        end
        MegaphoneMenu[#MegaphoneMenu+1] = {
            header = "⬅ Close",
            params = {
                event = "qb-menu:client:closeMenu",
            }
        }
        exports['qb-menu']:openMenu(MegaphoneMenu)
    else
        QBCore.Functions.Notify("You are not a police officer.", "error")
    end
end)

RegisterNetEvent('CL-Megaphone:PlayWithinDistance')
AddEventHandler('CL-Megaphone:PlayWithinDistance', function(playerNetId, maxDistance, soundFile, soundVolume)
    local lCoords = GetEntityCoords(GetPlayerPed(-1))
    local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
    local distIs  = Vdist(lCoords.x, lCoords.y, lCoords.z, eCoords.x, eCoords.y, eCoords.z)
    if(distIs <= maxDistance) then
        SendNUIMessage({
            transactionType     = 'playSound',
            transactionFile     = soundFile,
            transactionVolume   = soundVolume
        })
    end
end)

RegisterNetEvent("CL-BoatShop:PlaySound", function(data)
    AnimFinished = false
    TriggerEvent("CL-Megaphone:PlayWithinDistance", source, 20.0, data.sound, 10.0)
    SpawnMegaphone()
    QBCore.Functions.Progressbar('playingsound_'..data.optionname, 'Playing ' ..data.optionname .. '...', 3000, false, true, {
        disableMovement = false,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'amb@world_human_mobile_film_shocking@female@base',
        anim = 'base',
        flags = 49,
    }, {}, {}, function() 
        AnimFinished = true 
        Wait(100)
        AnimFinished = false
    end, function()
        ClearPedTasks(PlayerPedId())
    end)
end)

function SpawnMegaphone()
    LoadModel('prop_megaphone_01')
    local Megaphone = CreateObject(GetHashKey('prop_megaphone_01'), GetEntityCoords(PlayerPedId()), true)
	local PedCoords = GetEntityCoords(PlayerPedId())
	local MegaPhoneObject = GetClosestObjectOfType(PedCoords, 2.0, GetHashKey("prop_megaphone_01"), false)
	AttachEntityToEntity(MegaPhoneObject, GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),0.0, 0.0, 0.0, 0.0, 0.0, 80.0,1,1,0,1,0,1)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5)
            if AnimFinished == true then
                DetachEntity(MegaPhoneObject, true, true)
                DeleteObject(MegaPhoneObject)
                break
            end
            Citizen.Wait(1)
        end
    end)
end

function LoadModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Wait(10)
	end
end