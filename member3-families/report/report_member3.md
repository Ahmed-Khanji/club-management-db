# CBCS Report — Member 3 sections

## (1) Design

*Insert `er_diagram.png` here, full page width (landscape page if possible).*

The E/R diagram follows the notation of the course textbook (Ullman & Widom). Entity sets are rectangles with their attributes listed inside, and key attributes are underlined. Relationship sets are diamonds, with the relationship's key underlined beneath its name. A many-many relationship is keyed by the keys of both entity sets (for example `Enjoys`: MemberID, HobbyID); a many-one relationship is keyed by the key of its "many" side. An arrow entering an entity set means "at most one" of that entity per relationship; a round-headed arrow means "exactly one" (referential integrity). A line with no arrowhead means "many". Weak entity sets are drawn as double rectangles, linked to their owner through a double-diamond supporting relationship; their underlined discriminator, together with the owner's key, forms their key.

**Entity sets.** The seven entity sets required by the specification are `Locations`, `Personnel`, `ClubMembers`, `FamilyMembers`, `Hobbies`, `Payments` and `NBA_Games`. Each has a surrogate integer key. `ClubMembers.MemberID` is auto-incremented and unique across all locations, as the specification requires. SSN and Medicare number are unique for every kind of person, and SSN is never null.

**Weak entity sets.** Three things only make sense in relation to an owner, so they are modelled as weak entity sets:

- `LocationPhones` (owner `Locations`, discriminator `Phone`), because a location may have several phone numbers.
- `PersonnelAssignments` (owner `Personnel`, discriminator `StartDate`). Each row is one period of work at one location, with `EndDate` null while the person is still active there. Role, title and mandate are recorded per period, so the history of where each person worked is kept. A second relationship, `AssignedTo`, links each period to exactly one location. Roger Smith's example in the specification becomes three periods: Montréal, Laval, then Montréal again.
- `MemberMeasurements` (owner `ClubMembers`, discriminator `MeasureDate`), which keeps the full history of height and weight. The most recent row gives the current values.

**Relationship sets.**

| Relationship | Between | Multiplicity | Captures |
|---|---|---|---|
| `MemberAt` | ClubMembers → Locations | many-one, exactly one | The location a member is associated with now |
| `FamilyAt` | FamilyMembers → Locations | many-one, exactly one | The location a family member is associated with now |
| `AssignedTo` | PersonnelAssignments → Locations | many-one, exactly one | Where each work period took place |
| `GuardianOf` | ClubMembers (minor) → FamilyMembers | many-one | The family member a minor is associated with, with attribute `Relationship` ∈ {Father, Mother, Grandfather, Grandmother, Tutor, Partner, Friend, Other} |
| `Makes` | Payments → ClubMembers | many-one, exactly one | Who made each payment |
| `Enjoys` | ClubMembers – Hobbies | many-many | A member's hobbies, chosen from the registered list |
| `PlaysIn` | ClubMembers – NBA_Games | many-many | Participation in NBA games, with attributes `TeamPlayedFor`, `Points`, `Details` |

**Design decisions.**

1. *Major or minor is computed, not stored.* A member is major when aged 17 or older, calculated from date of birth. This means no row has to change when a member turns 17.
2. *Status and donations are computed from `Payments`.* A member is active when the payments for the previous membership year cover the fee ($100 for a minor, $200 for a major); anything above the fee is a donation. Storing these values would let them drift out of date.
3. *The same person in several roles.* A major club member can also be a family member (a parent) and personnel (for example a volunteer coach). These rows are recognised as the same person through their SSN, which is unique and mandatory everywhere.
4. *Final score.* The final score of a game is stored once in `NBA_Games` (home and away score). The opposing team is the game's other team, so it is not repeated in `PlaysIn`.
5. *Installments.* `InstallmentNo` is limited to 1–4 and is unique per member and membership year, so a fifth payment for the same year cannot be recorded.

## (2) Relational schema — introduction

The E/R diagram was converted into 13 relations. Each entity set became a relation with the same key. Each weak entity set became a relation whose key is its owner's key plus its discriminator. Each many-one relationship became a foreign key on the "many" side (for example `ClubMembers.LocationID`, `Payments.MemberID`), or, for `GuardianOf`, a separate relation keyed on the minor. Each many-many relationship became a relation whose key combines the keys of both sides.

| Relation | Primary key | Foreign keys |
|---|---|---|
| Locations | LocationID | — |
| LocationPhones | (LocationID, Phone) | LocationID → Locations |
| Personnel | PersonnelID | — |
| PersonnelAssignments | (PersonnelID, StartDate) | PersonnelID → Personnel, LocationID → Locations |
| ClubMembers | MemberID | LocationID → Locations |
| Hobbies | HobbyID | — |
| MemberHobbies | (MemberID, HobbyID) | MemberID → ClubMembers, HobbyID → Hobbies |
| MemberMeasurements | (MemberID, MeasureDate) | MemberID → ClubMembers |
| FamilyMembers | FamilyMemberID | LocationID → Locations |
| MinorGuardians | MemberID | MemberID → ClubMembers, FamilyMemberID → FamilyMembers |
| Payments | PaymentID | MemberID → ClubMembers |
| NBA_Games | GameID | — |
| GameParticipations | (MemberID, GameID) | MemberID → ClubMembers, GameID → NBA_Games |

**Data types used throughout.** SSN `CHAR(9)`, Medicare number `CHAR(12)`, postal code `CHAR(6)`, province `CHAR(2)`, phone `VARCHAR(15)`, money `DECIMAL(7,2)`, height and weight `DECIMAL(5,1)` in cm and kg, dates `DATE`, fixed lists (location type, role, mandate, payment method, relationship) `ENUM`. All tables use the InnoDB engine with `utf8mb4`, so foreign keys are enforced and accented names such as Montréal and Léa are stored correctly.

**Constraints enforced by the schema.** `UNIQUE` on SSN and Medicare number; `NOT NULL` on SSN; `AUTO_INCREMENT` on the membership number; `CHECK` constraints for the minimum age of 6 at registration and installment numbers 1–4; `ENUM` for every closed list of values; foreign keys with `ON DELETE RESTRICT` where deleting a parent row would break a rule (for example, a family member cannot be deleted while a minor still depends on them).

**Load order.** Scripts run in the order 00 (reset) → 01 Locations & Personnel → 02 Club members → 03 Families → 04 Payments → 05 NBA games → 06 views → 07 queries. Every foreign key refers to a table created in an earlier script.

### FamilyMembers and MinorGuardians (Member 3's tables)

`FamilyMembers` stores every family member who registers a minor: name, date of birth, SSN (unique, not null), Medicare number (unique), phone, address, email, and the location they are currently associated with. `MinorGuardians` links each minor to one family member and records the relationship. Its primary key is `MemberID`, so a minor has exactly one family member at a time; when a minor changes family member the row is updated. Deleting a minor removes their link (`ON DELETE CASCADE`), while a family member who is still linked to a minor cannot be deleted (`ON DELETE RESTRICT`).

Example transactions on these tables (`03_transactions.sql`) show the rules in action: registering a new family member, moving a family member to another location, switching a minor to a different family member, and deleting a family member only when no minor depends on them.

---

## Assumptions to add to the group list (send to Member 4)

- A minor's "child" relationship for query vi counts every minor linked to the family member, whatever the relationship type (father, grandmother, tutor, ...).
- A family member and a club member are the same person when their SSN is the same.
- A family member may be registered before any minor is linked to them.
- Only the current family member of a minor, and the current location of a family member, are stored; a change updates the row. The specification requires the relationship to be maintained but does not ask for the history of past family members or locations, and none of the nine queries needs it.
- Boys and Girls teams are mentioned in the description but no query uses them, so they are not modelled.
