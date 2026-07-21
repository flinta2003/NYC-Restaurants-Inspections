---- 1. ------------------------------------------------------------------------------------------------------------------
CREATE VIEW "TypicalInspectionTypes" AS
SELECT SUBSTR("i"."inspection_type", 1, INSTR("i"."inspection_type", " / ") - 1) AS "Inspection Type",
SUBSTR("i"."inspection_type", INSTR("i"."inspection_type", " / ") + 3) AS "Inspection Round",
strftime('%Y', "i"."inspection_date", 'julianday') AS "Year",
COUNT(CASE WHEN "i"."critical_flag" = 'Critical' THEN "i"."critical_flag" END) AS "Critical",
COUNT(CASE WHEN "i"."critical_flag" = 'Not Critical' THEN "i"."critical_flag" END) AS "Not Critical",
ROUND(AVG("i"."score"), 3) AS "Average Score"
FROM "inspections" "i"
WHERE "Year" IS NOT NULL
GROUP BY "Inspection Type", "Inspection Round", "Year"
ORDER BY COUNT("i"."inspection_type") DESC
;


---- 2. ------------------------------------------------------------------------------------------------------------------
CREATE VIEW "CuisineBoroPattern" AS
SELECT "c"."cuisine_type" AS "Cuisine", "r"."boro" AS "Borough",
strftime('%Y', "i"."inspection_date", 'julianday') AS "Year",
(COUNT(DISTINCT CASE WHEN "i"."critical_flag" = 'Critical' THEN "i"."inspection_id" END) * 1.0) / NULLIF(COUNT(DISTINCT "i"."inspection_id"), 0) AS "Violation Ratio",
ROUND(AVG("i"."score"),3) AS "Average Inspection Score"
FROM "restaurants" "r"
JOIN "inspections" "i" ON "i"."restaurant_id" = "r"."camis"
JOIN "cuisine_types" "c" ON "c"."restaurant_id" = "r"."camis"
WHERE "Year" IS NOT NULL
GROUP BY "Borough", "Cuisine", "Year"
;


---- 3. ------------------------------------------------------------------------------------------------------------------
CREATE VIEW "RiskyBorosYearly" AS
SELECT "r"."boro" AS "Borough", strftime('%Y', "i"."inspection_date", 'julianday') AS "Year",
SUM(CASE WHEN "i"."critical_flag" = 'Critical' THEN 1.0 ELSE 0.0 END) / COUNT("i"."critical_flag") AS "Critical Ratio",
SUM(CASE WHEN "i"."critical_flag" = 'Not Critical' THEN 1.0 ELSE 0.0 END) / COUNT("i"."critical_flag") AS "Not Critical Ratio",
SUM(CASE WHEN "i"."critical_flag" = 'Not Applicable' THEN 1.0 ELSE 0.0 END) / COUNT("i"."critical_flag") AS "Not Applicable Ratio"
FROM "restaurants" "r"
JOIN "inspections" "i" ON "i"."restaurant_id" = "r"."camis"
WHERE "Borough" IS NOT NULL AND "Year" IS NOT NULL
GROUP BY "Year", "Borough"
;



CREATE VIEW "RiskyBorosAvgScore" AS
WITH "UniqueInspections" AS (
    SELECT "camis", "inspection_date", "inspection_type",
    MAX(CASE WHEN "critical_flag" = 'Critical' THEN 1 ELSE 0 END) AS "is_critical",
    MAX(CASE WHEN "critical_flag" = 'Not Critical' THEN 1 ELSE 0 END) AS "is_not_critical",
    MAX(CASE WHEN "critical_flag" = 'Not Applicable' THEN 1 ELSE 0 END) AS "is_not_applicable"
    FROM "inspections"
    WHERE "inspection_date" IS NOT NULL
    GROUP BY "camis", "inspection_date", "inspection_type"
)
SELECT "r"."boro" AS "Borough", strftime('%Y', "i"."inspection_date", 'julianday') AS "Year",
ROUND(AVG(CASE WHEN "i"."is_critical" = 1 THEN "i"."score" END), 3) AS "Critical",
    ROUND(AVG(CASE WHEN "i"."is_not_critical" = 1 THEN "i"."score" END), 3) AS "Not Critical",
    ROUND(AVG(CASE WHEN "i"."is_not_applicable" = 1 THEN "i"."score" END), 3) AS "Not Applicable"
FROM "UniqueInspections"
JOIN "inspections" "i" ON "i"."restaurant_id" = "r"."camis"
WHERE "Borough" IS NOT NULL AND "Year" IS NOT NULL
GROUP BY "Year", "Borough"
;


---- 4. ------------------------------------------------------------------------------------------------------------------
CREATE TABLE "franchises" (
    "names" TEXT,
    PRIMARY KEY ("names")
);

INSERT INTO "franchises" ("names")
VALUES ('donald'), ('kfc'), ('kentuc'), ('five guys'),
('burger king'), ('popeyes'), ('taco bell'), ('subway'),
 ('chick-fil-a'), ('starbuck'), ('krispy kreme'), ('dunkin donut');

ALTER TABLE "restaurants" ADD COLUMN "is_franchise" INTEGER DEFAULT 0;

UPDATE "restaurants" SET "is_franchise" = 1
WHERE EXISTS (SELECT 1 FROM "franchises" "f"
WHERE "restaurants"."dba" LIKE '%' || "f"."names" || '%'
);

CREATE VIEW "FranchiseSafetyness" AS
SELECT "r"."is_franchise" AS "is Franchise", ROUND(AVG("score"),3) AS "Average Score", strftime('%Y' ,"i"."inspection_date", 'julianday') AS "Year",
SUM(CASE WHEN "critical_flag" = 'Critical' THEN 1.0 ELSE 0.0 END) / COUNT(*) AS "Critical Violations Ratio"
FROM "restaurants" "r"
JOIN "inspections" "i" ON "i"."restaurant_id" = "r"."camis"
WHERE "Year" IS NOT NULL
GROUP BY "is Franchise", "Year"
;


---- 5. ------------------------------------------------------------------------------------------------------------------
CREATE VIEW "RiskyAreas" AS
SELECT "r"."dba" AS "name", "r"."boro", "r"."latitude", "r"."longitude",
strftime('%Y', "i"."inspection_date", 'julianday') AS "year",
SUM(CASE WHEN "critical_flag" = 'Critical' THEN 1.0 ELSE 0.0 END) / COUNT(*) AS "Critical Violations Ratio"
FROM "restaurants" "r"
JOIN "inspections" "i" ON "r"."camis" = "i"."restaurant_id"
WHERE "i"."critical_flag" = 'Critical' AND "r"."latitude" IS NOT NULL
GROUP BY "r"."camis", "name", "year", "r"."latitude", "r"."longitude"
;
