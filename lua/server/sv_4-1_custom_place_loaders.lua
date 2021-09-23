



dm_PLACES = {
	-- сюда добавлять новые place (например, банк, инвентарь, гараж и тд)
	dm_new_Place('status', {
		'health',
		'armor',
		'team',
		'position',
		'model'
	}),
	dm_new_Place('hotbar', {
		'weapon',
		'ammo'
	})
}