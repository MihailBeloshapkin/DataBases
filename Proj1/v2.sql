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
    usedAuto_id integer primary key  not null,
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


insert into usedauto(usedauto_id, discription, newprice, ownerscount, condition, year) values
(1, 6, 10000, 1, 9, 2017), 
(2, 6, 8000, 2, 7, 2015), 
(3, 2, 2000, 4, 7, 2008),
(4, 5, 10000, 2, 8, 2008);

--1.
select distinct mark, model from info where class = 'Sport';

--2.
with a as (select * from info join usedauto on info.info_id = usedauto.discription)
select mark, model from a where year = 2008;

--6.
select mark, model, gen from info where not exists(select * from usedauto
    where info_id = usedauto.discription);



create or replace function GetMinMax()
returns table(
    class char(20),
    minMark char(20),
    minModel char(20),
    minPrice integer,
    maxMark char(20),
    maxModel char(20),
    maxPrice integer
             )
language plpgsql as
$$
    begin
        with minData as (select class, min(price) as minPrice from info group by class)
        with maxData as (select class, max(price) as minPrice from info group by class)
        select mark, model, minPrice from info join minData on (minPrice = price and minData.class = info.class)
    end;
    $$;


with minData as (select class, min(price) as minPrice from info group by class)
, maxData as (select class, max(price) as maxPrice from info group by class)
, minAutos as (select info.class, info.mark as minMark, info.model as minModel, minPrice from info join minData
    on (info.class = minData.class AND info.price = minData.minPrice))
, maxAutos as (select info.class, info.mark as maxMark, info.model as maxModel, maxPrice from info join maxData
    on (info.class = maxData.class AND info.price = maxData.maxPrice))
select minAutos.class, minMark, minModel, minPrice, maxMark, maxModel, maxPrice
from minAutos join maxAutos on (minAutos.class = maxAutos.class);

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


