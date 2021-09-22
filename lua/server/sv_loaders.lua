--[[----------------------------------------------------------------------------
	Здесь находятся функции, в которых инкапсулируется логика загрузки и
	выгрузки данных из базы данных к пользователю и наоборот.
	Самыми сажными здесь являются функции блока DM_, которые вызываются
	непосредственно в хуках.
	Функции блока dm_ вызываются внутри функций DM_ и не являются интерфейсными.
	

---------------------------------------------------------------------------------]]


local plyMeta = FindMetaTable("Player")




function plyMeta:dm_LoadData()
	--[[
	Возвращает таблицу с данными об игроке. Если таковой еще нет, то создает и записывает
	ее в соответствующий json.
	Вызывается при следующих событиях: 
			<PlayerInitialSpawn>
	Возвращает:
		nil - если такого игрока еще не было
		table - если игрок был
	]]
	local steam_id64 = self:SteamID64()
	local data = {}

	if not loaderDb:gamer_exists(steam_id64) then
		loaderDb:add_gamer(steam_id64)
		return nil
	end
	
	data = loaderDb:get_gamers_items(steam_id64)

	return data
end

function DM_init_player(ply) 
	local data = ply:dm_LoadData()
end

