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
    l.name                                   AS locationName,
    cm.memberID                              AS membershipNum,
    cm.firstName,
    cm.lastName,
    TIMESTAMPDIFF(YEAR, cm.DOB, CURDATE())   AS age,
    cm.city,
    cm.province,
    COALESCE(s.status, 'Inactive')           AS status,
    lm.heightCm,
    lm.weightKg,
    kids.numChildren,
    games.numGames
FROM ClubMembers AS cm
JOIN Locations   AS l  ON l.locationID = cm.locationID
JOIN (
        SELECT fm.SSN, COUNT(*) AS numChildren
        FROM FamilyMembers  AS fm
        JOIN MinorGuardians AS mg ON mg.familyMemberID = fm.familyMemberID
        GROUP BY fm.SSN
     ) AS kids  ON kids.SSN = cm.SSN
JOIN (
        SELECT gp.memberID, COUNT(*) AS numGames
        FROM GameParticipations AS gp
        GROUP BY gp.memberID
     ) AS games ON games.memberID = cm.memberID
LEFT JOIN v_MemberStatus      AS s  ON s.memberID  = cm.memberID
LEFT JOIN v_LatestMeasurement AS lm ON lm.memberID = cm.memberID
WHERE TIMESTAMPDIFF(YEAR, cm.DOB, CURDATE()) >= 17
ORDER BY locationName ASC, age ASC;
