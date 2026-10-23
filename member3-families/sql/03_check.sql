-- =====================================================================
-- 03_check.sql | Member 3 | Run AFTER the full build (00 to 06).
-- Every query below should return ZERO rows except the last one.
-- Any row returned points to a cast-list mismatch to fix.
-- =====================================================================

-- 1. Minors (age 6-16) with no guardian. The spec requires every minor
--    to be associated with a family member.
SELECT cm.MemberID, cm.FirstName, cm.LastName, cm.DOB
FROM ClubMembers cm
LEFT JOIN MinorGuardians mg ON mg.MemberID = cm.MemberID
WHERE TIMESTAMPDIFF(YEAR, cm.DOB, CURDATE()) BETWEEN 6 AND 16
  AND mg.MemberID IS NULL;

-- 2. Guardian rows pointing at members who were already major (17+)
--    when they joined the club, i.e. probably the wrong MemberID.
SELECT mg.MemberID, cm.FirstName, cm.LastName, cm.DOB, cm.JoinDate
FROM MinorGuardians mg
JOIN ClubMembers cm ON cm.MemberID = mg.MemberID
WHERE TIMESTAMPDIFF(YEAR, cm.DOB, cm.JoinDate) >= 17;

-- 3. Family members whose name matches a club member but whose SSN
--    does not, which silently breaks query vi.
SELECT fm.FamilyMemberID, fm.FirstName, fm.LastName,
       fm.SSN AS FamilySSN, cm.SSN AS MemberSSN
FROM FamilyMembers fm
JOIN ClubMembers cm
  ON cm.FirstName = fm.FirstName AND cm.LastName = fm.LastName
WHERE cm.SSN <> fm.SSN;

-- 4. Row counts for this slice (report section 5 needs >= 10 each).
SELECT 'FamilyMembers' AS TableName, COUNT(*) AS NumRows FROM FamilyMembers
UNION ALL
SELECT 'MinorGuardians', COUNT(*) FROM MinorGuardians;
