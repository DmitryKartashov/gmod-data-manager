--[[----------------------------------------------------------------------------
	Подгрузка файлов data-manager.
	Порядок загрузки файлов не менять, если жизнь дорога.
	

---------------------------------------------------------------------------------]]

if (SERVER) then
	print('/data-manager SERVER SIDE started/')
	include('server/sv_config.lua')
	include('server/sv_database.lua')
	include('server/sv_loaders.lua')
	include('server/sv_manager.lua')
elseif (CLIENT) then
	print('/data-manager CLIENT SIDE started/')
else
	print('/data-manager SHARED SIDE started/')
end