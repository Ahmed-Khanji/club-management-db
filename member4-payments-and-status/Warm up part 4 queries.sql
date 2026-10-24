-- Query viii
-- ----------
SELECT L.`name` AS location,
    COALESCE(SUM(LEAST(T.totalPaid, 100.00)), 0.00) AS membershipFeesPaid,
    COALESCE(SUM(GREATEST(T.totalPaid - 100.00, 0.00)), 0.00) AS donations
FROM Locations L
    LEFT OUTER JOIN (
        SELECT C.locationID, P.memberID, SUM(P.amount) AS totalPaid
        FROM Payments P, ClubMembers C
        WHERE P.memberID = C.memberID
            AND P.membershipYear = 2025
            AND TIMESTAMPDIFF(YEAR, C.DOB, '2025-01-01') < 17
        GROUP BY C.locationID, P.memberID
    ) AS T
        ON T.locationID = L.locationID
GROUP BY L.locationID, L.`name`
ORDER BY L.`name`;


-- Query ix
-- --------
SELECT L.`name` AS location, C.memberID, C.firstName, C.lastName,
    TIMESTAMPDIFF(YEAR, C.DOB, CURDATE()) AS age,
    C.city, C.province
FROM ClubMembers C, Locations L
WHERE C.locationID = L.locationID
    AND C.memberID IN (
        SELECT P.memberID
        FROM Payments P, ClubMembers M
        WHERE P.memberID = M.memberID
            AND P.membershipYear = YEAR(CURDATE()) - 1
        GROUP BY P.memberID, M.DOB
        HAVING SUM(P.amount) >= 200.00
            OR (SUM(P.amount) >= 100.00
                AND TIMESTAMPDIFF(YEAR, M.DOB, MAKEDATE(YEAR(CURDATE()) - 1, 1)) < 17)
    )
    AND C.memberID NOT IN (
        SELECT P.memberID
        FROM Payments P, ClubMembers M
        WHERE P.memberID = M.memberID
        GROUP BY P.memberID, P.membershipYear, M.DOB
        HAVING SUM(P.amount) > 200.00
            OR (SUM(P.amount) > 100.00
                AND TIMESTAMPDIFF(YEAR, M.DOB, MAKEDATE(P.membershipYear, 1)) < 17)
    )
ORDER BY L.`name`, age;