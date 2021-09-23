


local function dm_save_all_in_place(place)
	if not place.save_foo then -- Если хранилище встроенное
		for k1, type_name in pairs(place.place_types) do
			local type_data = {}
			t = dm_find_Type(type_name)
			if t != nil then -- Если такой type существует
				for k2, val in pairs(t.values_tbl) do
					type_data[val_name] = val.save_foo(ply)
				end
			end

			loaderDb:add_item(ply:SteamID64(),  
								place.place_name,
								type.type_name,
								nil,
								type_data)
		end
	else
		-- тут придумать, что делать, если хранилище кастомное
	end 
end



function dm_common_save(ply)
	local data = {}
	for k, place in pairs(dm_PLACES) do
		dm_save_all_in_place(place)
	end

end


function dm_common_give(ply)
end