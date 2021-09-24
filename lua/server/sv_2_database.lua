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

function dm_debug(text, is_tbl)
	--[[
		Выделяет строку text в логах консоли так,
		чтобы её было видно.
	]]
	print('/---------DEBUG---------/\n')
	if not is_tbl then print(text)
	else PrintTable(text) end
	print('\n/---------DEBUG---------/')
end

local function create_insert_list(tbl)
	--[[
		Cоздает строку вида ('v1'), ('v2'), ..., ('vN')
		из значений таблицы tbl
	]]
	local s = ''
	for k, v in pairs(tbl) do
		s = s .. string.format("('%s')", v) .. ','
	end
	return string.sub(s,1,#s-1)
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

function loaderDb:place_exists(name)
	--[[
		Проверяет, существует ли place с таким name
		в базе данных.
		Возвращает:
			false or true
	]]--
	local query = [[
		SELECT COUNT(place_name) AS fl
		FROM dm_place
		WHERE place_name = %s;
	]]
	query = string.format(query, sql.SQLStr(name))
	return execute(query)[1].fl == '1'
end


function loaderDb:get_place_id(place_name)
	if self:place_exists(place_name) then
		local query = [[
			SELECT place_id
			FROM dm_place
			WHERE place_name = %s;
		]]
		query = string.format(query, sql.SQLStr(place_name))
		return tonumber(execute(query)[1].place_id)
	end
	return false
end




function loaderDb:get_gamers_items(steam_id64)
	if self:gamer_exists(steam_id64) then
		local query = [[
			SELECT COUNT(dm_place.place_name)  AS place,
				   COUNT(dm_item.item_data)    AS place_data,
				   COUNT(dm_item.death_date)   AS death
			FROM dm_item 
					JOIN dm_gamer USING (steam_id64)
					JOIN dm_place USING (place_id);
			-- WHERE steam_id64 = %s;
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

-- function loaderDb:type_exists(name)
-- 	--[[
-- 		Проверяет, существует ли тип предметов с таким name
-- 		в базе данных.
-- 		Возвращает:
-- 			false or true
-- 	]]--
-- 	local query = [[
-- 		SELECT COUNT(type_name) AS fl
-- 		FROM dm_type
-- 		WHERE type_name = %s;
-- 	]]
-- 	query = string.format(query, sql.SQLStr(name))
-- 	return execute(query)[1].fl == '1'
-- end



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

function loaderDb:add_place(name)
	if not self:place_exists(name) then
		local query = [[
			INSERT INTO dm_place(place_name)
			VALUES (%s);
		]]
		query = string.format(query, sql.SQLStr(name))
		execute(query)
	end
end

-- function loaderDb:add_type(name)
-- 	if not self:type_exists(name) then
-- 		local query = [[
-- 			INSERT INTO dm_type(type_name)
-- 			VALUES (%s);
-- 		]]
-- 		query = string.format(query, sql.SQLStr(name))
-- 		execute(query)
-- 	end
-- end

function loaderDb:add_item(steam_id64, place_name, item_data)
	--[[
		item_data: table
	]]
	-- здесь нужно сделать какую-то проверку на то, что такой айтем уже существует
	local place_id = self:get_place_id(place_name)
	local query = [[
		INSERT INTO dm_item (steam_id64, place_id, item_data)
		VALUES (%s, %d, %s);
		DELETE FROM dm_item;
	]]
	query = string.format(query, tostring(steam_id64), place_id, sql.SQLStr(util.TableToJSON(item_data)))
	execute(query)
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

-- function createrDb:dm_type()
-- 	-- создает таблицу dm_tipe
-- 	if not sql.TableExists('dm_type') then 
-- 		sql.Begin()
-- 			sql.Query([[
-- 					CREATE TABLE dm_type(
-- 						type_id   INTEGER PRIMARY KEY,
-- 						type_name VARCHAR(30)
-- 					);
-- 				]])
-- 		sql.Commit()
-- 		return true
-- 	end
-- 	return false
-- end

function createrDb:dm_place()
	-- создает таблицу dm_place
	if not sql.TableExists('dm_place') then 
		sql.Begin()
			sql.Query([[
					CREATE TABLE dm_place(
						place_id   INTEGER PRIMARY KEY,
						place_name VARCHAR(30),
						place_types TEXT
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
						
						steam_id64 INTEGER, 	    -- владелец
						place_id   INTEGER, 		-- место пребывания предмета (инвентарь, статус и др)
					
						item_data   TEXT,          -- (где хранится) информация о местоположении предмета внутри данного хранилища   
						
						death_date   DATE, 			-- количество жизней предмета. Если = 0, то удаляется
						
						FOREIGN KEY (steam_id64) REFERENCES gamer (steam_id64) ON DELETE CASCADE,
						FOREIGN KEY (place_id)   REFERENCES place (place_id)
					);
				]])
		sql.Commit()
		return true
	end
	return false
end

-- function createrDb:init_fill()
-- 	if not loaderDb:var_exists('init is done') then
-- 		loaderDb:add_var('init is done', 1, 'Была ли пройдена начальная инициализация базы данных.')
-- 		local query = [[
-- 			INSERT INTO dm_place (place_name)
-- 			VALUES %s;

-- 			INSERT INTO dm_type (type_name)
-- 			VALUES %s;
-- 		]]
-- 		query = string.format(query, create_insert_list(dm_PLACES),
-- 					   			     create_insert_list(dm_TYPES))
-- 		execute(query)
-- 		return true
-- 	end
-- 	return false
-- end


function createrDb:Create()
	-- создает всю структуру базы данных игроков
	-- if self:dm_type() 
	-- 	then print('[data-manager: DataBase] Таблица dm_type создана!')
	-- 	else print('[data-manager: DataBase] Таблица dm_type уже существует!') 
	-- end
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
	-- if self:init_fill()
	-- 	then print('[data-manager: DataBase] Вспомогательные таблицы заполнены!')
	-- 	else print('[data-manager: DataBase] Вспомогательные таблицы уже заполнены!') 
	-- end
end

function createrDb:DropAll()
	-- Удаляет все таблицы
	-- применять только если знаешь, что делаешь.
	if sql.TableExists('dm_item') then execute('DROP TABLE dm_item;') end
	if sql.TableExists('dm_gamer') then execute('DROP TABLE dm_gamer;') end
	if sql.TableExists('dm_place') then execute('DROP TABLE dm_place;') end
	if sql.TableExists('dm_var') then execute('DROP TABLE dm_var;') end
end


createrDb:Create()