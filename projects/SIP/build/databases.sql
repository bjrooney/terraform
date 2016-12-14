create database bus;

create user bus@'%'  Identified by 'buspass123';
grant SELECT on bus.* to bus@'%';

create user busa@'%' Identified by 'buspass123a';
grant all on bus.* to busa@'%'; 

flush privileges;