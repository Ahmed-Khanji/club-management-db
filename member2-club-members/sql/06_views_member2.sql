-- Merge into Member 5's 06_views.sql after all tables and INSERTs are loaded.
-- Referenced by the original Member 3 query vi without modification.
CREATE OR REPLACE VIEW v_LatestMeasurement AS
SELECT m.MemberID, m.HeightCm, m.WeightKg
FROM MemberMeasurements m
JOIN (SELECT MemberID, MAX(MeasureDate) AS LastDate
      FROM MemberMeasurements GROUP BY MemberID) AS recent
  ON recent.MemberID=m.MemberID AND recent.LastDate=m.MeasureDate;

-- Shared formula for ages in all nine queries:
-- TIMESTAMPDIFF(YEAR, c.DOB, CURDATE())
