create table info(
    info_id INTEGER primary key NOT NULL,
    mark char(20) not null,
    model char(20) not null,
    gen char(12) not null,
    eq char(12) not null,
    class char(20) references class(class) not null,
    price integer check (price > 0)
);

create table usedAuto(
    usedAuto_id integer references car(id) primary key  not null,
    discription integer references info(info_id),
    newPrice integer NOT NULL check ( newPrice > 0 ),
    ownersCount integer check ( ownersCount > 0 ),
    condition integer CHECK ( condition BETWEEN 0 AND 10),
    year integer not null
);

create table class(
    class char(20) not null,
    unique (class)
);

insert into  class values
                          ('Econom'),
                          ('Business'),
                          ('SUV'),
                          ('Luxury'),
                          ('Sport');

create table info(
    info_id INTEGER primary key NOT NULL,
    mark char(20) not null,
    model char(20) not null,
    gen char(12) not null,
    eq char(12) not null,
    power integer check ( power > 0 ),
    class char(20) references class(class) not null,
    price integer check (price > 0)
);


insert into info(info_id, mark, model, gen, eq, power, class, price) values
(1, 'Lada', 'Granta', '1 gen', 'classic', 100, 'Econom', 7000);

insert into info(info_id, mark, model, gen, eq, power, class, price) values
(2, 'Lada', 'Niva', '1 gen', 'offroad', 80, 'SUV', 6800),
(3, 'BMW', '7 Series', 'e38', 'Avangard', 340, 'Luxury', 200000),
(4, 'Toyota', 'Camry', 'v40', '3.5 v6', 270, 'Business', 35000),
(5, 'Toyota', 'Rav4', '1 gen', '2.4d', 145, 'SUV', 27000),
(6, 'Lada', 'Granta Sport', '1 gen', 'sport+', 125, 'Sport', 14000),
(7, 'Lada', 'Vesta', '1 gen', 'comfort', 120, 'Econom', 12500),
(8, 'Lada', 'Vesta', '1 gen', 'comfort+', 125, 'Econom', 13500),
(9, 'Mercedes', 'S-classe', 'w222', 'avangard', 390, 'Luxury', 214000);

insert into info(info_id, mark, model, gen, eq, power, class, price) values
(10, 'BMW', '5 Series', 'f10', 'classic', 450, 'Sport', 120000);

insert into usedauto(usedauto_id, discription, newprice, ownerscount, condition, year) values
(1, 6, 10000, 1, 9, 2017), 
(2, 6, 8000, 2, 7, 2015), 
(3, 2, 2000, 4, 7, 2008),
(4, 5, 10000, 2, 8, 2008);

insert into usedauto(usedauto_id, discription, newprice, ownerscount, condition, year) values
(5, 4, 15000, 4, 5, 2007),
(6, 4, 15500, 3, 4, 2008),
(7, 3, 30000, 5, 4, 1998), (8, 7, 9000, 1, 8, 2017),
(9, 7, 9500, 2, 5, 2016),
(10, 7, 5700, 4, 5, 2015);	


insert into car(id, condition) values
(5, 'used'),
(6, 'used'),
(7, 'used'),
(8, 'used'),
(9, 'used'),
(10, 'used'),
(11, 'new'),
(12, 'new');




--1.
select distinct mark, model from info where class = 'Sport';

--2.
with a as (select * from info join usedauto on info.info_id = usedauto.discription)
select mark, model from a where year = 2008;

--3
select mark from usedautosdata group by mark having max(year) < 2008;

--4.
with a as (select mark from info group by class, mark having class = 'Luxury'),
     b as (select mark from info group by class, mark having class = 'SUV')
select * from a where exists(select * from b where a.mark = b.mark);

--5.
with a as (select mark, name from showroomCars group by mark, name)
select name, count(mark) from a group by name having count(mark) > 2;

--8.
--select distinct name, min(price) from showroomcars where class = 'SUV' and price < 30000;
select name, min(price) from showroomcars
group by name
having exists(select * from showroomcars where class = 'SUV')
and min(price) < 30000;

--6.
select mark, model, gen from info where not exists(select * from usedauto
    where info_id = usedauto.discription);

select min(newprice) * 1.0 / price as delta, mark, model from usedauto join info on (usedauto.discription = info.info_id)
group by mark, model, price;

--7.
select min(newprice) * 1.0 / price as delta, mark, model, price
from usedauto join info on (usedauto.discription = info.info_id)
group by mark, model, price;

--9.
select class, avg(price) as avgprice, sum(case class when info.class then 1 else 0 end) from info
group by class
order by avgprice desc;

--12
with a as (select * from info join usedauto on info.info_id = usedauto.discription)
select sum(case Mark when 'Toyota' then 1 else 0 end) * 100.0 / count(*) from a;

--11
with a as (select mark from info group by class, mark having class = 'Luxury'),
     b as (select mark from info group by class, mark having class = 'SUV')
select * from a where not exists(select * from b where a.mark = b.mark);

--10.
with a as (select * from info join usedauto on info.info_id = usedauto.discription)
, b as (select max(newprice) * 1.0 / min(newprice) as delta, mark, model from a group by mark, model)
select mark, model from b where delta > 1.1;


--13
with a as (select mark, model, class, sum(case class when usedautosdata.class then 1 else 0 end) as count from usedautosdata group by mark, model, class)
select class, max(count) as maxCount, mark, model from a group by class, mark, model;


-- view 1.
create or replace view GetMinMax
as with minData as (select class, min(price) as minPrice from info group by class)
, maxData as (select class, max(price) as maxPrice from info group by class)
, minAutos as (select info.class, info.mark as minMark, info.model as minModel, minPrice from info join minData
    on (info.class = minData.class AND info.price = minData.minPrice))
, maxAutos as (select info.class, info.mark as maxMark, info.model as maxModel, maxPrice from info join maxData
    on (info.class = maxData.class AND info.price = maxData.maxPrice))
select minAutos.class, minMark, minModel, minPrice, maxMark, maxModel, maxPrice
from minAutos join maxAutos on (minAutos.class = maxAutos.class);



select avg(newprice) * 100.0 / price as delta, mark, model, price
from usedauto join info on (usedauto.discription = info.info_id)
group by mark, model, price
order by delta desc;


create table car(
    id integer primary key not null,
    condition char(5) check (condition in ('new', 'used'))
);

create table newAuto(
    newAuto_id integer references car(id) primary key not null,
    discription integer references info(info_id) not null,
    newPrice integer check (newPrice > 0)
);

insert into newauto(newauto_id, discription, newprice) VALUES
(11, 7, 11700), (12, 9, 190000);

insert into car(id, condition) values
(1, 'used'), (2, 'used'), (3, 'used'), (4, 'used');


create or replace view usedAutosData
as select * from info join usedauto on info.info_id = usedauto.discription;

create or replace view newAutosData
as select * from newauto join info on (newauto.discription = info.info_id);

create or replace function Alternatives(id integer)
returns table(
    alternativeMark char(20),
    alternativeModel char(20),
    delta integer
    )
language plpgsql as
    $$
    begin
        return query
            with var as (select * from newautosdata where newautosdata.newauto_id = id)
            select usedautosdata.mark,
                   usedautosdata.model,
                   abs(usedautosdata.newprice - var.newprice) as delta
            from usedautosdata, var
            order by delta
            fetch first 10 rows only;
    end;
    $$;


create or replace function updatePrice() returns trigger as $gen_trigger$
    begin
        if new is not null then
            with prevGeneration as (select usedauto_id as id from usedautosdata
                where mark = new.mark and model = new.model)

            update usedauto
            set newprice = usedauto.newprice * 0.95
            where exists(select * from prevGeneration where prevGeneration.id = usedauto.usedauto_id);
            return new;
        end if;
    end;
$gen_trigger$ LANGUAGE plpgsql;


create or replace function updatePrice() returns trigger as $gen_trigger$
    begin
        if new is not null then
            if exists(select * from info where new.mark = mark
                and new.model = model and new.gen = gen)
                then
                return new;
            else
                with prevGeneration as (select usedauto_id as id from usedautosdata
                    where mark = new.mark and model = new.model)

                update usedauto
                set newprice = usedauto.newprice * 0.95
                where exists(select * from prevGeneration where prevGeneration.id = usedauto.usedauto_id);
                return new;
            end if;
        end if;
    end;
$gen_trigger$ LANGUAGE plpgsql;


create trigger gen_trigger after insert on info for each row execute procedure updateprice();


insert into info(info_id, mark, model, gen, eq, power, class, price)  values
(11, 'Toyota', 'Camry', 'v50', 'elegance', 230, 'Business', 31500);


create table showroom(
    name char(20) not null,
    car_id integer references car(id) not null,
    unique (car_id)
);

insert into showroom(name, car_id) values 
('Showroom 1', 1), ('Showroom 1', 4), ('Showroom 1', 7);

create or replace view showRoomData
as select * from showroom join car on showroom.car_id = car.id;


-- view for showroom cars.
create or replace view showroomCars as
with a as (select mark, model, newprice as price, class, car.condition, usedauto_id as id
from usedautosdata join car on usedauto_id = car.id
union all select mark, model, newprice as price, class, car.condition, newauto_id as id
from newautosdata join car on newauto_id = car.id)
select * from a join showroom on a.id = showroom.car_id;

create or replace function idGenerator()
returns integer
language plpgsql as
$$
    declare MaxId1 integer default 0;
    declare MaxId2 integer default 0;
    begin
        select max(usedauto_id) into MaxId1 from usedauto;
        select max(newauto_id) into MaxId2 from newauto;
        if MaxId1 > MaxId2 then
            return MaxId1 + 1;
        else
            return MaxId2 + 1;
        end if;
    end;
$$;


insert into usedauto(usedauto_id, discription, newprice, ownerscount, condition, year) values
(idgenerator(), 10, 21300, 2, 4, 2016), (idgenerator(), 8, 9800, 2, 8, 2017);


insert into showroom(name, car_id) VALUES
('Showroom 1', 5);
         

create or replace function insertUsed() returns trigger as $insert_used_trigger$
    begin
        insert into car(id, condition) VALUES (new.usedauto_id, 'used');
        return new;
    end;
$insert_used_trigger$ LANGUAGE plpgsql;

create trigger insertUsedTrigger

before insert
on usedauto for each row
    begin
    insert into car(id, condition) values )(new.usedauto_id, 'used');
    end;


