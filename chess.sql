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
	    FOR chessman_record in
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
                    i := i + step;
		END LOOP;
	END
$$

CREATE OR REPLACE PROCEDURE start_game ()
LANGUAGE plpgsql
AS $$
    BEGIN
	TRUNCATE Chessman CASCADE;
	TRUNCATE Chessboard;
        call initialize_figures();
        call initialize_board();
    END
$$

call start_game(); 


--1.
SELECT count(*) FROM Chessboard; 

--2. 
SELECT id FROM Chessman WHERE substring(class, 1, 1) = 'k';

--3.
SELECT class, count(*) AS count FROM chessman GROUP BY class;

--4.
SELECT id FROM Chessboard LEFT JOIN Chessman ON chessman_id = id WHERE color = 'white' AND class = 'pawn';

--5.
SELECT class, color FROM Chessman LEFT JOIN Chessboard ON chessman_id = id WHERE ascii(x) - ascii('A') = y - 1;

-- 6.
SELECT color, count(*) AS count FROM chessman LEFT JOIN Chessboard ON id = chessman_id GROUP BY color;

--7. 
SELECT class FROM Chessman LEFT JOIN Chessboard ON id = chessman_id WHERE color = 'black' GROUP BY class;
                                                                                                                            
--8.
SELECT class, count(*) AS count FROM Chessman LEFT JOIN Chessboard ON id = chessman_id WHERE color = 'black' GROUP BY class;

--9. 
SELECT class FROM Chessman LEFT JOIN Chessboard ON id = chessman_id GROUP BY class HAVING count(*) >= 2;

--10.
WITH X AS (SELECT color, COUNT(Chessman) count FROM Chessman LEFT JOIN Chessboard on id = chessman_id GROUP BY color)
SELECT * FROM X WHERE count = (SELECT MAX(count) FROM X);     

--11.
WITH coords AS (SELECT x, y FROM Chessman LEFT JOIN Chessboard ON id = chessman_id WHERE class = 'rook')
SELECT id, class FROM Chessman, Chessboard, coords 
WHERE id = chessman_id 
AND (Chessboard.x = coords.x OR Chessboard.y = coords.y)

--12.
SELECT color FROM Chessman 
LEFT JOIN Chessboard ON id = chessman_id 
GROUP BY class, color 
HAVING class = 'pawn' AND count(*) = 8


--13. (With deletion to commit changes)
SELECT * INTO newChessboard FROM Chessboard;
DELETE FROM newChessboard WHERE x = 'A' AND y = 2;
 
SELECT DISTINCT id, class, color FROM Chessman, Chessboard, newChessboard 
WHERE (exists(SELECT * FROM Chessboard WHERE id = Chessboard.chessman_id)
		 AND NOT exists(SELECT * FROM newChessboard WHERE id = newChessboard.chessman_id))
	  OR 
	  (id = Chessboard.chessman_id 
	   AND id = newChessboard.chessman_id
	   AND (Chessboard.x <> newChessboard.x OR Chessboard.y <> newChessboard.y)
	  );



--14.
WITH blackKing AS (SELECT x, y FROM Chessman 
				   LEFT JOIN Chessboard ON id = chessman_id 
				   WHERE class = 'king' AND color = 'black')


SELECT id, class, color FROM Chessman, Chessboard, blackKing
WHERE 
id = chessman_id
AND abs(Chessboard.y - blackKing.y) BETWEEN 0 AND 2
AND abs(ascii(Chessboard.x) - ascii(blackKing.x)) BETWEEN 0 AND 2
AND class <> 'king';

--15.
WITH whiteKing AS (SELECT * FROM Chessman LEFT JOIN Chessboard ON id = chessman_id 
				   WHERE color = 'white' AND class = 'king')
, distanceTable AS (SELECT Chessman.id, Chessman.class, Chessman.color, abs(ascii(Chessboard.x) - ascii(whiteKing.x)) + abs(Chessboard.y - whiteKing.y) AS distance
					FROM Chessman, Chessboard, whiteKing 
					WHERE Chessman.id = Chessboard.chessman_id AND Chessman.id <> whiteKing.id)
SELECT * FROM distanceTable WHERE distanceTable.distance = (SELECT MIN(distanceTable.distance) FROM distanceTable);

