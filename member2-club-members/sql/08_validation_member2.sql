-- Run AFTER the combined build (Member 1 + 2 + 3, plus other members' tables).
-- Each check is PASS when the exception count is 0 (or row count >=10).
SELECT 'ClubMembers count >= 10' AS Test, COUNT(*) AS Observed,
       IF(COUNT(*) >=10,'PASS','FAIL') AS Result FROM ClubMembers;
SELECT 'Hobbies count >= 10' AS Test, COUNT(*) AS Observed,
       IF(COUNT(*) >=10,'PASS','FAIL') AS Result FROM Hobbies;
SELECT 'MemberHobbies count >= 10' AS Test, COUNT(*) AS Observed,
       IF(COUNT(*) >=10,'PASS','FAIL') AS Result FROM MemberHobbies;
SELECT 'MemberMeasurements count >= 10' AS Test, COUNT(*) AS Observed,
       IF(COUNT(*) >=10,'PASS','FAIL') AS Result FROM MemberMeasurements;
SELECT 'No club member lacks yearly measurements 2023-2026 from joined year' AS Test,
       COUNT(*) AS Observed,
       IF(COUNT(*)=0,'PASS','FAIL') AS Result
FROM ClubMembers c
WHERE EXISTS (SELECT 1 FROM (
    SELECT 2023 AS Yr UNION ALL SELECT 2024 UNION ALL SELECT 2025 UNION ALL SELECT 2026
) years WHERE years.Yr BETWEEN YEAR(c.JoinDate) AND 2026
AND NOT EXISTS(SELECT 1 FROM MemberMeasurements m
               WHERE m.MemberID=c.MemberID AND YEAR(m.MeasureDate)=years.Yr));
SELECT 'All minor IDs 11-22 have valid guardian' AS Test, COUNT(*) AS Observed,
       IF(COUNT(*)=0,'PASS','FAIL') AS Result
FROM ClubMembers c LEFT JOIN MinorGuardians mg ON c.MemberID=mg.MemberID
WHERE TIMESTAMPDIFF(YEAR,c.DOB,CURDATE()) BETWEEN 6 AND 16 AND mg.MemberID IS NULL;
SELECT 'All guardian IDs point to minors today' AS Test, COUNT(*) AS Observed,
       IF(COUNT(*)=0,'PASS','FAIL') AS Result
FROM MinorGuardians mg JOIN ClubMembers c ON c.MemberID=mg.MemberID
WHERE TIMESTAMPDIFF(YEAR,c.DOB,CURDATE()) NOT BETWEEN 6 AND 16;
SELECT 'Member3 parent SSN/name/DOB match club member' AS Test,
       COUNT(*) AS Observed, IF(COUNT(*)=0,'PASS','FAIL') AS Result
FROM FamilyMembers f JOIN ClubMembers c ON f.SSN=c.SSN
WHERE f.FirstName<>c.FirstName OR f.LastName<>c.LastName OR f.DOB<>c.DOB;
SELECT 'Every member has one latest measurement row' AS Test,
       COUNT(*) AS Observed, IF(COUNT(*)=0,'PASS','FAIL') AS Result
FROM (SELECT c.MemberID FROM ClubMembers c
      LEFT JOIN v_LatestMeasurement v ON c.MemberID=v.MemberID
      GROUP BY c.MemberID HAVING COUNT(v.MemberID)<>1) BadLatest;
SELECT 'Family-based query vi has >=2 qualifying adults (requires games)' AS Test,
       COUNT(DISTINCT c.MemberID) AS Observed,
       IF(COUNT(DISTINCT c.MemberID)>=2,'PASS','FAIL') AS Result
FROM ClubMembers c JOIN FamilyMembers f ON f.SSN=c.SSN
JOIN MinorGuardians mg ON mg.FamilyMemberID=f.FamilyMemberID
JOIN GameParticipations gp ON gp.MemberID=c.MemberID
WHERE TIMESTAMPDIFF(YEAR,c.DOB,CURDATE())>=17;
SELECT 'ClubMembers' AS TableName,COUNT(*) AS Rows FROM ClubMembers
UNION ALL SELECT 'Hobbies',COUNT(*) FROM Hobbies
UNION ALL SELECT 'MemberHobbies',COUNT(*) FROM MemberHobbies
UNION ALL SELECT 'MemberMeasurements',COUNT(*) FROM MemberMeasurements;
-- Violation details (expected zero rows):
SELECT c.MemberID, c.FirstName, c.LastName, c.DOB
FROM ClubMembers c LEFT JOIN MinorGuardians mg ON mg.MemberID=c.MemberID
WHERE TIMESTAMPDIFF(YEAR,c.DOB,CURDATE()) BETWEEN 6 AND 16
  AND mg.MemberID IS NULL;
