-- =====================================================================
-- 03_check.sql | Member 3 | Run AFTER the full build (00 to 06).
-- Every query below should return ZERO rows except the last one.
-- Any row returned points to a cast-list mismatch to fix.
-- =====================================================================

-- 1. Minors (age 6-16) with no guardian. The spec requires every minor
--    to be associated with a family member.
SELECT cm.memberID, cm.firstName, cm.lastName, cm.DOB
FROM ClubMembers cm
LEFT JOIN MinorGuardians mg ON mg.memberID = cm.memberID
WHERE TIMESTAMPDIFF(YEAR, cm.DOB, CURDATE()) BETWEEN 6 AND 16
  AND mg.memberID IS NULL;

-- 2. Guardian rows pointing at members who were already major (17+)
--    when they joined the club, i.e. probably the wrong memberID.
SELECT mg.memberID, cm.firstName, cm.lastName, cm.DOB, cm.joinDate
FROM MinorGuardians mg
JOIN ClubMembers cm ON cm.memberID = mg.memberID
WHERE TIMESTAMPDIFF(YEAR, cm.DOB, cm.joinDate) >= 17;

-- 3. Family members whose name matches a club member but whose SSN
--    does not, which silently breaks query vi.
SELECT fm.familyMemberID, fm.firstName, fm.lastName,
       fm.SSN AS familySSN, cm.SSN AS memberSSN
FROM FamilyMembers fm
JOIN ClubMembers cm
  ON cm.firstName = fm.firstName AND cm.lastName = fm.lastName
WHERE cm.SSN <> fm.SSN;

-- 4. Row counts for this slice (report section 5 needs >= 10 each).
SELECT 'FamilyMembers' AS tableName, COUNT(*) AS numRows FROM FamilyMembers
UNION ALL
SELECT 'MinorGuardians', COUNT(*) FROM MinorGuardians;
