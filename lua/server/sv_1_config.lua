--[[----------------------------------------------------------------------------
	Здесь находятся основные настройки дата-менеджера.
	

---------------------------------------------------------------------------------]]

local default_team = TEAM_HOBO

dm_CONFIG = {}
dm_CONFIG.saveweapons = true -- true if you want to save the player's weapons ans false if you don't
dm_CONFIG.saveteam = true	-- true if you want to save the player's team and false if you don't
dm_CONFIG.savepos = false -- true if you want to save the player's pos and false if you don't
dm_CONFIG.savemodel = dm_CONFIG.saveteam  -- true if you want to save the player's model and false if you don't
dm_CONFIG.savehealth = true -- true if you want to save the player's health and false if you don't
dm_CONFIG.savearmor = true -- true if you want to save the player's armor and false if you don't
dm_CONFIG.teams = {default_team} --team that doesn't use the save spawn/weapon/team
dm_CONFIG.auto_time = 20 --Time between each auto saves (IN SECONDS)
dm_CONFIG.print = true -- Print a message in the console when the server as saved the player's data
dm_CONFIG.dontsavedamage = false -- If the player will not save anything after being damaged (cooldown in Seconds)
dm_CONFIG.dontsavecooldown = 10 -- see above, it's the cooldown when he will be able to disconnect and has is data saved
dm_CONFIG.cooldownfinish = "Вы можете выйти с сервера." -- sentence when the cooldown is finish
dm_CONFIG.cooldownstart = "Не выходите ещё "..dm_CONFIG.dontsavecooldown.." секунд. Ваши данные сохраняются." -- sentence when the cooldown starts

dm_CONFIG.save_team_time = 600 -- время в секундах, на которое сохраняется ваша профессия после выхода из сервера
dm_CONFIG.save_model_time = dm_CONFIG.save_team_time
dm_CONFIG.save_weapons_time = dm_CONFIG.save_team_time