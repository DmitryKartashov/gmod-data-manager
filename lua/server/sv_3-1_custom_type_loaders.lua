



dm_TYPES = {
	-- сюда добавлять новые type (здоровье, профессия, транспорт, дом, оружие и тд)
	dm_new_Type('health',{
		dm_new_val('cur_hp',
					'int',
					function(ply, val) ply:SetHealth(val) end,
					function(ply) return ply:Health() end),
		dm_new_val('max_hp',
					'int',
					function(ply, val) ply:SetMaxHealth(val) end,
					function(ply) return ply:GetMaxHealth() end)
	})
}

