// MongoDB initialization script
// This script creates a user for the application database

db.getSiblingDB('cookbook').createUser({
  user: 'cookbook-user',
  pwd: 'cookbookuserpass',
  roles: [{ role: 'readWrite', db: 'cookbook' }]
});

print('User created successfully');
print('Database: cookbook');
print('User: cookbook-user');

