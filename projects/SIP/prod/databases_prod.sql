
create database tickets_and_passes;

create user tandp@'%'    Identified by '46@athens@DEVICE@outer@88';
grant SELECT on tickets_and_passes.* to tandp@'%';

create user tandpa@'%'    Identified by '49_joined_SEEDS_usually_33';
SET PASSWORD FOR tandpa@'%'  = PASSWORD('49_joined_SEEDS_usually_33');
grant all on tickets_and_passes.* to tandpa@'%';

create database stations;

create user stations@'%' Identified by '30!leader!LARGE!party!40';	
grant SELECT on stations.* to stations@'%';

create user stationsa@'%'   Identified by '55/group/SHIP/then/76';
SET PASSWORD FOR stationsa@'%' = PASSWORD('55/group/SHIP/then/76');
grant all on stations.* to stationsa@'%';

create database bus;

create user bus@'%'  Identified by '40589.course.RADIO.montana.35';
grant SELECT on bus.* to bus@'%';

create user busa@'%' Identified by '59189:building:NEPTUNE:laugh:30';
grant all on bus.* to busa@'%'; 

SET PASSWORD FOR stationsa@'%' = PASSWORD('55/group/SHIP/then/76');
SET PASSWORD FOR tandpa@'%'    = PASSWORD('49_joined_SEEDS_usually_33');