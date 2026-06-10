-- Optional bootstrap script.
-- Run as ADMIN if you want a dedicated demo schema.
--
-- Usage in SQLcl:
--   sql ADMIN/password@yourdb_tp?TNS_ADMIN=/path/to/Wallet_yourdb @sql/00_create_user_as_admin.sql

define aq_user = aqdemo
define aq_password = "ChangeThisPassword_12345"

create user &aq_user identified by &aq_password quota unlimited on data;

grant create session to &aq_user;
grant create table to &aq_user;
grant create procedure to &aq_user;
grant aq_administrator_role to &aq_user;
grant aq_user_role to &aq_user;
grant execute on dbms_aq to &aq_user;
grant execute on dbms_aqadm to &aq_user;

prompt Created &aq_user. Change the password before using this outside a throwaway demo.
