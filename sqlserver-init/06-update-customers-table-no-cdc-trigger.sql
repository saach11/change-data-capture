USE testDB;
GO

UPDATE customers SET last_name='Smith'
  WHERE email='john.doe3@example.com';