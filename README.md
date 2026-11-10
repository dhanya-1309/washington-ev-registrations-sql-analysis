# Washington State EV Registrations: SQL and Tableau Analysis

A descriptive analysis of every electric vehicle (EV) registered in Washington State: which makes and models dominate, how battery and plug-in hybrid vehicles split, how electric range varies, and where the vehicles are.

**Tools:** PostgreSQL 18 (pgAdmin) for cleaning and summary tables, Tableau for charts and county maps, Excel for exporting the raw file
**Data:** Washington State Department of Licensing, Electric Vehicle Population Data ([ADD THE DATA.WA.GOV LINK HERE])
**Files:** `ev_registrations_analysis.sql` (full script), `Washington_EV_SQL_Analysis.pdf` (full report)

## The questions
1. How many EVs are registered in Washington, and how do battery electric (BEV) and plug-in hybrid (PHEV) vehicles split?
2. Which makes and models dominate?
3. How does electric range differ between BEVs and PHEVs?
4. How have registrations changed by model year?
5. Where in the state are EVs concentrated?

## Why this project
Most EV research asks *why* people buy EVs, using regression on incentives, chargers and income. I did not find a study describing what the registered EV fleet in a state actually looks like by make, model, type and range. This project fills that gap.

## Data cleaning (raw file: 300,142 records, 16 fields)

| Issue | Records | What I did |
|---|---|---|
| Registered outside Washington | 789 | Removed |
| Electric range = 0 (all BEVs) | 196,594 | Labeled "Not researched" and kept |
| Electric range blank | 35 | Labeled "Not researched" and kept |
| Legislative district missing (WA) | 1 | Kept (field not used) |
| Duplicate records | 0 | Checked full rows and DOL Vehicle ID |
| **Final dataset** | **299,353** | |

**Key decision:** a range of 0 does not mean the car has no range. It means the DOL has not researched it. I flagged these rows with a new `range_status` field and kept them in every count, but left them out of the range statistics, so they don't pull averages down.

## Key findings
- **299,353 EVs** from 52 makes and 205 models in 39 counties. **BEVs are 80.6%** (241,238) and **PHEVs 19.4%** (58,115).
- **Tesla dominates:** 121,879 vehicles (40.7% of the fleet), about six times Chevrolet, the second-largest make (20,177, 6.7%). The top 10 makes hold 82.3%.
- **The two most common models are both Teslas:** Model Y (66,379, 22.2%) and Model 3 (38,735, 12.9%), together 35.1% of the fleet.
- **Range differs sharply by type:** BEVs have a median range of 215 miles; PHEVs 32 miles. Among researched vehicles, Tesla has the highest average range of the larger makes (241.5 miles).
- **Registrations peaked at model year 2023** (61,316 vehicles), up from 520 in model year 2011. The lower counts for 2024 to 2027 likely reflect those years still being registered, not a real drop.
- **EVs are concentrated around Puget Sound:** King County alone has 143,976 (48.1%). King, Snohomish and Pierce together hold 69.1%, and the top 10 counties hold 90.8%. Spokane (8,778) is the largest county in eastern Washington.

## Limitations
- The data is a snapshot of vehicles registered now. It excludes vehicles sold out of state or scrapped.
- **Only 34.3% of vehicles (102,724) have a researched range**, including just 18.5% of BEVs (mostly older model years), so BEV range results describe older vehicles.
- County figures are raw counts, not rates per person, so larger counties naturally have more vehicles.

## Next steps
- Compare counties after adjusting for population.
- Compare range across makes and model years using regression or analysis of variance.

## SQL skills used
`CREATE TABLE`, `ALTER TABLE`, `UPDATE` with `CASE`, `DELETE`, `GROUP BY`, `ORDER BY`, `LIMIT`, window function (`SUM() OVER`), `PERCENTILE_CONT` for medians, `ROUND`, `COALESCE`

## What I did
Individual project. I loaded the raw data into PostgreSQL, cleaned it with SQL and documented each cleaning decision, wrote the analysis queries, built the Tableau charts and county maps, and wrote the report.
