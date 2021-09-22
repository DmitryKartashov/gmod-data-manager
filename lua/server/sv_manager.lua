--[[----------------------------------------------------------------------------
	Этот файл отвечает только за вызов всех методов.
	Cохраняет данные в SQLite БД: garrysmod\cv.db
	

---------------------------------------------------------------------------------]]

if not SERVER then return end
print ("[data-manager] ON")

createrDb:Create()
hook.Add("PlayerInitialSpawn", "dm_init_player", DM_init_player )

print ("[data-manager] OFF")