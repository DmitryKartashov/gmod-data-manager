--------------------------------ПУТЬ---------------------------------------------
--save-to-save\lua\autorun\server
--сохраняет данные в: garrysmod\data\save_module\
---------------------------------------------------------------------------------
print ("[save-to-save] ON")
if not SERVER then return end

local default_team = TEAM_HOBO

CONFIG = {}
CONFIG.saveweapons = true -- true if you want to save the player's weapons ans false if you don't
CONFIG.saveteam = true	-- true if you want to save the player's team and false if you don't
CONFIG.savepos = false -- true if you want to save the player's pos and false if you don't
CONFIG.savemodel = CONFIG.saveteam  -- true if you want to save the player's model and false if you don't
CONFIG.savehealth = true -- true if you want to save the player's health and false if you don't
CONFIG.savearmor = true -- true if you want to save the player's armor and false if you don't
CONFIG.teams = {default_team} --team that doesn't use the save spawn/weapon/team
CONFIG.auto_time = 20 --Time between each auto saves (IN SECONDS)
CONFIG.print = true -- Print a message in the console when the server as saved the player's data
CONFIG.dontsavedamage = false -- If the player will not save anything after being damaged (cooldown in Seconds)
CONFIG.dontsavecooldown = 10 -- see above, it's the cooldown when he will be able to disconnect and has is data saved
CONFIG.cooldownfinish = "Вы можете выйти с сервера." -- sentence when the cooldown is finish
CONFIG.cooldownstart = "Не выходите ещё "..CONFIG.dontsavecooldown.." секунд. Ваши данные сохраняются." -- sentence when the cooldown starts

CONFIG.save_team_time = 600 -- время в секундах, на которое сохраняется ваша профессия после выхода из сервера
CONFIG.save_model_time = CONFIG.save_team_time
CONFIG.save_weapons_time = CONFIG.save_team_time


local plyMeta = FindMetaTable("Player")

local function checkTime(lasttime, delta)
	return (os.time() - lasttime) < delta
end

function plyMeta:LoadThings()
	--[[
	Возвращает таблицу с данными об игроке. Если таковой еще нет, то создает и записывает
	ее в соответствующий json.
	Вызывается при следующих событиях: 
			<PlayerInitialSpawn>
	]]
	local read = file.Read( "save_module/"..string.lower(game.GetMap()).."/" .. self:SteamID64() .. ".txt", "DATA" )
	if not file.Exists( "save_module", "DATA" ) then file.CreateDir( "save_module", "DATA" ) return end
	if not file.Exists("save_module/"..string.lower(game.GetMap()),"DATA") then file.CreateDir( "save_module/"..string.lower(game.GetMap()), "DATA" ) end
	if not file.Exists("save_module/"..string.lower(game.GetMap()).."/"..self:SteamID64()..".txt", "DATA") then 
		local data = {sys_time = os.time(),
						pos = Vector(0,0,0), 
						team = default_team, 
						weapon = {""}}
		file.Write("save_module/"..string.lower(game.GetMap()).."/"..self:SteamID64()..".txt", util.TableToJSON(data) )  return 
	end
	local things = util.JSONToTable(read)
	return things
end 

function plyMeta:SaveThings()
	--[[
	Перезаписывает данные пользователя в соответствующем ему json файле.
	Вызывается при следующих событиях:
			<PlayerDisconnected>	при отсоединении пользователя
			<ShutDown>				при неполадках на сервере
			<SaveThingsAuto>		автоматически при срабатывании этого таймера
	]]
	if not self:Alive() then return end
	if not file.Exists( "save_module", "DATA" ) then file.CreateDir( "save_module", "DATA" ) end
	if not file.Exists("save_module/"..string.lower(game.GetMap()),"DATA") then file.CreateDir( "save_module/"..string.lower(game.GetMap()), "DATA" ) end
	local weapondata ={}
	local ammodata = {}
	local datapos, datateam, datamodel, dataarmor, datahealth
	if CONFIG.saveweapons then 
		for k,v in ipairs(self:GetWeapons()) do
				table.insert(weapondata,k, v:GetClass())

				if v:GetPrimaryAmmoType() != -1 then
					if ammodata[v:GetPrimaryAmmoType()] then 
						if ammodata[v:GetPrimaryAmmoType()].ammotype then
							if ammodata[v:GetPrimaryAmmoType()].ammotype == v:GetPrimaryAmmoType() then continue end
						end
					end
					table.insert(ammodata,v:GetPrimaryAmmoType(), {ammotype = v:GetPrimaryAmmoType(), 
																   ammonum = self:GetAmmoCount(v:GetPrimaryAmmoType())})
				end
		end
	end
		if CONFIG.savepos then datapos = self:GetPos() end
		if CONFIG.savemodel then datamodel = self:GetModel() end
		if CONFIG.saveteam then datateam = self:Team() end
		if CONFIG.savehealth then datahealth = {hp = self:Health(),maxhp = self:GetMaxHealth()} end
		if CONFIG.savearmor then dataarmor = self:Armor() end
	local data = {sys_time = os.time(),
					pos = datapos, 
					team = datateam, 
					weapon = weapondata, 
					ammo = ammodata, 
					model = datamodel, 
					health = datahealth, 
					armor = dataarmor}

	if self:GetNWBool("savecooldown") then data = {"no"} end

		file.Write("save_module/"..string.lower(game.GetMap()).."/"..self:SteamID64()..".txt", util.TableToJSON(data) )  
end

hook.Add("PlayerDisconnected", "savethings", function(ply)
	ply:SaveThings()

end)

hook.Add("ShutDown", "ShutDownSaveThings", function()

	for k,v in pairs(player.GetAll()) do
		v:SaveThings()
	end
	if CONFIG.print then
		print("[save-to-save] Произошел сбой, но данные в безопасности.")
	end

end)

hook.Add("PlayerInitialSpawn", "loadthings", function(ply)

		local data = ply:LoadThings()
		if not data then return end
		if data == "no" then return end
	if table.HasValue(CONFIG.teams, data.team) then return end

		timer.Simple(1, function()
			if CONFIG.saveteam  then
				if checkTime(data.sys_time, CONFIG.save_team_time) then
					ply:changeTeam(data.team, True)
					--ply:SetTeam(data.team)
					--ply:ConCommand("say /job "..team.GetName(data.team)) --ALL_JOBS[data.team]['command'])
					ply:Spawn()
				end
			end

			if CONFIG.savepos  then
				ply:SetPos(data.pos)
			end

			if CONFIG.saveweapons  then
				if checkTime(data.sys_time, CONFIG.save_weapons_time) then
					if data.weapon then
					 for k,v in pairs(data.weapon) do
					 	--if v:GetPrimaryAmmoType() != -1 then
					 	--	v:SetClip1(3)
					 	--end
		 				ply:Give(v)
					 end
					 for k,v in pairs(data.ammo) do
					 		ply:SetAmmo(v.ammonum,v.ammotype)		
					 end
					end
				end
			end

			if CONFIG.savemodel  then
				if checkTime(data.sys_time, CONFIG.save_model_time) then
					ply:SetModel(data.model)
				end
			end

			if CONFIG.savehealth  then
				ply:SetMaxHealth(data.health.maxhp)
				ply:SetHealth(data.health.hp)
			end

			if CONFIG.savearmor then
				ply:SetArmor(data.armor)
			end
		end)
end)

hook.Add("EntityTakeDamage", "DontSaveWhenDamage", function(target, damage)
	if !CONFIG.dontsavedamage then return end
	if !target:IsPlayer() then return end
	if damage:GetAttacker() == target then return end
	if not (damage:GetAttacker():IsNPC() or damage:GetAttacker():IsPlayer()) then return end
		if target:GetNWBool("savecooldown", false) then 
				timer.Adjust("savecooldown"..target:UniqueID(), CONFIG.dontsavecooldown, 1, function() if IsValid(target) then target:PrintMessage(HUD_PRINTTALK,CONFIG.cooldownfinish) target:SetNWBool("savecooldown", false) end end)
		else
			target:SetNWBool("savecooldown", true)
			target:PrintMessage(HUD_PRINTTALK,CONFIG.cooldownstart)
			timer.Create("savecooldown"..target:UniqueID(), CONFIG.dontsavecooldown, 1, function() if IsValid(target) then target:PrintMessage(HUD_PRINTTALK,CONFIG.cooldownfinish) target:SetNWBool("savecooldown", false) end end)
		end
end)

hook.Add("PlayerDeath", "removecooldowndeath", function(ply)
	if timer.Exists("savecooldown"..ply:UniqueID()) then timer.Destroy("savecooldown"..ply:UniqueID()) target:SetNWBool("savecooldown", false) end

end)

timer.Create("SaveThingsAuto", CONFIG.auto_time, 0, function() 
	local time = 0
	for k,v in pairs(player.GetAll()) do
		timer.Simple(time, function() 
			v:SaveThings()
		end)
		time = time+0.5
	end
	if CONFIG.print then
		print("[save-to-save] ВАШИ ДАННЫЕ В БЕЗОПАСНОСТИ")
end

end)
