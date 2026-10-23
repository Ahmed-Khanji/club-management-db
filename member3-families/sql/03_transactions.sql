-- =====================================================================
-- 03_transactions.sql | Member 3 | Families slice
-- Example transactions (INSERT / UPDATE / DELETE) on FamilyMembers and
-- MinorGuardians. Run after the full build. Each block is atomic.
-- Run them in order: T3 relies on the row added in T1.
-- =====================================================================

-- T1. Register a new family member (must exist before a minor can be
--     registered under them).
START TRANSACTION;
INSERT INTO FamilyMembers
  (FamilyMemberID, FirstName, LastName, DOB, SSN, MedicareNo, Phone,
   Address, City, Province, PostalCode, Email, LocationID)
VALUES
  (13, 'Hélène', 'Lavoie', '1958-04-30', '200000013', 'LAVH58543011', '450-555-0113',
   '77 Rue des Érables', 'Laval', 'QC', 'H7G2R1', 'helene.lavoie@mail.ca', 2);
COMMIT;

-- T2. A family member moves to another location (the spec allows a
--     family member to be associated with different locations over time).
START TRANSACTION;
UPDATE FamilyMembers
SET    LocationID = 3,
       Address    = '15 Chemin de Chambly',
       City       = 'Longueuil',
       PostalCode = 'J4H3L1'
WHERE  FamilyMemberID = 9;
COMMIT;

-- T3. A minor changes family member (the spec allows a minor to be
--     associated with different family members over time).
--     Chloé Lavoie (member 17) moves from her grandfather to her
--     grandmother. (Uses a minor outside query vi, so vi is unaffected.)
START TRANSACTION;
UPDATE MinorGuardians
SET    FamilyMemberID = 13,
       Relationship   = 'Grandmother'
WHERE  MemberID = 17;
COMMIT;

-- T4. Remove a family member who no longer has any minor linked to
--     them. The NOT EXISTS guard makes the delete a no-op otherwise;
--     the foreign key (ON DELETE RESTRICT) would also refuse it.
START TRANSACTION;
DELETE FROM FamilyMembers
WHERE  FamilyMemberID = 11
  AND  NOT EXISTS (SELECT 1 FROM MinorGuardians mg
                   WHERE mg.FamilyMemberID = 11);
COMMIT;

-- Check the effect of T1 to T4.
SELECT fm.FamilyMemberID, fm.FirstName, fm.LastName, fm.City, fm.LocationID,
       COUNT(mg.MemberID) AS NumMinors
FROM FamilyMembers fm
LEFT JOIN MinorGuardians mg ON mg.FamilyMemberID = fm.FamilyMemberID
GROUP BY fm.FamilyMemberID, fm.FirstName, fm.LastName, fm.City, fm.LocationID
ORDER BY fm.FamilyMemberID;
