# Member 3 — Families

My part of the CBCS project: the **family tables**, **query vi**, the **E/R diagram**, and the **report text** for sections (1) and (2).

**Due to Member 5:** Fri Oct 23

> ⚠️ **Not final yet.** The IDs in `sql/03_families.sql` are placeholders until I get Member 1's cast list. Lines to change are marked `[CAST]`.

---

## 1. What's in this folder

```
member3-families/
├── README.md               ← this file
├── sql/
│   ├── 03_families.sql     ← my 2 tables + data (build file 03)
│   ├── query_vi.sql        ← query vi (goes into 07_queries.sql)
│   ├── 03_transactions.sql ← 4 example transactions
│   └── 03_check.sql        ← checks that the data lines up (testing only)
├── diagram/
│   ├── er_diagram.png      ← goes in the report, section (1)
│   ├── er_diagram.svg      ← same diagram, sharper (optional)
│   └── er_diagram.dot      ← editable source (only I need this)
└── report/
    └── report_member3.md   ← text for report sections (1) and (2)
```

| File | Report section |
|---|---|
| `03_families.sql` | (2) CREATE statements and (4) the data |
| `query_vi.sql` | (3) queries |
| `03_transactions.sql` | (3) transactions |
| `er_diagram.png` | (1) design |
| `report_member3.md` | (1) design and the intro to (2) |

---

## 2. What I need from you

**Member 1**
- [ ] Send me the cast list:
  - the **MemberIDs of at least 10 minors** (age 6–16)
  - the **name, birth date and SSN of at least 2 adult members who are parents and played NBA games**
  - the **LocationIDs**

**Member 2**
- [ ] Confirm there are **at least 10 minors** in `ClubMembers`.
- FYI: your query iii reads my `MinorGuardians` table (`memberID`, `familyMemberID`, `relationship`). One row per minor.

**Member 5**
- [ ] Give each parent from Member 1's list **at least 1 NBA game**, or query vi returns nothing.
- [ ] Add `sql/03_families.sql` to the build as **file 03**, and paste `sql/query_vi.sql` into `07_queries.sql`.
- [ ] Put `diagram/er_diagram.png` in section (1) and `report/report_member3.md` in sections (1) and (2).
- [ ] Add `FamilyMembers` and `MinorGuardians` to the `SELECT COUNT(*)` list (both should show **12**).
- [ ] Tell me if **any column in any table** changed after Oct 19, so I can update the diagram.

---

## 3. Run order

```
00_reset.sql
01_locations_personnel.sql   (Member 1)
02_club_members.sql          (Member 2)
03_families.sql              (Member 3)  ← mine, needs 01 and 02 first
04_payments.sql              (Member 4)
05_nba.sql                   (Member 5)
06_views.sql                 (Members 2 and 4)
07_queries.sql               (everyone, includes query vi)
03_transactions.sql          ← mine, run once after the build
03_check.sql                 ← optional check
```

Run `SET NAMES utf8mb4;` first so names like Montréal display correctly.

**About the transactions file:** it only needs to run after `03_families.sql`. It doesn't change query vi's results or the row counts, so running it before or after the queries is fine. Just run it **once**: running it a second time without rebuilding fails, because it adds a family member who already exists.

---

## 4. What I still have to replace

Every line to change is marked `[CAST]` in `sql/03_families.sql`.

| Placeholder now | Becomes |
|---|---|
| Family members 1–4: SSNs `100000001`–`100000004`, names, birth dates | The **exact** SSN, name and birth date from each parent's `ClubMembers` row (query vi matches on SSN) |
| Minors 11–22 in `MinorGuardians` | Real MemberIDs of minors |
| LocationIDs 1–5 | Real LocationIDs |
| In `03_transactions.sql`: member 17, family members 9, 11, 13 | The matching new IDs |

Format: SSN = 9 digits · Medicare = 12 characters · postal code = 6 characters, no space (`H3G1P1`).

---

## 5. How to check it worked

1. Run `sql/03_check.sql`. The first 3 checks should return **no rows**; the last one should show **12** for both tables.
2. Run `sql/query_vi.sql`. Expect **at least 2 rows**, sorted by location name, then age.
3. **Screenshot** the query and its result for the report.

---

## 6. Design decisions

- A family member and a club member are the **same person when their SSN matches**.
- Each minor has **one family member at a time**; a change updates the row.
- A family member **can't be deleted** while a minor depends on them.
- **Naming:** tables in PascalCase (`FamilyMembers`), columns in camelCase (`familyMemberID`, `postalCode`). Acronyms stay uppercase (`SSN`, `DOB`, `ID`), and number columns end in `Num` (`medicareNum`).
