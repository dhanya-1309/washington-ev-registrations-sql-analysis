-- =====================================================================
-- Washington State Electric Vehicle Registrations: SQL analysis
-- Data: WA Department of Licensing EV Population data (public)
-- Dialect: PostgreSQL (PERCENTILE_CONT and window functions are used)
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Create the raw table (load the CSV into it before running step 2)
-- ---------------------------------------------------------------------
CREATE TABLE ev_raw (
  vin                  TEXT,
  county               TEXT,
  city                 TEXT,
  state                TEXT,
  postal_code          TEXT,
  model_year           INTEGER,
  make                 TEXT,
  model                TEXT,
  ev_type              TEXT,
  cafv_eligibility     TEXT,
  electric_range       INTEGER,
  legislative_district TEXT,
  dol_vehicle_id       BIGINT,
  vehicle_location     TEXT,
  electric_utility     TEXT,
  geoid                TEXT
);

SELECT * FROM ev_raw;


-- ---------------------------------------------------------------------
-- 2. Clean the data
-- ---------------------------------------------------------------------

-- Electric range of 0 (or NULL) means the range was never researched,
-- not that the car has zero range. Flag these rows.
ALTER TABLE ev_raw ADD COLUMN range_status TEXT;

UPDATE ev_raw
SET range_status = CASE WHEN COALESCE(electric_range, 0) > 0
                        THEN 'Researched' ELSE 'Not researched' END;

-- Keep Washington State registrations only
DELETE FROM ev_raw WHERE state <> 'WA';

-- Row count check after cleaning
SELECT COUNT(*) FROM ev_raw;   -- should be 299353

-- Check: researched vs. not researched, by vehicle type
SELECT range_status, ev_type, COUNT(*)
FROM ev_raw
GROUP BY range_status, ev_type;

ALTER TABLE ev_raw RENAME TO ev_vehicle;

SELECT * FROM ev_vehicle;


-- ---------------------------------------------------------------------
-- 3. Analysis
-- ---------------------------------------------------------------------

-- Total vehicles and BEV vs PHEV share
SELECT ev_type, COUNT(*) AS vehicles,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM ev_vehicle
GROUP BY ev_type;

-- Top 10 makes
SELECT make, COUNT(*) AS vehicles
FROM ev_vehicle
GROUP BY make
ORDER BY vehicles DESC
LIMIT 10;

-- Top 10 models
SELECT make, model, COUNT(*) AS vehicles
FROM ev_vehicle
GROUP BY make, model
ORDER BY vehicles DESC
LIMIT 10;

-- Top 10 counties
SELECT county, COUNT(*) AS vehicles
FROM ev_vehicle
GROUP BY county
ORDER BY vehicles DESC
LIMIT 10;

-- Registrations by model year
SELECT model_year, COUNT(*) AS vehicles
FROM ev_vehicle
GROUP BY model_year
ORDER BY model_year;

-- Range stats (real values only, excluding "not researched")
SELECT ev_type, COUNT(electric_range) AS electric_range_count,
       ROUND(AVG(electric_range), 1) AS avg_range,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY electric_range) AS median_range,
       MIN(electric_range) AS min_range, MAX(electric_range) AS max_range
FROM ev_vehicle
WHERE range_status = 'Researched'
GROUP BY ev_type;
