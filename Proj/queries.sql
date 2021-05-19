--1.
SELECT DISTINCT mark FROM AutoInfo WHERE class = 'Sport Cars';

--2. 
SELECT model FROM Autos WHERE year = 2008;

--3.

--4. 
SELECT DISTINCT mark, FullName FROM AutoInfo LEFT JOIN Autos ON AutoInfo.FullName = Autos.Model WHERE (class = 'Luxury' OR class = 'crossover');

