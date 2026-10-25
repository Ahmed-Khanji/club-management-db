-- Query vii: depends on Member 4's v_MemberStatus and Member 5's GameParticipations.
-- Confirm their exact column names during integration.
SELECT l.Name AS LocationName, pa.Role, cm.MemberID,
 cm.FirstName,cm.LastName,TIMESTAMPDIFF(YEAR,cm.DOB,CURDATE()) AS Age,
 mm.HeightCm AS Height,COUNT(DISTINCT gp.GameID) AS NBAGamesPlayed
FROM Personnel p
JOIN PersonnelAssignments pa ON pa.PersonnelID=p.PersonnelID AND pa.EndDate IS NULL AND pa.Mandate='Volunteer'
JOIN Locations l ON l.LocationID=pa.LocationID
JOIN ClubMembers cm ON cm.SSN=p.SSN
JOIN v_MemberStatus ms ON ms.MemberID=cm.MemberID AND ms.Status='active'
JOIN GameParticipations gp ON gp.MemberID=cm.MemberID
JOIN MemberMeasurements mm ON mm.MemberID=cm.MemberID
 AND mm.MeasureDate=(SELECT MAX(m2.MeasureDate) FROM MemberMeasurements m2 WHERE m2.MemberID=cm.MemberID)
GROUP BY l.Name,pa.Role,cm.MemberID,cm.FirstName,cm.LastName,cm.DOB,mm.HeightCm
ORDER BY l.Name ASC,pa.Role ASC;
