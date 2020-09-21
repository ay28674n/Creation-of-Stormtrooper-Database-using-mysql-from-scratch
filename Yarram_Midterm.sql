DROP DATABASE IF EXISTS paceWSN;
CREATE DATABASE IF NOT EXISTS paceWSN;

USE paceWSN;



CREATE TABLE IF NOT EXISTS NODE_TYPE(
NType CHAR(100) NOT NULL,
Manufacturer CHAR(100),
Cost Decimal(10,2),
ServiceLife INT,
CostLifeRatio Decimal(10,2) GENERATED ALWAYS AS (Cost/ServiceLife) STORED,

CONSTRAINT pk_NODE_TYPE PRIMARY KEY(NType)
);

CREATE TABLE IF NOT EXISTS NODE(
IDNumber VARCHAR(30) NOT NULL,
NType CHAR(100) NOT NULL,
Location_X INT,
Location_Y INT,
NStatus   ENUM('Online','Offline') NOT NULL DEFAULT 'Online',
AccessDistance Decimal(10,2) generated always as (sqrt(pow(location_X - 100, 2) + pow(location_Y - 100, 2))) stored,
CONSTRAINT pk_NODE PRIMARY KEY(IDNumber),
CONSTRAINT fk1_NODE FOREIGN KEY(NType) REFERENCES NODE_TYPE(NType)

);



CREATE TABLE IF NOT EXISTS NODE_NETWORK(
IDNumber VARCHAR(30) NOT NULL,
Network_A  ENUM('C','N') NOT NULL  ,
Network_B  ENUM('C','N') NOT NULL ,
Network_C  ENUM('C','N') NOT NULL ,
CONSTRAINT pk_NODE_NETWORK PRIMARY KEY(IDNumber),
CONSTRAINT fk1_NODE_NETWORK FOREIGN KEY(IDNumber) REFERENCES NODE(IDNumber)
);




CREATE TABLE IF NOT EXISTS NETWORKS(
Name VARCHAR(30) NOT NULL,
NET_Type CHAR(100) NOT NULL,
CONSTRAINT pk_NETWORKS PRIMARY KEY(Name)
);


CREATE TABLE IF NOT EXISTS NETWORK_GATEWAY(
Network_Name VARCHAR(30) NOT NULL,
NET_Type VARCHAR(30) NOT NULL,
CONSTRAINT pk_NETWORK_GATEWAY PRIMARY KEY(Network_Name),
CONSTRAINT fk1_NETWORK_GATEWAY FOREIGN KEY(NET_Type) REFERENCES NODE_NETWORK(IDNumber)

);

CREATE TABLE IF NOT EXISTS NODE_BATTERY(
NType VARCHAR(30) NOT NULL,
Battery CHAR(100) NOT NULL,
CONSTRAINT pk_NODE_BATTERY PRIMARY KEY(NType),
CONSTRAINT fk1_NODE_BATTERY FOREIGN KEY(NType) REFERENCES NODE(NType)
);





CREATE TABLE IF NOT EXISTS NETWORK_TRANSMISSION(
Name VARCHAR(30) NOT NULL,
Link_Band VARCHAR(100) NOT NULL,
Link_Type CHAR(100),
CONSTRAINT pk_NETWORK_TRANSMISSION PRIMARY KEY(Name),
CONSTRAINT fk1_NETWORK_TRANSMISSION FOREIGN KEY(Name) REFERENCES NETWORKS(Name)
);


source C:\Users\Arun\Desktop\Hilberclass\Midterm-Exam\populatePaceWSN.sql


#1,What is the ratio of offline to online nodes in all networks.

Select sum(NStatus='Offline')/sum(NStatus='Online') as 'Offline-Online Ratio' from NODE;



#2,Which nodes are connected to Network A but not to Network C.

Select IDNumber, Network_A, Network_C From NODE_NETWORK
Where Network_A = 'C' and Network_C = 'N';



#3 List all  nodes that are offline in Network A.

SELECT NODE.IDNumber as 'Node ID',NODE_NETWORK.Network_A as 'Connected To Network A' ,NODE.NStatus as 'Current Node Status'
FROM NODE INNER JOIN NODE_NETWORK ON NODE_NETWORK.IDNumber=NODE.IDNumber  WHERE NStatus='Offline' and NODE_NETWORK.Network_A='C';




#4,List the status of all  nodes in Network A manufactured by General Dynamics

SELECT NODE.IDNumber as 'Node ID',NODE_TYPE.NType as 'Node Type' ,NODE_TYPE.Manufacturer as 'Built By',
NODE_NETWORK.Network_A as 'Connected To Network A',NODE.NStatus as 'Current Node Status'
FROM NODE INNER JOIN NODE_TYPE ON NODE.NType=NODE_TYPE.NType INNER JOIN NODE_NETWORK ON NODE_NETWORK.IDNumber=NODE.IDNumber
 WHERE NODE_NETWORK.Network_A='C' and NODE_TYPE.Manufacturer='General Dynamics' and NODE_TYPE.NType='A' order by NODE_NETWORK.IDNumber;






#5,List any Type ‘C’ node that is more than 120 km but less than 135 km from the Master Node.
Select IDNumber as 'Node ID', NODE.NType as 'Node Type', (concat('[', Location_X, '-', Location_Y, ']')) as 'Coordinates', (concat(AccessDistance, ' KM')) as 'Distance to Master Node', (concat(Battery, ' Battery')) as 'Battery Used'
from NODE, NODE_BATTERY
where NODE_BATTERY.NType = NODE.NType and AccessDistance > 120 and AccessDistance < 135 and NODE.NType = 'C'
order by IDNumber;