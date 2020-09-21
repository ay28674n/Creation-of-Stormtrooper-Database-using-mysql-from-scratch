USE stormtrooper_java;



DROP TABLE IF EXISTS all_UnitData;
CREATE TABLE all_UnitData(
STUID VARCHAR(20),
STUnitInfo JSON,
CONSTRAINT pk_skj PRIMARY KEY(STUID));

DROP PROCEDURE IF EXISTS AU_Data  ;
DELIMITER //
CREATE PROCEDURE AU_Data()

BEGIN

     DECLARE COUNT INT; DECLARE ROWS INT;DECLARE BID VARCHAR(20); 
     DECLARE BDESIGNATION VARCHAR(20); DECLARE BLOCX INT;
     DECLARE BLOCY INT; DECLARE SID VARCHAR(20); DECLARE STYPE VARCHAR(20);
     DECLARE SSTRENGTH VARCHAR(20); DECLARE SLOCX INT; DECLARE SLOCY INT;
     DECLARE O1 JSON; DECLARE STUnitInfo JSON;




     DECLARE A CURSOR FOR
     SELECT IBG.BGID,IBG.Designation,IBG.HQ_LocationX,IBG.HQ_LocationY,
     SU.STUID,SU.UnitType,SU.AssignedStrength,SU.Location_X,SU.Location_Y FROM 
     imperial_battlegroup as IBG JOIN stormtrooper_unit as SU ON IBG.BGID=SU.UnitCmd;



     SET COUNT=0;
     OPEN A;
     SELECT FOUND_ROWS() INTO ROWS ;
     WHILE COUNT<ROWS DO
       FETCH A INTO BID, BDESIGNATION,BLOCX,BLOCY,SID,STYPE,SSTRENGTH,SLOCX,SLOCY;
       SET O1=JSON_OBJECT('A',BID,'B',BDESIGNATION,'C',BLOCX,'D',BLOCY,'E',SID,'F',STYPE,'G',SSTRENGTH,'H',SLOCX,'I',SLOCY);
       INSERT INTO all_UnitData VALUES(SID,O1);
       SET COUNT=COUNT+1;
     END WHILE;

     CLOSE A;
     SELECT * FROM all_UnitData LIMIT 5;


END //
DELIMITER ;

CALL AU_Data();



DROP TABLE IF EXISTS all_TrooperData;
CREATE TABLE all_TrooperData(
STUID VARCHAR(20),
TrooperInfo JSON,
CONSTRAINT pk_skj PRIMARY KEY(STUID));


DROP PROCEDURE IF EXISTS AT_Data;
DELIMITER //
CREATE PROCEDURE AT_Data ()

BEGIN
    DECLARE COUNT INT; DECLARE ROWS INT;DECLARE SID VARCHAR(20);DECLARE SUID VARCHAR(20);DECLARE SROLE VARCHAR(20);DECLARE SFRANK VARCHAR(20);
    DECLARE SFGENDER VARCHAR(20);DECLARE SFSERVICEYEARS INT;
    DECLARE SFH INT;DECLARE SFW INT; DECLARE SFDC VARCHAR(20); DECLARE SFDS VARCHAR(20); DECLARE O1 JSON;
    



    DECLARE B CURSOR FOR
     SELECT st_officer_assign.STID,stormtroopers_officer.Rank,stormtroopers_officer.Gender,stormtroopers_officer.ServiceYears,
    stormtroopers_officer.Height,stormtroopers_officer.Weight,stormtroopers_officer.DutyCategory,stormtroopers_officer.DutyStatus,
    st_officer_assign.STUID,st_officer_assign.Role
    FROM st_officer_assign JOIN stormtroopers_officer ON 
    st_officer_assign.stid=stormtroopers_officer.STID UNION ALL
SELECT st_nco_assign.STID,stormtroopers_nco.Rank,stormtroopers_nco.Gender,stormtroopers_nco.ServiceYears,
    stormtroopers_nco.Height,stormtroopers_nco.Weight,stormtroopers_nco.DutyCategory,stormtroopers_nco.DutyStatus,
    st_nco_assign.STUID,st_nco_assign.Role
    FROM st_nco_assign JOIN stormtroopers_nco ON 
    st_nco_assign.STID=stormtroopers_nco.STID UNION ALL
SELECT st_troop_assign.STID,stormtroopers_troop.Rank,stormtroopers_troop.Gender,stormtroopers_troop.ServiceYears,
    stormtroopers_troop.Height,stormtroopers_troop.Weight,stormtroopers_troop.DutyCategory,stormtroopers_troop.DutyStatus,
    st_troop_assign.STUID,st_troop_assign.Role
    FROM st_troop_assign JOIN stormtroopers_troop ON 
    st_troop_assign.STID=stormtroopers_troop.STID;
 

  



    SET COUNT=0;
    OPEN B;
    SELECT FOUND_ROWS() INTO ROWS ;
    WHILE COUNT<ROWS DO
        FETCH B INTO SID,SFRANK,SFGENDER,SFSERVICEYEARS,SFH,SFW,SFDC,SFDS,SUID,SROLE;
        SET O1=JSON_OBJECT('A',SID,'B',SFRANK,'C',SFGENDER,'D',SFSERVICEYEARS,'E',SFH,'F',SFW,'G',SFDC,'H',SFDS,'I',SUID,'J',SROLE);
        INSERT INTO all_TrooperData VALUES(SID,O1);
        SET COUNT=COUNT+1;
    END WHILE;
    CLOSE B;
    SELECT * FROM all_TrooperData LIMIT 5;

END //
DELIMITER ;





CALL AT_Data();





DROP PROCEDURE IF EXISTS UnitRebuildCost  ;
DELIMITER //
CREATE PROCEDURE UnitRebuildCost(STUID VARCHAR(20))

BEGIN
    
    DECLARE BR VARCHAR(20); DECLARE JR VARCHAR(20); DECLARE GDC VARCHAR(20); DECLARE EH INT; DECLARE FW INT; DECLARE CG VARCHAR(20) ; DECLARE ICOMM VARCHAR(20); DECLARE BBG VARCHAR(20); DECLARE ECOMM VARCHAR(20);
    DECLARE ROL INT; DECLARE DC INT; DECLARE OFF INT; DECLARE WEIGH int; DECLARE HEIG int; DECLARE COUNT INT; DECLARE ROWS INT;
    DECLARE CRep INT; DECLARE GEN  VARCHAR(20); DECLARE IDS VARCHAR(20); DECLARE ID VARCHAR(20); DECLARE ID1 VARCHAR(20) ; DECLARE ED VARCHAR(20); DECLARE CReb int; DECLARE SN VARCHAR(20); DECLARE STUID1 VARCHAR(20);

    DECLARE C CURSOR FOR
    select  au.STUID, JSON_EXTRACT(at.TrooperInfo,'$.B') as B ,  JSON_EXTRACT(at.TrooperInfo,'$.J') as J ,   JSON_EXTRACT(at.TrooperInfo,'$.G') as G, JSON_EXTRACT(at.TrooperInfo,'$.E') as E, 
       JSON_EXTRACT(at.TrooperInfo,'$.F') as F, JSON_EXTRACT(at.TrooperInfo,'$.C') as C ,JSON_EXTRACT(at.TrooperInfo,'$.I') as I,JSON_EXTRACT(at.TrooperInfo,'$.H') as IDS ,
      JSON_EXTRACT(au.STUnitInfo,'$.B')  as BattleGroup, 
       JSON_EXTRACT(au.STUnitInfo,'$.E') as ED
       FROM  all_UnitData  au JOIN all_TrooperData at
         ON  JSON_EXTRACT(at.TrooperInfo,'$.I')= JSON_EXTRACT(au.STUnitInfo,'$.E') WHERE JSON_EXTRACT(at.TrooperInfo,'$.I')  IN (au.STUID) and at.TrooperInfo->>"$.H" in ('Killed','Wounded');
         

DROP TABLE IF EXISTS ST_UNIT_JSON3;
    CREATE TABLE ST_UNIT_JSON3(
    STUID2 VARCHAR(20) NOT NULL,
    Rank VARCHAR(20) NOT NULL,
    Role VARCHAR(20) NOT NULL,
    DutyCategory VARCHAR(20),
    Height INT NOT NULL,
    Weight  INT NOT NULL,
    GENDER VARCHAR(20),
    CostToReplace INT NOT NULL,
    CostToRebuild INT,
    ID VARCHAR(20) 


    );   

   SET COUNT=0;
    OPEN C;
    SELECT FOUND_ROWS() INTO ROWS ;
    WHILE COUNT<ROWS DO
        FETCH C INTO STUID1, BR,JR,GDC,EH,FW,CG,ID1,IDS,BBG,ID;

        IF BR='LT' OR BR='CAPT' OR BR='CMDR' THEN
           SET OFF=10;
        ELSE
           SET OFF=5;
        END IF;
        
        IF JR='Assault' THEN
           SET ROL=15;
        ELSE
           SET ROL=10;
        END IF;
        IF GDC='Active' THEN
          SET DC=10;
        ELSE
          SET DC=5;
        END IF;
        SET HEIG=EH*2;
        SET WEIGH =FW*8;
        IF CG='Female' THEN
          SET GEN=25;
        ELSE
          SET GEN=20;
        END IF;
        SET CRep = ROL + OFF + DC + GEN + HEIG + WEIGH;
        IF BBG = 'Battle Group I' THEN
          SET CReb = CRep + 50;
        ELSE
          SET CReb=CRep;
        END IF;
        INSERT INTO ST_UNIT_JSON3 VALUES(STUID1,BR,JR,GDC,EH,FW,CG,CRep,CReb,ID1);
        SET COUNT=COUNT+1;


    END WHILE;
    CLOSE C;

        SELECT SUM(CostToRebuild) AS "UnitRebuildCost", STUID2 from ST_UNIT_JSON3 WHERE STUID2 in (STUID) LIMIT 1 ;

END //
DELIMITER ;


CALL UnitRebuildCost("STU-1");
CALL UnitRebuildCost("STU-20");
call UnitRebuildCost('STU-10');