README
=======

This is a rails app to replace my solar-panels set of python scripts
Rails 4.0.0

Database
--------
Using sqlite3 (for now), only a table for 5 minute data (at the moment)

Old database used: -
CREATE TABLE five_minute_data (
time DATETIME, total_power_kWh FLOAT, power_kW FLOAT, power_kWh FLOAT, processed INTEGER,
PRIMARY KEY(time));

Will upload via POST requests, from Raspberry Pi.

