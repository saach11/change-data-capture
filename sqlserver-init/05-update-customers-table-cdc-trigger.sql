USE testDB;
GO

UPDATE customers SET first_name='Peter', email='peter.doe1@example.com'
  WHERE email='john.doe1@example.com';
UPDATE customers SET email='john.doe2@contoso.com'
  WHERE email='john.doe2@example.com';