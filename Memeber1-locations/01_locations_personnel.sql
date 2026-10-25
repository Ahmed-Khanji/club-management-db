CREATE TABLE Locations (
 LocationID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 Type ENUM('Head','Branch') NOT NULL,
 Name VARCHAR(80) NOT NULL UNIQUE,
 Address VARCHAR(100) NOT NULL, City VARCHAR(50) NOT NULL,
 Province CHAR(2) NOT NULL, PostalCode CHAR(6) NOT NULL,
 WebAddress VARCHAR(150), MaxCapacity INT NOT NULL,
 CONSTRAINT ck_loc_capacity CHECK (MaxCapacity > 0)
);

CREATE TABLE LocationPhones (
 LocationID INT NOT NULL, Phone VARCHAR(15) NOT NULL,
 PRIMARY KEY (LocationID,Phone),
 FOREIGN KEY (LocationID) REFERENCES Locations(LocationID) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Personnel (
 PersonnelID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 FirstName VARCHAR(50) NOT NULL, LastName VARCHAR(50) NOT NULL,
 DOB DATE NOT NULL, SSN CHAR(9) NOT NULL UNIQUE,
 MedicareNo CHAR(12) NOT NULL UNIQUE, Phone VARCHAR(15) NOT NULL,
 Address VARCHAR(100) NOT NULL, City VARCHAR(50) NOT NULL,
 Province CHAR(2) NOT NULL, PostalCode CHAR(6) NOT NULL,
 Email VARCHAR(100),
 CONSTRAINT ck_personnel_ssn CHECK (SSN REGEXP '^[0-9]{9}$')
);

CREATE TABLE PersonnelAssignments (
 PersonnelID INT NOT NULL, LocationID INT NOT NULL,
 StartDate DATE NOT NULL, EndDate DATE NULL,
 Role ENUM('Administrator','Captain','Coach','Assistant Coach','Other') NOT NULL,
 Title VARCHAR(60) NOT NULL, Mandate ENUM('Volunteer','Salaried') NOT NULL,
 PRIMARY KEY (PersonnelID,StartDate),
 FOREIGN KEY (PersonnelID) REFERENCES Personnel(PersonnelID) ON UPDATE CASCADE ON DELETE RESTRICT,
 FOREIGN KEY (LocationID) REFERENCES Locations(LocationID) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT ck_assignment_dates CHECK (EndDate IS NULL OR EndDate >= StartDate)
);
-- Keep Locations 1-5 consistent with Members 2 and 3.
INSERT INTO Locations (LocationID,Type,Name,Address,City,Province,PostalCode,WebAddress,MaxCapacity) VALUES
 (1,'Head','Montréal','1200 Rue Sainte-Catherine O','Montréal','QC','H3G1P1','https://cbcs.example.org/location/1',350),
 (2,'Branch','Laval','45 Boulevard Le Carrefour','Laval','QC','H7T1C7','https://cbcs.example.org/location/2',220),
 (3,'Branch','Longueuil','88 Rue Saint-Charles O','Longueuil','QC','J4H1C9','https://cbcs.example.org/location/3',200),
 (4,'Branch','Québec','700 Grande Allée E','Québec','QC','G1R2K5','https://cbcs.example.org/location/4',210),
 (5,'Branch','Gatineau','25 Rue Laurier','Gatineau','QC','J8X3W9','https://cbcs.example.org/location/5',190),
 (6,'Branch','Sherbrooke','100 Rue King O','Sherbrooke','QC','J1H1P1','https://cbcs.example.org/location/6',150),
 (7,'Branch','Trois-Rivières','250 Rue des Forges','Trois-Rivières','QC','G9A2G8','https://cbcs.example.org/location/7',140),
 (8,'Branch','Brossard','9000 Boulevard Leduc','Brossard','QC','J4Y0E6','https://cbcs.example.org/location/8',160),
 (9,'Branch','Terrebonne','100 Boulevard des Seigneurs','Terrebonne','QC','J6W1T3','https://cbcs.example.org/location/9',130),
 (10,'Branch','Saint-Jérôme','10 Rue de Martigny O','Saint-Jérôme','QC','J7Y2E9','https://cbcs.example.org/location/10',120);

INSERT INTO LocationPhones (LocationID,Phone) VALUES
 (1,'514-555-2001'),
 (2,'450-555-2002'),
 (3,'450-555-2003'),
 (4,'418-555-2004'),
 (5,'819-555-2005'),
 (6,'819-555-2006'),
 (7,'819-555-2007'),
 (8,'514-555-2008'),
 (9,'450-555-2009'),
 (10,'450-555-2010'),
 (1,'514-555-2991'),
 (2,'450-555-2992');

-- Personnel 11-15 intentionally match major ClubMembers 5,6,7,9,10 by SSN and DOB.
INSERT INTO Personnel (PersonnelID,FirstName,LastName,DOB,SSN,MedicareNo,Phone,Address,City,Province,PostalCode,Email) VALUES
(1,'James','Smith','1982-04-18','400000001','PER000000001','514-555-3001','101 Rue Exemple','Montréal','QC','H3G1P1','JamesSmith@gmail.com'),
(2,'Christopher','Anderson','1978-06-09','400000002','PER000000002','514-555-3002','102 Rue Exemple','Laval','QC','H7T1C7','ChristopherAnderson@gmail.com'),
(3,'Ronald','Clark','1980-08-20','400000003','PER000000003','514-555-3003','103 Rue Exemple','Longueuil','QC','J4H1C9','RonaldClark@gmail.com'),
(4,'Mary','Wright','1986-01-16','400000004','PER000000004','514-555-3004','104 Rue Exemple','Québec','QC','G1R2K5','MaryWright@gmail.com'),
(5,'Lisa','Mitchell','1990-03-25','400000005','PER000000005','514-555-3005','105 Rue Exemple','Gatineau','QC','J8X3W9','LisaMitchell@gmail.com'),
(6,'Michelle','Johnson','1983-09-13','400000006','PER000000006','514-555-3006','106 Rue Exemple','Sherbrooke','QC','J1H1P1','MichelleJohnson@gmail.com'),
(7,'John','Thomas','1975-12-10','400000007','PER000000007','514-555-3007','107 Rue Exemple','Trois-Rivières','QC','G9A2G8','JohnThomas@gmail.com'),
(8,'Daniel','Rodriguez','1988-11-07','400000008','PER000000008','514-555-3008','108 Rue Exemple','Brossard','QC','J4Y0E6','DanielRodriguez@gmail.com'),
(9,'Anthony','Lopez','1981-07-21','400000009','PER000000009','514-555-3009','109 Rue Exemple','Terrebonne','QC','J6W1T3','AnthonyLopez@gmail.com'),
(10,'Patricia','Perez','1989-02-02','400000010','PER000000010','514-555-3010','110 Rue Exemple','Saint-Jérôme','QC','J7Y2E9','PatriciaPerez@gmail.com'),
(11,'Nadia','Rahman','1996-08-09','300000005','PER000000011','514-555-3011','111 Rue Exemple','Montréal','QC','H3G1P1','Nadia@Gmail.org'),
(12,'Omar','Khan','1999-04-12','300000006','PER000000012','514-555-3012','112 Rue Exemple','Laval','QC','H7T1C7','Omar@Gmail.org'),
(13,'Amelia','Chen','2002-07-12','300000007','PER000000013','514-555-3013','113 Rue Exemple','Longueuil','QC','J4H1C9','Amerlia@Gmail.org'),
(14,'Sarah','Wilson','1999-01-15','300000009','PER000000014','514-555-3014','114 Rue Exemple','Québec','QC','G1R2K5','Sarah@Gmail.org'),
(15,'Victor','Morin','1989-06-06','300000010','PER000000015','514-555-3015','115 Rue Exemple','Gatineau','QC','J8X3W9','Victor@Gmail.org'),
(16,'Emma','Laurent','1987-05-06','400000016','PER000000016','514-555-3016','116 Rue Exemple','Sherbrooke','QC','J1H1P1','Emma@Gmail.org'),
(17,'Luc','Martin','1991-06-11','400000017','PER000000017','514-555-3017','117 Rue Exemple','Trois-Rivières','QC','G9A2G8','Luc@Gmail.org');




INSERT INTO PersonnelAssignments (PersonnelID,LocationID,StartDate,EndDate,Role,Title,Mandate) VALUES
 (1,1,'2022-01-15','2022-06-30','Coach','Trainer','Salaried'),
 (1,2,'2022-07-05','2022-12-15','Coach','Trainer','Salaried'),
 (1,1,'2022-12-20',NULL,'Coach','Trainer','Salaried'),
 (2,1,'2023-01-01',NULL,'Administrator','General Manager','Salaried'),
 (3,1,'2023-01-01',NULL,'Administrator','Deputy Manager','Salaried'),
 (4,1,'2023-01-01',NULL,'Administrator','Treasurer','Salaried'),
 (5,1,'2023-01-01',NULL,'Administrator','Secretary','Salaried'),
 (6,1,'2023-01-01',NULL,'Administrator','Location Manager','Salaried'),
 (7,2,'2023-01-01',NULL,'Administrator','Location Manager','Salaried'),
 (8,3,'2023-01-01',NULL,'Administrator','Location Manager','Salaried'),
 (9,4,'2023-01-01',NULL,'Administrator','Location Manager','Salaried'),
 (10,5,'2023-01-01',NULL,'Administrator','Location Manager','Salaried'),
 (16,6,'2024-01-01',NULL,'Administrator','Location Manager','Salaried'),
 (17,7,'2024-01-01',NULL,'Administrator','Location Manager','Salaried'),
 (11,1,'2024-01-01',NULL,'Coach','Volunteer Coach','Volunteer'),
 (12,2,'2024-01-01',NULL,'Coach','Volunteer Coach','Volunteer'),
 (13,4,'2024-01-01',NULL,'Coach','Volunteer Coach','Volunteer'),
 (14,5,'2024-01-01',NULL,'Coach','Volunteer Coach','Volunteer'),
 (15,3,'2024-01-01',NULL,'Coach','Volunteer Coach','Volunteer');

-- Current managers for remaining branches (8-10) require additional personnel.
INSERT INTO Personnel (PersonnelID,FirstName,LastName,DOB,SSN,MedicareNo,Phone,Address,City,Province,PostalCode,Email) VALUES
 (18,'Alex','Perron','1980-01-02','400000018','PER000000018','514-555-3018','18 Rue Exemple','Brossard','QC','J4Y0E6','alex@example.org'),
 (19,'Mina','Bouchard','1981-02-03','400000019','PER000000019','450-555-3019','19 Rue Exemple','Terrebonne','QC','J6W1T3','mina@example.org'),
 (20,'Hugo','Côté','1982-03-04','400000020','PER000000020','450-555-3020','20 Rue Exemple','Saint-Jérôme','QC','J7Y2E9','hugo@example.org');

INSERT INTO PersonnelAssignments VALUES (18,8,'2024-01-01',NULL,'Administrator','Location Manager','Salaried'),(19,9,'2024-01-01',NULL,'Administrator','Location Manager','Salaried'),(20,10,'2024-01-01',NULL,'Administrator','Location Manager','Salaried');

