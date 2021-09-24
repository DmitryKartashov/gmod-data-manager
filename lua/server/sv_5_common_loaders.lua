


-- local function dm_save_all_in_place(place)
-- 	if not place.save_foo then -- Если хранилище встроенное
-- 		for k1, type_name in pairs(place.place_types) do
-- 			local type_data = {}
-- 			t = dm_find_Type(type_name)
-- 			if t != nil then -- Если такой type существует
-- 				for k2, val in pairs(t.values_tbl) do
-- 					type_data[val_name] = val.save_foo(ply)
-- 				end
-- 			end

-- 			loaderDb:add_item(ply:SteamID64(),  
-- 								place.place_name,
-- 								type.type_name,
-- 								nil,
-- 								type_data)
-- 		end
-- 	else
-- 		-- тут придумать, что делать, если хранилище кастомное
-- 	end 
-- end



function dm_common_save(ply)
	--[[
		Проходит по всем определенным местам, собирает у каждого
		все данные об игроке и сохраняет в БД.
	]]

	for k, place in pairs(dm_PLACES) do
		COMMON_SAVE(ply, place)
	end
	dm_debug('КОЛИЧЕСТВО ОБЪЕКТОВ У ИГРОКА: ' .. loaderDb:get_gamers_items_amount(ply:SteamID64()))
end


function dm_common_give(ply)
	--[[
		Проходит по всем определенным местам, 
	]]
	for k, place in pairs(dm_PLACES) do
		dm_debug('dm_common_give: place' .. tostring(place))
		dm_debug('dm_common_give: place_name' .. tostring(place_name))
		COMMON_GIVE(ply, place)
		
	end
end