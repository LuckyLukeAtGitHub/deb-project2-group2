
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS ETL_P2
WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    COMMENT = 'A computing resource for dbt to run ETL_P2';

-- databases and schemas
CREATE DATABASE IF NOT EXISTS TVSHOW;
CREATE SCHEMA IF NOT EXISTS TVSHOW.SOURCE; --raw Airbyte to dump here
CREATE SCHEMA IF NOT EXISTS TVSHOW.MODEL; --silver
CREATE SCHEMA IF NOT EXISTS TVSHOW.EXPOSE; --gold
CREATE SCHEMA IF NOT EXISTS TVSHOW.UTIL;

-- roles and users
USE ROLE USERADMIN;

-- create dbt role and user
CREATE ROLE IF NOT EXISTS DBT_RW_P2;
CREATE USER IF NOT EXISTS dbt_P2
    PASSWORD='project2tvshows'
    LOGIN_NAME='dbt_P2'
    MUST_CHANGE_PASSWORD=FALSE
    DEFAULT_WAREHOUSE='ETL_P2'
    DEFAULT_ROLE='DBT_RW_P2'
    DEFAULT_NAMESPACE='TVSHOW.SOURCE'
    COMMENT='A dbt user used for ETL_P2';

-- create Airbyte role
USE ROLE securityadmin;
CREATE ROLE IF NOT EXISTS AIRBYTE_ROLE;
GRANT AIRBYTE_ROLE TO ROLE SYSADMIN;

-- create Airbyte user
CREATE USER IF NOT EXISTS AIRBYTE_USER
PASSWORD ='project2tvshows'
    LOGIN_NAME='airbyte_user'
    MUST_CHANGE_PASSWORD=FALSE
    DEFAULT_WAREHOUSE='ETL_P2'
    DEFAULT_ROLE='DBT_RW_P2'
    DEFAULT_NAMESPACE='TVSHOW.SOURCE'
    COMMENT='An Airbyte user used for ETL_P2';
    
-- set up permissions
USE ROLE SECURITYADMIN;

GRANT ROLE DBT_RW_P2 TO USER dbt_P2;
GRANT ROLE AIRBYTE_ROLE TO USER AIRBYTE_USER;

-- grant Airbyte warehouse access
GRANT USAGE ON WAREHOUSE ETL_P2 TO ROLE AIRBYTE_ROLE;

-- grant Airbyte and DBT_RW_P2 database access
GRANT ALL ON DATABASE TVSHOW TO ROLE AIRBYTE_ROLE;

GRANT ALL ON DATABASE TVSHOW TO ROLE DBT_RW_P2;

-- dbt_rw account level
GRANT USAGE ON WAREHOUSE ETL_P2 TO ROLE DBT_RW_P2;
-- dbt_rw schema level
GRANT ALL ON ALL SCHEMAS IN DATABASE TVSHOW TO ROLE DBT_RW_P2;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE TVSHOW TO ROLE DBT_RW_P2;
-- airbyte schema level
GRANT ALL ON ALL SCHEMAS IN DATABASE TVSHOW TO ROLE AIRBYTE_ROLE;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE TVSHOW TO ROLE AIRBYTE_ROLE;
-- dbt_rw object level
GRANT ALL ON ALL TABLES IN SCHEMA TVSHOW.SOURCE TO ROLE DBT_RW_P2;
GRANT ALL ON FUTURE TABLES IN SCHEMA TVSHOW.SOURCE TO ROLE DBT_RW_P2;
GRANT ALL ON ALL TABLES IN SCHEMA TVSHOW.MODEL TO ROLE DBT_RW_P2;
GRANT ALL ON FUTURE TABLES IN SCHEMA TVSHOW.MODEL TO ROLE DBT_RW_P2;
GRANT ALL ON ALL VIEWS IN SCHEMA TVSHOW.EXPOSE TO ROLE DBT_RW_P2;
GRANT ALL ON FUTURE VIEWS IN SCHEMA TVSHOW.EXPOSE TO ROLE DBT_RW_P2;