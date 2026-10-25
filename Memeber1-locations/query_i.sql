-- Query i: run after all tables, payments, and NBA participation data exist.
-- Counts use independent subqueries to avoid multiplication from phones/assignments/games.
SELECT l.LocationID, l.Name, l.Address, l.City, l.Province,
 l.PostalCode, (SELECT GROUP_CONCAT(lp.Phone ORDER BY lp.Phone SEPARATOR ', ')
 FROM LocationPhones lp WHERE lp.LocationID=l.LocationID) AS PhoneNumbers,
 l.WebAddress,l.Type,l.MaxCapacity,
 (SELECT CONCAT(p.FirstName,' ',p.LastName) FROM PersonnelAssignments pa
 JOIN Personnel p ON p.PersonnelID=pa.PersonnelID
 WHERE pa.LocationID=l.LocationID AND pa.EndDate IS NULL
 AND pa.Title IN ('General Manager','Location Manager')
 ORDER BY (pa.Title='General Manager') DESC, pa.PersonnelID LIMIT 1) AS ManagerName,
 (SELECT COUNT(*) FROM PersonnelAssignments pa WHERE pa.LocationID=l.LocationID AND pa.EndDate IS NULL) AS NumberOfPersonnel,
 (SELECT COUNT(*) FROM ClubMembers cm WHERE cm.LocationID=l.LocationID) AS NumberOfClubMembers,
 (SELECT COUNT(DISTINCT cm.MemberID) FROM ClubMembers cm
 JOIN GameParticipations gp ON gp.MemberID=cm.MemberID
 WHERE cm.LocationID=l.LocationID) AS MembersWithNBAGames
FROM Locations l
ORDER BY l.Name ASC, NumberOfClubMembers ASC;
