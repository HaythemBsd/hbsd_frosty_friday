CREATE OR REPLACE STAGE
    frosty_friday_2_stage
    URL = 's3://frostyfridaychallenges/challenge_2/employees.parquet'
    FILE_FORMAT = (TYPE = PARQUET)
    ;


CREATE OR REPLACE FILE FORMAT
    ffw2_format 
    TYPE = 'PARQUET'
    ;


CREATE OR REPLACE TABLE
    ffw2
    USING TEMPLATE (

        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
        FROM TABLE(INFER_SCHEMA(
            LOCATION => '@frosty_friday_2_stage'
            , FILE_FORMAT => 'ffw2_format'
            , IGNORE_CASE => TRUE
            ))
        )
    ;
    
COPY INTO ffw2
    FROM @frosty_friday_2_stage
    MATCH_BY_COLUMN_NAME = 'CASE_INSENSITIVE'
    ;


    
CREATE OR REPLACE  VIEW
    ffw2_view 
    AS SELECT
        employee_id
        , dept
        , job_title
    FROM ffw2
    ;


CREATE OR REPLACE STREAM track_changes
ON VIEW ffw2_view;

UPDATE ffw2 SET COUNTRY = 'Japan' WHERE EMPLOYEE_ID = 8;
UPDATE ffw2 SET LAST_NAME = 'Forester' WHERE EMPLOYEE_ID = 22;
UPDATE ffw2 SET DEPT = 'Marketing' WHERE EMPLOYEE_ID = 25;
UPDATE ffw2 SET TITLE = 'Ms' WHERE EMPLOYEE_ID = 32;
UPDATE ffw2 SET JOB_TITLE = 'Senior Financial Analyst' WHERE EMPLOYEE_ID = 68;

SELECT *
FROM track_changes
