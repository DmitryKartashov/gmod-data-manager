--[[----------------------------------------------------------------------------
	Подгрузка файлов data-manager.
	Порядок загрузки файлов не менять, если жизнь дорога.
	

---------------------------------------------------------------------------------]]

if (SERVER) then
	print('/data-manager SERVER SIDE started/')
	include('server/sv_1_config.lua')                 -- Базовые настройки.
	include('server/sv_2_database.lua')               -- Интеграция с БД.


	--include('server/sv_3_type_loaders.lua')           -- Загрузчики разных типов type (определения базовых функций)
	--include('server/sv_3-1_custom_type_loaders.lua')  -- Кастомные. Здесь определяйте свои по шаблону.
	

	include('server/sv_4_place_loaders.lua')     -- Загрузчики разных типов place (определения базовых функций).
	include('server/sv_4-1_custom_place_loaders.lua') -- Кастомные. Здесь определяйте свои по шаблону.


	include('server/sv_5_common_loaders.lua')         -- Обобщенные загрузчики. Объединяют place и type.
	include('server/sv_6_hook_api.lua')               -- Интерфейсы, которые используют Хуки.
	include('server/sv_7_manager.lua')                -- Здесь все собирается воедино.
elseif (CLIENT) then
	print('/data-manager CLIENT SIDE started/')
else
	print('/data-manager SHARED SIDE started/')
end