-- MEMBER 2 queries iii and iv; place within final 07_queries.sql.
-- Prerequisites: group scripts 01-06 and the views v_MemberStatus,
-- v_LatestMeasurement. Uses *actual Member 3* MinorGuardians and FamilyMembers.
-- MySQL 8.0+: parameters may be changed by the instructor.

-- Query iii: for a chosen club member. Multiple SELECTs are explicitly allowed.
SET @MemberID = 11;  -- Léa Tremblay; current Member 3 guardian row: MemberID 11 -> FamilyMemberID 1

-- iii A: full member profile and status
SELECT c.MemberID, c.FirstName, c.LastName, c.DOB, c.JoinDate,
       c.SSN, c.MedicareNo, c.Phone, c.Address, c.City,
       c.Province, c.PostalCode, COALESCE(s.Status, 'Inactive') AS Status,
       lm.HeightCm, lm.WeightKg
FROM ClubMembers c
LEFT JOIN v_MemberStatus s ON s.MemberID=c.MemberID
LEFT JOIN v_LatestMeasurement lm ON lm.MemberID=c.MemberID
WHERE c.MemberID=@MemberID;

-- iii B: 0 or more hobbies
SELECT h.Name AS Hobby
FROM MemberHobbies mh JOIN Hobbies h ON h.HobbyID=mh.HobbyID
WHERE mh.MemberID=@MemberID ORDER BY h.Name;

-- iii C: complete measurement history
SELECT MeasureDate, HeightCm, WeightKg FROM MemberMeasurements
WHERE MemberID=@MemberID ORDER BY MeasureDate;

-- iii D: assigned guardian when one exists (should be one for minors)
SELECT f.FamilyMemberID, f.FirstName AS GuardianFirstName,
       f.LastName AS GuardianLastName, mg.Relationship
FROM MinorGuardians mg
JOIN FamilyMembers f ON f.FamilyMemberID=mg.FamilyMemberID
WHERE mg.MemberID=@MemberID;

-- iii E: payments made during last 2 years (not just membershipYear)
SELECT p.PaymentDate, p.MembershipYear, p.Amount, p.Method, p.InstallmentNum
FROM Payments p
WHERE p.MemberID=@MemberID
  AND p.PaymentDate BETWEEN DATE_SUB(CURDATE(), INTERVAL 2 YEAR) AND CURDATE()
ORDER BY p.PaymentDate DESC, p.PaymentID DESC;

-- Query iv: for one supplied location; all members, including those with no games/hobbies.
SET @LocationID = 1;  -- 1 = Montréal in Member 3's current placeholder cast
SELECT c.MemberID, c.FirstName, c.LastName,
       TIMESTAMPDIFF(YEAR,c.DOB,CURDATE()) AS Age,
       COALESCE(h.HobbyCount,0) AS NumberOfHobbies,
       COALESCE(s.Status,'Inactive') AS Status,
       lm.HeightCm, lm.WeightKg,
       COALESCE(g.GameCount,0) AS TotalNBAGames
FROM ClubMembers c
LEFT JOIN (SELECT MemberID,COUNT(*) AS HobbyCount FROM MemberHobbies GROUP BY MemberID) h
  ON h.MemberID=c.MemberID
LEFT JOIN v_MemberStatus s ON s.MemberID=c.MemberID
LEFT JOIN v_LatestMeasurement lm ON lm.MemberID=c.MemberID
LEFT JOIN (SELECT MemberID, COUNT(*) AS GameCount
           FROM GameParticipations GROUP BY MemberID) g ON g.MemberID=c.MemberID
WHERE c.LocationID=@LocationID
ORDER BY Age ASC, lm.HeightCm ASC, lm.WeightKg ASC;
