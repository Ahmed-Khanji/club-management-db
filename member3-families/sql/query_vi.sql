-- =====================================================================
-- Query vi  |  Owner: Member 3
-- Major club members who have played in at least one NBA game AND have
-- at least one child registered as a club member.
-- Output: current location name, membership number, first name,
-- last name, age, city, province, status (active/inactive), height,
-- weight, number of children, number of NBA games.
-- Sorted by location name, then age (both ascending).
--
-- How "has a child" is found: a family member who registered a minor
-- (MinorGuardians) is matched to the club member with the same SSN
-- (schema contract, decision 2). Every minor linked to that family
-- member counts as one of their children, whatever the relationship.
-- Uses: v_MemberStatus (Member 4), v_LatestMeasurement (Member 2),
--       the shared age formula TIMESTAMPDIFF(YEAR, DOB, CURDATE()).
-- The two counts are computed in separate derived tables so that the
-- joins cannot multiply each other (2 children x 3 games != 6).
-- =====================================================================
SELECT
    l.Name                                   AS LocationName,
    cm.MemberID                              AS MembershipNo,
    cm.FirstName,
    cm.LastName,
    TIMESTAMPDIFF(YEAR, cm.DOB, CURDATE())   AS Age,
    cm.City,
    cm.Province,
    COALESCE(s.Status, 'Inactive')           AS Status,
    lm.HeightCm,
    lm.WeightKg,
    kids.NumChildren,
    games.NumGames
FROM ClubMembers AS cm
JOIN Locations   AS l  ON l.LocationID = cm.LocationID
JOIN (
        SELECT fm.SSN, COUNT(*) AS NumChildren
        FROM FamilyMembers  AS fm
        JOIN MinorGuardians AS mg ON mg.FamilyMemberID = fm.FamilyMemberID
        GROUP BY fm.SSN
     ) AS kids  ON kids.SSN = cm.SSN
JOIN (
        SELECT gp.MemberID, COUNT(*) AS NumGames
        FROM GameParticipations AS gp
        GROUP BY gp.MemberID
     ) AS games ON games.MemberID = cm.MemberID
LEFT JOIN v_MemberStatus      AS s  ON s.MemberID  = cm.MemberID
LEFT JOIN v_LatestMeasurement AS lm ON lm.MemberID = cm.MemberID
WHERE TIMESTAMPDIFF(YEAR, cm.DOB, CURDATE()) >= 17
ORDER BY LocationName ASC, Age ASC;
