--[[------------------------------------------------------------------------
	Модуль с определением различных значений dm_place.place_name
	и логикой загрузки в БД и выгрузки из БД предметов собственности
	игроков с заданым значением поля dm_place.place_name.

	Например:
		dm_place.place_name = 'банк'
		Значит, что в этом файле определена логика для загрузки и выгрузки
		любых предметов из банка. Эту логику вы определяете сами.

---------------------------------------------------------------------------]]


dm_PLACES = {}



function create_Place(place_name, API_function_tbl)
	--[[
		Создает объект класса Place.
		Аргументы:
			place_name: string
				Имя места
			API_function_tbl: table
				Содержит две функции:
					give_foo(ply): function
						Данная функция вызывается при выгрузке из БД data-manager.
						Если их dm_place.place_name == name.

						Аргументы функции:

						Возвращаемое значение:

					save_foo(ply): function
						Данная функция вызывается при сохранении данных в БД data-manager.
						Возвращает список предметов данного игрока в этом хранилище.
						
						Аргументы функции:

						Возвращаемое значение:
	]]
	local default_foo = nil
	local new_place = {
		['place_name'] = place_name,
		['give_foo'] = not API_function_tbl.give_foo and default_foo or API_function_tbl.give_foo,
		['save_foo'] = not API_function_tbl.save_foo and default_foo or API_function_tbl.save_foo
	}

	dm_PLACES[place_name] = new_place
	loaderDb:add_place(place_name)
end

function COMMON_SAVE(ply, place)
	local steam_id64 = ply:SteamID64()
	local place_name = place.place_name
	local data_to_save = place.save_foo(ply)
	
	loaderDb:delete_items(steam_id64, place_name)
	for _, item_data in pairs(data_to_save) do
		loaderDb:add_item(tostring(steam_id64), place_name, item_data)
	end
end

function COMMON_GIVE(ply, place)
	local steam_id64 = ply:SteamID64()
	local place_name = place.place_name
	local data_to_give = loaderDb:get_gamers_items(tostring(steam_id64), place_name)
	dm_debug('COMMON_GIVE: place' .. tostring(place))
	dm_debug('COMMON_GIVE: place_name' .. tostring(place_name))
	
	for _, item_data in pairs(data_to_give) do
		place.give_foo(ply, item_data)
	end
	loaderDb:delete_items(steam_id64, place_name)
end