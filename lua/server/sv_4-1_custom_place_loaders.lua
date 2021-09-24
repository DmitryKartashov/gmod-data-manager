




-- сюда добавлять новые place (например, банк, инвентарь, гараж и тд)
create_Place('status',{
	['give_foo'] = function(ply, data)
						for k, v in pairs(data) do
							if k == 'cur_hp' then
								ply:SetHealth(v)
							elseif k == 'max_hp' then
								ply:SetMaxHealth(v)
							elseif k == 'team' then
								ply:changeTeam(math.floor(team), True)
								ply:Spawn()
							elseif k == 'pos' then
								ply:SetPos(v)
							elseif k == 'model' then
								ply:SetModel(v)
							elseif k == 'armor' then 
								ply:SetArmor(v)
							end
						end
					end,
	['save_foo'] = function(ply)
						return {
							{['cur_hp'] = ply:Health()}, -- первый предмет
							{['max_hp'] = ply:GetMaxHealth()}, -- второй предмет
							{['team'] = math.floor(ply:Team())},
							{['pos'] = ply:GetPos()},
							{['model'] = ply:GetModel()},
							{['armor'] = ply:Armor()}
							}
					end
})
