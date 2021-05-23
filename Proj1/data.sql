CREATE TABLE NewAutoInfo(
	Mark CHAR(20) NOT NULL,
	Model CHAR(20) NOT NULL,
	Generation CHAR(10) NOT NULL,
	Power integer,
	Class CHAR(20) REFERENCES Class (class) NOT NULL,
	Colors CHAR(40) NOT NULL,
	Equipment CHAR(20),
	OriginPrice integer,
	PRIMARY KEY (Mark, Model, Generation, Equipment)
);

INSERT INTO NewAutoInfo VALUES
('BMW', '3 Series', 'e46', 300, 'Sport Cars', 'black, white', 'Sport+', 65000),
('Mercedes', 'S600', 'w140', 350, 'Luxury', 'black, white', 'Classic', 150000),
('Toyota', 'Rav4', '3 Gen', 150, 'Crossover', 'black, gray', '2.0', 27000),
('VAS', 'Vesta', '1 Gen', 115, 'Econom', 'gray, white, green', 'classic', 12000),
('BMW', '7 Series', 'e38', 277, 'Luxury', 'black', 'Elehance', 150000),
('BMW', '3 Series', 'e36', 150, 'Sport Cars', 'black, blue', 'Avangard', 100000),
('VAS', 'Granta Sport', '1 Gen', 120, 'Sport Cars', 'gray', 'Classic', 15000);	

CREATE TABLE UsedAutoInfo(
	id CHAR(10) PRIMARY KEY, 
	Mark CHAR(20) NOT NULL,
	Model CHAR(20) NOT NULL,
	Generation CHAR(10) NOT NULL,
	Equipment CHAR(20) NOT NULL,
	Price INT NOT NULL,
	Year integer CHECK (Year BETWEEN 1980 AND 2021) NOT NULL,
	OwnersNumber integer NOT NULL,
	Condition integer CHECK (Condition BETWEEN 0 AND 10),
	FOREIGN KEY (Mark, Model, Generation, Equipment) REFERENCES NewAutoInfo (Mark, Model, Generation, Equipment)
);

INSERT INTO UsedAutoInfo 
(id, Mark, Model, Generation, Equipment, Price, Year, OwnersNumber, Condition) VALUES
('m221mm98', 'BMW', '3 Series', 'e36', 'Avangard', 10000, 1997, 5, 4), 
('a234aa178', 'Toyota', 'Rav4', '3 Gen', '2.0', 25000, 2007, 2, 9), 
('r175ct777', 'VAS', 'Vesta', '1 Gen', 'classic', 7000, 2016, 1, 8);	

CREATE TABLE ShowRoom(
	Name CHAR(20) NOT NULL,
	car_id CHAR(10) REFERENCES UsedAutoInfo(id),
	PRIMARY KEY (Name,car_id)
);

--1.
SELECT DISTINCT Mark FROM NewAutoInfo WHERE class = 'Sport Cars'; 



--12.
SELECT sum(case Mark WHEN 'Toyota' then 1 else 0 end) * 100.0 / count(*) FROM UsedAutoInfo;

--6.
SELECT Mark, Model, Generation FROM NewAutoInfo 
WHERE NOT EXISTS (SELECT * FROM UsedAutoInfo 
				  WHERE UsedAutoInfo.Mark = NewAutoInfo.Mark 
				  AND UsedAutoInfo.Model = NewAutoInfo.Model
		          AND UsedAutoInfo.Generation = NewAutoInfo.Generation);