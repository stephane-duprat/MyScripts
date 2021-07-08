--- Copiar y expandir el wallet del ADB en la maquina del DBCS:
---------------------------------------------------------------
[oracle@hostdbmadee admin]$ pwd
/u01/app/oracle/product/19.0.0.0/dbhome_1/network/admin

mv /tmp/wallet_ATPLABPUB.zip .
mkdir wallet_ATPLABPUB
unzip wallet_ATPLABPUB.zip -d ./wallet_ATPLABPUB

--- Examinar el contenido de tnsnames.ora

cd wallet_ATPLABPUB
cat tnsnames.ora

atplabpub_high = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=j3n0oas9sdwvmr1_atplabpub_high.atp.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))

atplabpub_low = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=j3n0oas9sdwvmr1_atplabpub_low.atp.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))

atplabpub_medium = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=j3n0oas9sdwvmr1_atplabpub_medium.atp.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))

atplabpub_tp = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=j3n0oas9sdwvmr1_atplabpub_tp.atp.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))

atplabpub_tpurgent = (description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=j3n0oas9sdwvmr1_atplabpub_tpurgent.atp.oraclecloud.com))(security=(ssl_server_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))


-- Ahora creo un dblink que apunta al ATP:
------------------------------------------

create database link dbl_atplabpub 
connect to microservice identified by "AAZZ__welcomedevops123" 
using '(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=j3n0oas9sdwvmr1_atplabpub_tp.atp.oraclecloud.com))(security=(my_wallet_directory="/u01/app/oracle/product/19.0.0.0/dbhome_1/network/admin/wallet_ATPLABPUB")(ssl_server_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))';


--- En sqlnet.ora, comentar la linea siguiente:

##SQLNET.ENCRYPTION_CLIENT=REQUIRED

-- Verificar que la conexión al ATP funciona desde SQL*Plus:
------------------------------------------------------------

sqlplus microservice/"AAZZ__welcomedevops123"@'(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.eu-frankfurt-1.oraclecloud.com))(connect_data=(service_name=j3n0oas9sdwvmr1_atplabpub_tp.atp.oraclecloud.com))(security=(my_wallet_directory="/u01/app/oracle/product/19.0.0.0/dbhome_1/network/admin/wallet_ATPLABPUB")(ssl_server_cert_dn="CN=adwc.eucom-central-1.oraclecloud.com,OU=Oracle BMCS FRANKFURT,O=Oracle Corporation,L=Redwood City,ST=California,C=US")))'

SQL*Plus: Release 19.0.0.0.0 - Production on Wed Jun 17 13:22:44 2020
Version 19.4.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Last Successful login time: Wed Jun 17 2020 13:21:33 +00:00

Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.5.0.0.0

SQL> 


--- Verificar el dblink:
------------------------

sqlplus microservice/"AAZZ__welcomedevops123"@hostdbmadee:1521/pdbjson.sub03010825490.devopsvcn.oraclevcn.com


SQL> select count(*) from pizzaorder@dbl_atplabpub;

  COUNT(*)
----------
      2179

-- => SO FAR SO GOOD !!!





