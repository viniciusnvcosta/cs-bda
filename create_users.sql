CREATE USER 'Aplicativo'@'localhost' IDENTIFIED BY '123456';
GRANT INSERT, SELECT ON condominos.* TO 'Aplicativo'@'localhost';

CREATE USER 'AdminGroup'@'localhost' IDENTIFIED BY '123456';
GRANT INSERT, SELECT ON condominos.* TO 'AdminGroup'@'localhost';

CREATE USER 'AdminBD'@'localhost' IDENTIFIED BY '123456';
GRANT INSERT, SELECT ON condominos.* TO 'AdminBD'@'localhost';

FLUSH PRIVILEGES;