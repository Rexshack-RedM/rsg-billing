local RSGCore = exports['rsg-core']:GetCoreObject()
local jobcheck = false

-- billing menu
RegisterNetEvent('rsg-billing:client:billingMenu', function()
    local PlayerId = GetPlayerServerId(PlayerId())
    local BillsOptions = {
        {
            header = 'Billing Menu',
            isMenuHeader = true,
            icon = 'fas fa-file-invoice-dollar',
        },
        {
            header = 'Send Bill',
            icon = 'fas fa-dollar-sign',
            txt    = '',
            params = { event = 'rsg-billing:client:billplayer' }
        },
        {
            header = 'View Your Bills',
            icon = 'fas fa-dollar-sign',
            txt    = '',
            params = { event = 'rsg-billing:client:checkbills' }
        },
        {
            header = 'Delete Sent Bill (WIP)',
            icon = 'fas fa-dollar-sign',
            txt    = '',
            params = { event = 'rsg-billing:client:deletebills' }
        },
        {
            header = 'close',
            icon   = 'fa-solid fa-circle-xmark',
            txt    = '',
            params = { event = 'rsg-menu:closeMenu', }
        },
    }
    exports['rsg-menu']:openMenu(BillsOptions)
end)

-- send bill to player (client:billplayer)
RegisterNetEvent('rsg-billing:client:billplayer', function()
    local dialog = exports['rsg-input']:ShowInput({
    header = "Create Bill",
    submitText = "Send Bill",
        inputs = {
            {
                text = "PlayerID",
                name = "playerid",
                type = "number",
                isRequired = false,
            },
            {
                text = "Bill Price ($)",
                name = "billprice",
                type = "number",
                isRequired = false,
            },
            {
                text = "Bill Type",
                name = "billtype",
                type = "radio",
                options = {
                    { value = "player", text = "Bill as Player" },
                    { value = "society", text = "Bill as Society" },
                },
            },
        }
    })
    if dialog == nil then return end
    if dialog == "" then return RSGCore.Functions.Notify("you didn't write anything", 'error') end
    if dialog.playerid == "" then return RSGCore.Functions.Notify("you didn't write the player id", 'error') end
    if dialog.billprice == "" then return RSGCore.Functions.Notify("you didn't write the bill price", 'error') end
    if dialog.billtype == 'society' then
        local playerjob = RSGCore.Functions.GetPlayerData().job.name
        jobcheck = false
        for _, name in pairs(Config.VerifySociety) do
            if name == playerjob then
                jobcheck = true
            end
        end
        if jobcheck == true then
            TriggerServerEvent('rsg-billing:server:sendSocietyBill', dialog.playerid, dialog.billprice, playerjob)    
        else
            RSGCore.Functions.Notify('you are not part of a society!', 'error')
        end
    end
    if dialog.billtype == 'player' then
        TriggerServerEvent('rsg-billing:server:sendPlayerBill', dialog.playerid, dialog.billprice)
    end
end, false)

-- check bills with callback (client:checkbills)
RegisterNetEvent('rsg-billing:client:checkbills', function()
    local PlayerId = GetPlayerServerId(PlayerId())
    RSGCore.Functions.TriggerCallback('rsg-billing:server:checkbills', function(bills, cid)
        local BillsShow = {
            {
                header = 'Unpaid Bills | ID: ' .. PlayerId,
                isMenuHeader = true,
                icon = 'fas fa-file-invoice-dollar',
            },
            {
                header = 'Citizen ID: ' .. cid,
                isMenuHeader = true,
                icon = 'fas fa-id-card-clip',
            },
        }
        
        for _, v in ipairs(bills) do
            BillsShow[#BillsShow + 1] = {
                header = 'Amount: ' .. v.amount .. '$',
                icon = 'fas fa-dollar-sign',
                txt = 'Sender: ' .. v.sender .. ' | From: ' .. v.society,
                params = { event = 'rsg-billing:server:paybills', 
                    isServer = true,
                    args = {
                        sender = v.sender, 
                        amount = v.amount, 
                        billid = v.id, 
                        society = v.society,
                        citizenid = v.citizenid,
                        sendercitizenid = v.sendercitizenid
                    } 
                }
            }
        end

        BillsShow[#BillsShow + 1] = {
            header = 'Close',
            icon   = 'fa-solid fa-circle-xmark',
            txt    = '',
            params = { event = 'rsg-menu:closeMenu', }
        }

        exports['rsg-menu']:openMenu(BillsShow)
    end, PlayerId)
end)
