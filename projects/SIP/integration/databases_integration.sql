
create database tickets_and_passes;
create database stations;

create user stations@'%' Identified by '85/africa/MONDAY/report/19';
create user tandp@'%'    Identified by '80+oslo+FILL+king+23';

grant SELECT on tickets_and_passes.* to tandp@'%';
grant SELECT on stations.* to stations@'%';

create user stationsa@'%' Identified by '63:street:RAISED:nice:48';
create user tandpa@'%'    Identified by '95%crops%MATCH%have%22';


grant all on tickets_and_passes.* to tandpa@'%';
grant all on stations.* to stationsa@'%';

create database bus;

create user bus@'%'  Identified by '24392!line!COVERED!apple!75';
grant SELECT on bus.* to bus@'%';

create user busa@'%' Identified by '17126|amount|CATCH|salt|25';
grant all on bus.* to busa@'%'; 

flush privileges;
flush privileges;