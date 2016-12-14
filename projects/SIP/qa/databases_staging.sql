
create database tickets_and_passes;
create database stations;

create user stations@'%' Identified by '==23:many:NUMBER:america:25==';
create user tandp@'%'    Identified by '^^41?decided?MARKET?story?41^^';

grant SELECT on tickets_and_passes.* to tandp@'%';
grant SELECT on stations.* to stations@'%';

create user stationsa@'%' Identified by '--83%cotton%GUESS%weight%91--';
create user tandpa@'%'    Identified by '||38&guard&WELCOME&mail&53||';


grant all on tickets_and_passes.* to tandpa@'%';
grant all on stations.* to stationsa@'%';


create database bus;

create user bus@'%'  Identified by '22!true!OFTEN!himself!70';
grant SELECT on bus.* to bus@'%';

create user busa@'%' Identified by '55;music;PICKED;drive;23';
grant all on bus.* to busa@'%'; 