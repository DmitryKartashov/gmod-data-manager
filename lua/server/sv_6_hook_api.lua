--[[----------------------------------------------------------------------------
	Здесь находятся функции, в которых инкапсулируется логика загрузки и
	выгрузки данных из базы данных к пользователю и наоборот.
	Самыми сажными здесь являются функции блока DM_, которые вызываются
	непосредственно в хуках.
	Функции блока dm_ вызываются внутри функций DM_ и не являются интерфейсными.
	

---------------------------------------------------------------------------------]]


--[[----------------------------------------------------
				ВАЖНЫЕ ПЕРЕМЕННЫЕ
------------------------------------------------------]]

local plyMeta = FindMetaTable("Player")



--[[----------------------------------------------------
				ДЛЯ СОХРАНЕНИЯ
------------------------------------------------------]]


function plyMeta:dm_SaveData()
	--[[

	]]
	if not self:Alive() then return nil end
	dm_common_save(self)
end

function DM_save_player(ply)
	ply:dm_SaveData()
end

function DM_save_ShutDown()
	for k,ply in pairs(player.GetAll()) do
		DM_save_player(ply)
	end
	if CONFIG.print then
		print("[data-manager] ПРОИЗОШЕЛ СБОЙ, НО ВАШИ ДАННЫЕ В БЕЗОПАСНОСТИ.")
	end
end

function DM_save_Auto() 
	local time = 0
	for k,ply in pairs(player.GetAll()) do
		timer.Simple(time, function() 
			DM_save_player(ply)
		end)
		time = time+0.5
	end
	if CONFIG.print then
		print("[data-manager] ВАШИ ДАННЫЕ В БЕЗОПАСНОСТИ")
	end
end

--[[----------------------------------------------------
				ДЛЯ ВЫГРУЗКИ ДАННЫХ
------------------------------------------------------]]
function plyMeta:dm_LoadData()
	--[[
	Возвращает таблицу со всем имуществом игрока. 
	Если данного игрока в базе еще нет, то он добавляется.
	Возвращает:
		nil - если такого игрока еще не было
		table - если игрок был
	]]
	local steam_id64 = self:SteamID64()

	if not loaderDb:gamer_exists(steam_id64) then
		loaderDb:add_gamer(steam_id64)
		return nil
	end
	
	return loaderDb:get_gamers_items(steam_id64)
end

function plyMeta:dm_GiveData(data)
	--[[
		нужно дождаться, когда же тут появится информация
		Для этого нужно реализовать сохранение данных
	]]
end

function DM_init_player(ply) 
	local data = ply:dm_LoadData()
	ply:dm_GiveData(data)
end

