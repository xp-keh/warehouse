-- postgis-setup/init.sql

CREATE TABLE data_catalog (
    catalog_id      SERIAL,
    table_name      TEXT NOT NULL,
    source_type     TEXT NOT NULL,
    partition_date  TIMESTAMP WITH TIME ZONE NOT NULL,
    columns_info    JSONB,
    spatial_extent  GEOGRAPHY(Point),
    record_count    INTEGER,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (source_type, catalog_id)
) PARTITION BY LIST (source_type);

CREATE TABLE data_catalog_seismic PARTITION OF data_catalog
    FOR VALUES IN ('seismic');
CREATE TABLE data_catalog_weather PARTITION OF data_catalog
    FOR VALUES IN ('weather');

CREATE INDEX idx_partition_date_seismic ON data_catalog_seismic (partition_date);
CREATE INDEX idx_partition_date_weather ON data_catalog_weather (partition_date);

-- Adjusting spatial index to use GEOGRAPHY type
CREATE INDEX idx_spatial_extent_seismic ON data_catalog_seismic USING GIST (spatial_extent);
CREATE INDEX idx_spatial_extent_weather ON data_catalog_weather USING GIST (spatial_extent);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    refresh_token TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create a new user with credentials stored in environment variables
DO
$$
BEGIN
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', current_setting('app.db_user'), current_setting('app.db_password'));
EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'User already exists, skipping creation.';
END;
$$;

-- Grant privileges to the new user
GRANT ALL PRIVILEGES ON DATABASE spatialdb TO CURRENT_USER;

-- Grant schema-level privileges
GRANT USAGE ON SCHEMA public TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO CURRENT_USER;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO CURRENT_USER;

-- Ensure future tables and sequences are accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO CURRENT_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO CURRENT_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO CURRENT_USER;

CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL
);

INSERT INTO cities (city, latitude, longitude)
VALUES 
('Serang', -6.1169, 106.1539),
('Jakarta', -6.1944, 106.8229),
('Bandung', -6.9175, 107.6191),
('Semarang', -6.9838, 110.4100),
('Surabaya', -7.2575, 112.7521);
