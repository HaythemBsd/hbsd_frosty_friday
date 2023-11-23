-- create stage
CREATE OR REPLACE STAGE frosty_friday_1 url='s3://frostyfridaychallenges/challenge_1/';
list @frosty_friday_1;

-- file format
CREATE OR REPLACE FILE FORMAT 
    myformat TYPE = 'csv' 
    SKIP_HEADER=1
    NULL_IF=('NULL','totally_empty');

-- store stage data into a table
CREATE OR REPLACE TEMPORARY TABLE frosty_friday_1 AS 
    (SELECT LISTAGG($1,' ') WITHIN GROUP (ORDER BY METADATA$FILENAME, METADATA$FILE_ROW_NUMBER) AS COL1
     FROM @frosty_friday_1
     (file_format=>'myformat')
    );

-- display content
SELECT * FROM frosty_friday_1
