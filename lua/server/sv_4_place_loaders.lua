--[[------------------------------------------------------------------------
	Модуль с определением различных значений dm_place.place_name
	и логикой загрузки в БД и выгрузки из БД предметов собственности
	игроков с заданым значением поля dm_place.place_name.

	Например:
		dm_place.place_name = 'банк'
		Значит, что в этом файле определена логика для загрузки и выгрузки
		любых предметов из банка. Эту логику вы определяете сами.

---------------------------------------------------------------------------]]



function dm_new_Place(place_name, place_types, give_foo, save_foo)
	--[[
		Создает объект класса Place.
		Аргументы:
			place_name: string
				Имя места
			
			place_types: table
				Список type тех предметов, которые может хранить это место.
				Пример:
					{'armor', 'health'}

			give_foo: function
				Функция загрузки проедметов в БД, 
				если их dm_place.place_name == name.

				Аргументы функции:

				Возвращаемое значение:

			save_foo: function
				При вызове этой функции, place (хранилище), должно
				сообщить данные о местоположении всех его предметов,
				которые принадлежат указанному игроку.
				Пример:
					{}

				Аргументы функции:

				Возвращаемое значение:
	]]
	local default_foo = nil
	local new_place = {
		['place_name'] = place_name,
		['place_types'] = place_types
		['give_foo'] = not give_foo and default_foo or give_foo,
		['save_foo'] = not save_foo and default_foo or save_foo
	}
	loaderDb:add_place(place_name, place_types)
	return new_place
end


