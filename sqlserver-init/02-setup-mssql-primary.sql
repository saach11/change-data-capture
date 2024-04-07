CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Password!';
CREATE LOGIN mirror WITH PASSWORD = 'Password!';
CREATE USER mirror FOR LOGIN mirror;
CREATE CERTIFICATE mirror
    AUTHORIZATION mirror
    FROM FILE = '/etc/sqlserver/debezium.cer'
    WITH PRIVATE KEY (
    FILE = '/etc/sqlserver/debezium.key',
    DECRYPTION BY PASSWORD = 'Password!'
);
CREATE ENDPOINT mirror
	STATE = STARTED
	AS TCP (LISTENER_IP = (0.0.0.0), LISTENER_PORT = 5022)
	FOR DATA_MIRRORING (
                AUTHENTICATION = CERTIFICATE mirror,
		ROLE = ALL,
		ENCRYPTION = REQUIRED ALGORITHM AES
        );
GRANT CONNECT ON ENDPOINT::mirror TO mirror;
CREATE AVAILABILITY GROUP dbz WITH (CLUSTER_TYPE=NONE) FOR REPLICA ON
'mssql-primary' WITH (
	ENDPOINT_URL = 'tcp://mssql-primary:5022',
	AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
	FAILOVER_MODE = MANUAL,
	SEEDING_MODE = AUTOMATIC,
	SECONDARY_ROLE (
		ALLOW_CONNECTIONS = READ_ONLY,
		READ_ONLY_ROUTING_URL = 'TCP://mssql-primary:1433'
	)
),
'mssql-secondary' WITH (
	ENDPOINT_URL = 'tcp://mssql-secondary:5022',
	AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
	FAILOVER_MODE = MANUAL,
	SEEDING_MODE = AUTOMATIC,
	SECONDARY_ROLE (
		ALLOW_CONNECTIONS = READ_ONLY,
		READ_ONLY_ROUTING_URL = 'TCP://mssql-secondary:1433'
	)
);
BACKUP DATABASE testDB
	TO DISK = '/tmp/testDB.bak'
	WITH FORMAT;
ALTER AVAILABILITY GROUP dbz ADD DATABASE testDB;
GO