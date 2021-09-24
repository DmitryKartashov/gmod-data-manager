--[[----------------------------------------------------------------------------
	Этот файл отвечает только за вызов всех методов.
	Cохраняет данные в SQLite БД: garrysmod\cv.db
	

---------------------------------------------------------------------------------]]

if not SERVER then return end
print ("[data-manager] ON")


hook.Add("PlayerInitialSpawn", "dm_init_player", DM_init_player)
hook.Add("PlayerDisconnected", "dm_save_player", DM_save_player)
hook.Add("ShutDown", "ShutDownSaveThings", DM_save_ShutDown)

timer.Create("dm_SaveDataAuto", dm_CONFIG.auto_time, 0, DM_save_Auto)

print ("[data-manager] OFF")