CREATE TABLE world(
    -- таблица с названиями серверов
	world_id   INT PRIMARY KEY,
    world_name VARCHAR(30)
);


CREATE TABLE gamer(
    -- таблица с пользователями
	steam_id64 BIGINT UNSIGNED NOT NULL PRIMARY KEY,
    
    birthday   DATE,
    
    world_id   INT NOT NULL,
    
    FOREIGN KEY (world_id) REFERENCES world (world_id)
);

CREATE TABLE place(
    -- таблица с возможными местами пребывания предметов
	place_id   INT NOT NULL PRIMARY KEY,
    place_name VARCHAR(30)
);

CREATE TABLE type(
    -- таблица с различными типами предметов
	type_id   INT NOT NULL PRIMARY KEY,
    type_name VARCHAR(30)
);

CREATE TABLE item(
    -- таблица с описанием предметов, принадлежащих игрокам
	item_id    INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    
    steam_id64 BIGINT UNSIGNED NOT NULL, 	-- владелец
    place_id   INT NOT NULL, 				-- место пребывания предмета (инвентарь, статус и др)
    type_id    INT NOT NULL, 				-- тип предмета (оружие и др)
    world_id   INT NOT NULL, 				-- на каком сервере хранится
    	
    item_data    TEXT, 						-- внутренняя информация о предмете
    lives_number SMALLINT, 					-- количество жизней предмета. Если = 0, то удаляется
    
    FOREIGN KEY (steam_id64) REFERENCES gamer (steam_id64),
    FOREIGN KEY (place_id)   REFERENCES place (place_id),
    FOREIGN KEY (type_id)    REFERENCES type  (type_id),
    FOREIGN KEY (world_id)   REFERENCES world (world_id)
);
