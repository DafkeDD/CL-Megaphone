local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('megaphone' , function(source, item)
    local src = source
    TriggerClientEvent("CL-Megaphone:Use", src)          
end)