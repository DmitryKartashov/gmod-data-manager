--[[------------------------------------------------------------------------
	Модуль с различными методами для обращения к базе данных. 
	Если ты не знаешь, что делаешь, то лучше ничего не меняй.

---------------------------------------------------------------------------]]


--[[----------------------------------------------------
				ПЕРЕМЕННЫЕ
------------------------------------------------------]]

-- модуль с функциями создания базы данных
createrDb = {}

-- модуль для загрузки и выгрузки данных
loaderDb = {}



--[[----------------------------------------------------
				ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
------------------------------------------------------]]


local function execute(query, nolog)
	--[[ 
		Исполняет запрос.
		Если nolog = nil or false: 
			выводит информацию об ошибке и\или предупреждает
			о том, что запрос вернул пустое значение.
		Возвращает:
			data - таблица с результатом запроса
	]]
	sql.Begin()
	local data = sql.Query(query)
	sql.Commit()
	if (data == nil or data == false) and not nolog then
		print('[data-manager: SQL Warning] ' .. 'Запрос (\n'..query..'\n) вернул пустое множество.')
		print('[data-manager: SQL Warning] ' .. 'sql.LastError: ' .. tostring(sql.LastError()))
	end
	return data
end

local function dm_debug(text, is_tbl)
	--[[
		Выделяет строку text в логах консоли так,
		чтобы её было видно.
	]]
	print('/---------DEBUG---------/\n')
	if is_tbl then print(text)
	else PrintTable(text) end
	print('\n/---------DEBUG---------/')
end





--[[----------------------------------------------------
				LOADERS
------------------------------------------------------]]


function loaderDb:gamer_exists(steam_id64)
	--[[
		Проверяет, существует ли игрок с таким steam_id64
		в базе данных.
		Возвращает:
			false or true
	]]--
	local query = [[
		SELECT COUNT(steam_id64) AS fl 
		FROM dm_gamer
		WHERE steam_id64 = %s;
	]]
	query = string.format(query, steam_id64)
	return execute(query)[1].fl == '1'
end

function loaderDb:var_exists(name)
	--[[
		Проверяет, существует ли переменная с таким name
		в базе данных.
		Возвращает:
			false or true
	]]--
	local query = [[
		SELECT COUNT(var_name) AS fl
		FROM dm_var
		WHERE var_name = %s;
	]]
	query = string.format(query, sql.SQLStr(name))
	return execute(query)[1].fl == '1'
end



function loaderDb:add_var(name, value, description)
	if not self:var_exists(name) then
		local query = [[
			INSERT INTO dm_var(var_name, var_value, var_description)
			VALUES (%s, %d, %s);
		]]
		query = string.format(query, sql.SQLStr(name), value, sql.SQLStr(description))
		execute(query)
	end
end

function loaderDb:add_gamer(steam_id64)
	if not self:gamer_exists(steam_id64) then
		local query = [[
			INSERT INTO dm_gamer(steam_id64, birthday)
			VALUES (%s, '%s');
		]]
		local date = os.date("%Y-%m-%d", os.time())
		query = string.format(query, steam_id64, date)
		execute(query)
	end
end


function loaderDb:get_gamers_items(steam_id64)
	if self:gamer_exists(steam_id64) then
		local query = [[
			SELECT dm_place.place_name  AS place,
				   dm_type.type_name    AS type,
				   dm_item.item_data    AS data,
				   dm_item.lives_number AS lives
			FROM dm_item 
					JOIN dm_gamer USING (steam_id64)
					JOIN dm_place USING (place_id)
					JOIN dm_type USING (type_id)
			WHERE steam_id64 = %s;
		]]
		query = string.format(query, steam_id64)
		return execute(query)
	end
	return false
end

function loaderDb:get_var_value(name)
	if self:var_exists(name) then
		local query = [[
			SELECT var_value AS val
			FROM dm_var
			WHERE var_name = %s;
		]]
		query = string.format(query,sql.SQLStr(name))
		return tonumber(execute(query)[1].val)
	end
end


function loaderDb:set_var(name, value)
	if not self:var_exists(name) then
		local query = [[
			UPDATE dm_var
			SET var_value = %f
			WHERE var_name = %s;
		]]
		query = string.format(query, value, sql.SQLStr(name))
		execute(query)
	end
end






--[[----------------------------------------------------
				CREATORS
------------------------------------------------------]]

function createrDb:dm_type()
	-- создает таблицу dm_tipe
	if not sql.TableExists('dm_type') then 
		sql.Begin()
			sql.Query([[
					CREATE TABLE dm_type(
						type_id   INTEGER PRIMARY KEY,
						type_name VARCHAR(30)
					);
				]])
		sql.Commit()
		return true
	end
	return false
end

function createrDb:dm_place()
	-- создает таблицу dm_place
	if not sql.TableExists('dm_place') then 
		sql.Begin()
			sql.Query([[
					CREATE TABLE dm_place(
						place_id   INTEGER PRIMARY KEY,
						place_name VARCHAR(30)
					);
				]])
		sql.Commit()
		return true
	end
	return false
end

function createrDb:dm_gamer()
	-- создает таблицу dm_gamer
	if not sql.TableExists('dm_gamer') then 
		sql.Begin()
			sql.Query([[
					CREATE TABLE dm_gamer(
						steam_id64 INTEGER PRIMARY KEY,
						birthday   DATE,
						PC_id      VARCHAR(40)
					);
				]])
		sql.Commit()
		return true
	end
	return false
end

function createrDb:dm_var()
	--[[
		Создает таблицу для хранения различных переменных
	]]
	local query = [[
		CREATE TABLE dm_var(
			var_name VARCHAR(50) PRIMARY KEY,
			var_value REAL,
			var_description TEXT
		);
	]]

	if not sql.TableExists('dm_var') then
		execute(query)
		return true
	end
	return false
end

function createrDb:dm_item()
	-- создает таблицу dm_item
	if not sql.TableExists('dm_item') then 
		sql.Begin()
			sql.Query([[
					CREATE TABLE dm_item(
						-- таблица с описанием предметов, принадлежащих игрокам
						item_id    INTEGER PRIMARY KEY AUTOINCREMENT,
						
						steam_id64 INTEGER, 	                -- владелец
						place_id   INTEGER, 				-- место пребывания предмета (инвентарь, статус и др)
						type_id    INTEGER, 				-- тип предмета (оружие и др)
							
						item_data    TEXT, 						-- внутренняя информация о предмете
						lives_number SMALLINT, 					-- количество жизней предмета. Если = 0, то удаляется
						
						FOREIGN KEY (steam_id64) REFERENCES gamer (steam_id64) ON DELETE CASCADE,
						FOREIGN KEY (place_id)   REFERENCES place (place_id),
						FOREIGN KEY (type_id)    REFERENCES type  (type_id)
					);
				]])
		sql.Commit()
		return true
	end
	return false
end

function createrDb:init_fill()
	if not loaderDb:var_exists('init is done') then
		loaderDb:add_var('init is done', 1, 'Была ли пройдена начальная инициализация базы данных.')
		local query = [[
			INSERT INTO dm_place (place_name)
			VALUES ('status'),    -- статус персонажа (жизни, голод и тд)
					('hotbar'),   -- в панели быстрого доступа
					('inventory'),-- в инвентаре
					('bank');     -- в банке

			INSERT INTO dm_type (type_name)
			VALUES ('weapon'),    -- оружие
					('ammo'),     -- боеприпасы
					('armor'),    -- броня
					('health'),   -- здоровье
					('model'), 	  -- модель
					('position'), -- позиция в пространстве
					('team'),     -- профессия
					('vehicle');  -- транспортное средство
		]]
		execute(query)
		return true
	end
	return false
end


function createrDb:Create()
	-- создает всю структуру базы данных игроков
	if self:dm_type() 
		then print('[data-manager: DataBase] Таблица dm_type создана!')
		else print('[data-manager: DataBase] Таблица dm_type уже существует!') 
	end
	if self:dm_place() 
		then print('[data-manager: DataBase] Таблица dm_place создана!')
		else print('[data-manager: DataBase] Таблица dm_place уже существует!') 
	end
	if self:dm_gamer() 
		then print('[data-manager: DataBase] Таблица dm_gamer создана!')
		else print('[data-manager: DataBase] dm_gamer уже существует!') 
	end
	if self:dm_item() 
		then print('[data-manager: DataBase] Таблица dm_item создана!')
		else print('[data-manager: DataBase] Таблица dm_item уже существует!') 
	end
	if self:dm_var() 
		then print('[data-manager: DataBase] Таблица dm_var создана!')
		else print('[data-manager: DataBase] Таблица dm_var уже существует!') 
	end
	-- и заполняет вспомогательные таблицы
	if self:init_fill()
		then print('[data-manager: DataBase] Вспомогательные таблицы заполнены!')
		else print('[data-manager: DataBase] Вспомогательные таблицы уже заполнены!') 
	end
end

function createrDb:DropAll()
	-- Удаляет все таблицы
	-- применять только если знаешь, что делаешь.
	local query = [[
		DROP TABLE dm_item;
		DROP TABLE dm_gamer;
		DROP TABLE dm_place;
		DROP TABLE dm_type;
	]]
	execute(query)
end