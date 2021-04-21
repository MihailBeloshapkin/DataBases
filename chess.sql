CREATE DATABASE chess;

CREATE TABLE Chessman(
    id serial primary key,
    class char(20) check (class in ('king', 'queen', 'rook', 'bishop', 'knight', 'pawn')) NOT NULL,
    color char(20) check (color in ('white', 'black')) NOT NULL
);

CREATE TABLE Chessboard(
    chessman_id int primary key references chessman(id),
    x char check (x between 'A' and 'H') NOT NULL,
    y int check (y between 1 and 8) NOT NULL,
    UNIQUE (x, y)
);

CREATE OR REPLACE PROCEDURE insert_chessman (chessman_class char(20), count int)
LANGUAGE plpgsql
AS $$
    BEGIN 
	    FOR i in 1..count loop
		    INSERT INTO Chessman(class, color) values (chessman_class, 'white');
			INSERT INTO Chessman(class, color) values (chessman_class, 'black');
		END loop;
	END
$$

CREATE OR REPLACE PROCEDURE initialize_figures ()
LANGUAGE plpgsql
AS 
$$
    BEGIN
	    call insert_chessman('king', 1);
		call insert_chessman('queen', 1);
		call insert_chessman('rook', 2);
		call insert_chessman('bishop', 2);
		call insert_chessman('knight', 2);
		call insert_chessman('pawn', 8);
	END
$$

CREATE OR REPLACE PROCEDURE place_chessman(required_class char(20), coord_y int, coord_x int, step int)
LANGUAGE plpgsql
AS $$
    DECLARE 
	chessman_record int;
	i int := coord_x;
	x_positions char[] := array['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
	BEGIN
	    for chessman_record in
		    SELECT id FROM chessman WHERE class = required_class AND color = 'white'
		LOOP
		    INSERT INTO Chessboard VALUES (chessman_record, x_positions[i], coord_y);
			i := i + step;
		END LOOP;
		i := coord_x;
		FOR chessman_record IN 
		    SELECT id FROM chessman WHERE class = required_class AND color = 'black'
			LOOP
			    INSERT INTO Chessboard VALUES (chessman_record, x_positions[i], 9 - coord_y);
			END LOOP;
	END
$$