-- clickhouse-setup/init.sql

-- Create databases
CREATE DATABASE IF NOT EXISTS seismic;
CREATE DATABASE IF NOT EXISTS weather;

-- Create a new user
CREATE USER abby IDENTIFIED BY 'SpeakLouder';

-- Grant permissions to the user
GRANT SELECT ON seismic.* TO abby;
GRANT SELECT ON weather.* TO abby;
