




	-- сюда добавлять новые place (например, банк, инвентарь, гараж и тд)
	create_Place('status',
		function(ply, data)
			for k, v in pairs(data) do
				if k == 'cur_hp' then
					ply:SetHealth(v)
				elseif k == 'max_hp' then
					ply:SetMaxHealth(v)
				elseif k == 'team' then
					ply:changeTeam(team, True)
				elseif k == 'pos' then
					ply:SetPos(v)
				elseif k == 'model' then
					ply:SetModel(v)
				elseif k == 'armor' then 
					ply:SetArmor(v)
				end
				ply:Spawn()
			end
		end,
		function(ply)
			return {
				{['cur_hp'] = ply:Health()}, -- первый предмет
				{['max_hp'] = ply:GetMaxHealth()}, -- второй предмет
				{['team'] = ply:Team()},
				{['pos'] = ply:GetPos()},
				{['model'] = ply:GetModel()},
				{['armor'] = ply:Armor()}

			}
		end
	)
