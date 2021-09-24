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



function DM_save_player(ply)
	--[[

	]]
	if not ply:Alive() then return nil end
	dm_common_save(ply)
end

function DM_save_ShutDown()
	for k,ply in pairs(player.GetAll()) do
		DM_save_player(ply)
	end
	if dm_CONFIG.print then
		print("[data-manager] АВТОСОХРАНЕНИЕ ПРИ НЕПОЛАДКЕ.")
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
	if dm_CONFIG.print then
		print("[data-manager] АВТОСОХРАНЕНИЕ")
	end
end

--[[----------------------------------------------------
				ДЛЯ ВЫГРУЗКИ ДАННЫХ
------------------------------------------------------]]


function DM_init_player(ply) 
	local steam_id64 = ply:SteamID64()

	if not loaderDb:gamer_exists(steam_id64) then
		loaderDb:add_gamer(steam_id64)
		return nil
	end
	
	dm_common_give(ply)
end

