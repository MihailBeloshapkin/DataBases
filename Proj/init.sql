CREATE TABLE Autos(
	Model CHAR(41) REFERENCES AutoInfo(FullName) ON DELETE CASCADE NOT NULL,
	Year integer CHECK (Year BETWEEN 1980 AND 2021) NOT NULL,
	OwnersNumber integer NOT NULL,
	Condition integer CHECK (Condition BETWEEN 0 AND 10)
);

CREATE TABLE AutoInfo(
	Mark CHAR(20),
	Model CHAR(20),
	Power integer,
	Class CHAR(20),
	Color CHAR(20) CHECK (Color in ('black', 'white', 'gray', 'red', 'blue', 'green')) NOT NULL,
	Equipment CHAR(20),
	OriginPrice integer,
	FullName CHAR(41) GENERATED ALWAYS AS (Mark || ' ' || Model) STORED PRIMARY KEY
);