CREATE TABLE Payments (
    paymentID INT AUTO_INCREMENT,
    memberID INT NOT NULL,
    paymentDate DATE NOT NULL,
    amount DECIMAL(7,2) NOT NULL,
    method VARCHAR(6) NOT NULL,
    membershipYear INT NOT NULL,
    installmentNum INT NOT NULL,
    PRIMARY KEY (paymentID),
    UNIQUE (memberID, membershipYear, installmentNum),
    FOREIGN KEY (memberID) REFERENCES ClubMembers(memberID),
    CONSTRAINT PaymentAmountPositive CHECK (amount > 0),
    CONSTRAINT PaymentMethodValid CHECK (method IN ('Cash', 'Debit', 'Credit')),
    CONSTRAINT PaymentYearValid CHECK (membershipYear BETWEEN 2000 AND 2100),
    CONSTRAINT PaymentMaxFourInstallments CHECK (installmentNum BETWEEN 1 AND 4)
);

INSERT INTO Payments (memberID, paymentDate, amount, method, membershipYear, installmentNum) VALUES
    -- 1 Marc (major): exactly $200 every year, never a donation
    (1, '2024-01-08', 200.00, 'Debit', 2024, 1),
    (1, '2024-12-18', 100.00, 'Debit', 2025, 1), -- paid in Dec. 2024 FOR 2025
    (1, '2025-01-20', 100.00, 'Debit', 2025, 2),
    (1, '2026-01-12', 200.00, 'Credit', 2026, 1),
    -- 2 Lea (minor): $130 for 2025 = $100 fee + $30 donation
    (2, '2024-03-05', 100.00, 'Cash', 2024, 1), -- more than 2 years ago: not in query iii
    (2, '2024-12-15', 60.00, 'Cash', 2025, 1), -- paid in Dec. 2024 FOR 2025
    (2, '2025-02-10', 70.00, 'Credit', 2025, 2),
    (2, '2026-01-14', 100.00, 'Cash', 2026, 1),
    -- 3 Noah (minor): exactly $100 every year
    (3, '2024-02-01', 100.00, 'Debit', 2024, 1),
    (3, '2025-01-25', 100.00, 'Debit', 2025, 1),
    (3, '2026-02-03', 100.00, 'Debit', 2026, 1),
    -- 4 Chloe (minor): $80 for 2025, $20 short -> Inactive
    (4, '2025-03-03', 80.00, 'Cash', 2025, 1),
    -- 5 Sofia (major): 2025 in the maximum 4 installments
    (5, '2025-01-15', 50.00, 'Credit', 2025, 1),
    (5, '2025-03-15', 50.00, 'Credit', 2025, 2),
    (5, '2025-05-15', 50.00, 'Cash', 2025, 3),
    (5, '2025-07-15', 50.00, 'Debit', 2025, 4),
    (5, '2026-01-15', 200.00, 'Credit', 2026, 1),
    -- 6 Karim (major): $250 for 2025 = $50 donation
    (6, '2025-01-09', 250.00, 'Credit', 2025, 1),
    (6, '2026-01-09', 200.00, 'Credit', 2026, 1),
    -- 7 Julie (major): 2024 and 2026 paid, nothing for 2025 -> Inactive
    (7, '2024-01-22', 200.00, 'Cash', 2024, 1),
    (7, '2026-01-22', 200.00, 'Cash', 2026, 1),
    -- 8 Ethan: minor fee for 2024 and 2025 (16 on Jan. 1, 2025), major fee for 2026
    (8, '2024-01-30', 100.00, 'Debit', 2024, 1),
    (8, '2025-01-30', 100.00, 'Debit', 2025, 1),
    (8, '2026-01-30', 200.00, 'Debit', 2026, 1),
    -- 9 Maya: minor fee for 2024, then turned 17 on Jan. 1, 2025, so $200 for 2025 -> $50 short
    (9, '2024-02-14', 100.00, 'Cash', 2024, 1),
    (9, '2025-02-14', 150.00, 'Credit', 2025, 1),
    -- 10 Omar (major): $300 for 2024 = $100 donation, exact fee after that
    (10, '2024-01-04', 300.00, 'Credit', 2024, 1),
    (10, '2025-01-04', 200.00, 'Credit', 2025, 1),
    (10, '2026-01-04', 200.00, 'Credit', 2026, 1),
    -- 11 Amira (minor): $120 for 2025 = $20 donation
    (11, '2025-01-28', 120.00, 'Debit', 2025, 1),
    (11, '2026-01-28', 100.00, 'Debit', 2026, 1),
    -- 12 Lucas (minor): $125 for 2025 in 3 installments = $25 donation
    (12, '2024-01-17', 100.00, 'Cash', 2024, 1),
    (12, '2025-01-17', 50.00, 'Cash', 2025, 1),
    (12, '2025-04-17', 50.00, 'Cash', 2025, 2),
    (12, '2025-09-17', 25.00, 'Cash', 2025, 3),
    (12, '2026-01-17', 100.00, 'Cash', 2026, 1);