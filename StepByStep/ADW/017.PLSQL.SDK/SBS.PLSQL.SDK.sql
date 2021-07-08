BEGIN
DBMS_CLOUD.drop_credential (credential_name => 'OCI_NATIVE_CRED');
  DBMS_CLOUD.CREATE_CREDENTIAL (
    credential_name => 'OCI_NATIVE_CRED',
    user_ocid              => 'ocid1.user.oc1..aaaaaaaa62ddo23gk5z65jjx4kvfqfbfbxit6plqyzotuajvbicfevjzmpya',
    tenancy_ocid           => 'ocid1.tenancy.oc1..aaaaaaaanws4oifjsjatcxnvngqqfa7p2htaoqt6uvxgtswn2bsdmgpafi3q',
    private_key            => 'MIIEpAIBAAKCAQEA8aQjVluKdyDhLMSldqMfzuUXUBirBlUfXKv0do6WtEP+nts/' ||
'Lt58lBDWcrKK+nJnanvWBEUo0i2r6l7AoN+eXDBPep7uAixf/J5VIuq6tiyuUHDy' ||
'mxX266ZvsBceSh1qsymgzJoNMQ3LEykfQubuYSLYSSAaR8t/vIeoqtKxWqwUVA8x' ||
'jCDsg4mNG154qg/mbxr6TlWs+qQb3q9cqp5hqdiIzmbD8+7le915BmTxCdpIBkAQ' ||
'IU+WHMkgZQk2/o4BoUGTO7ZQYRuz3cvQO03lhEzTKxTi1z8NqkzOpA6kxFuX6TRr' ||
'xXvB/1kJ0vkgsMxzac6LgZMD55AnkbQnbQWEhwIDAQABAoIBAQDt/p/fWmHSW0vs' ||
'b/IYGyok+HYxqVoo7oXpHGO2sVG1UpLhm0drvi4tFzhf14ISkcNRmY58vjEqcVk1' ||
'iQVobVbnrZ1aRFZfRZ10je2EanRjITa+e8A3BzcfednfMaXfkYGZ3JJHciM0AUXW' ||
'JVZo6lI20b78puW7eK7i3So+tS2BArk4ysTKqNjuuz5+hGMIxt8lpGCHr+w25Vc2' ||
'33DCwSho0sQEsBagOK8FPqsJTczo3NeWq1BC3RnMyFwvxuzn6dP+XsOt72S2JnXV' ||
'GpUR/QCIIHQC6f2s+P0lQcy+mUdyklkcRRHfxjkeVN7SBY2C4UjvAMpGMVu0eBse' ||
'pKK5clbhAoGBAPv/vMh3VVdNiBoQpYL48jTm5jLLy+D8JnpJcfqmrrmIu4iWwgJV' ||
'CDaCmRHEHwZzaCgASJbi5WBBLoeCFGadwpdsh0rReB/u3wmrBq8r61XLFno/EMdv' ||
'DZNWf0whUGLlIndolqmVrq5GNxOkdpw7KZLW361Nx+13tIUBkuYl6PAzAoGBAPV6' ||
'TP6YZdj7/V4P/mw5ac9e2aWfsd7ADyEAycxL640e5URG210Oefw5eofgLoIIQ6Qs' ||
'eS7pXJinAXDUONY4gS/TNzBs9ZmmuApeXPTYK2RIbhft0Q3IpxYawmmuhS+QuFvb' ||
'EKd31wEk38mjtnlytMXTagAjya8fTOwxjHm21rZdAoGBAOXU7Nz42YDyWXtMS2gU' ||
'nPLa1IDnll7wGjfV3Hp6o0jcCA4fUXrHCuKMYgbuFE3R2+D/wTS8Y+9SA5nbbbfZ' ||
'kqyAczQtr52QQyOSNFp3d/+bZjjAZBFAm+URMrDAgYxw5up5HVA2EEcqCvmDOhpr' ||
'axNdnkt1cS6HysC0GsKFONo5AoGAEi5qwXicIoQXcf4RRAbElX1a9W9shykGddVP' ||
'HPiKi7s8E+CDotLNqia/soyiJTNjfydkGltiZlQIQUkWpJcuylIEhmurjSPSAcKX' ||
'c/MG07ihntgYYcL4zSRSPe2VI76+SN9izmSL4iPPB2o+u6QJS5WrBjOgXn4c/ml1' ||
'FBa8tGkCgYBoxuMrXBT/3xaB9vTMPJSDt3CpqMBhux2oFuZmhYtrl97Dq5ePvP1j' ||
'qU91tLPKO/NmqRd2MjYJ2U8Cyw7xc02gTmT5NGAJAd/2D+qvX8VzL7YT7M3hh6+k' ||
'rhR6H6NIp7Wj/DWtDYwXmhVu95pyC/N59GTVlGZ6sQbromUQUdC1GQ==',
    fingerprint            => 'a2:f1:f6:75:8e:db:c3:8e:76:7f:3b:36:45:a7:06:50');
END;
/



CREATE OR REPLACE NONEDITIONABLE TYPE dbms_cloud_oci_db_database_autonomous_db_version_summary_t FORCE AUTHID CURRENT_USER IS OBJECT (
  version varchar2(4000),
  db_workload varchar2(4000),
  is_dedicated number,
  details varchar2(4000),
  is_free_tier_enabled number,
  CONSTRUCTOR FUNCTION dbms_cloud_oci_db_database_autonomous_db_version_summary_t
    RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION dbms_cloud_oci_db_database_autonomous_db_version_summary_t (
    version varchar2,
    db_workload varchar2,
    is_dedicated number,
    details varchar2,
    is_free_tier_enabled number
  ) RETURN SELF AS RESULT
) NOT PERSISTABLE;


--- Ver las versiones de ADB disponibles en el compartimento !!!

set serveroutput on size 1000000
DECLARE
	ret dbms_cloud_oci_db_database_list_autonomous_db_versions_response_t;
	v_body dbms_cloud_oci_db_database_autonomous_db_version_summary_tbl;
	v_body_elem dbms_cloud_oci_db_database_autonomous_db_version_summary_t;
	--- Tipos escalares !!!
	v_version VARCHAR2(100);
	v_workload VARCHAR2(100);
	v_dedicated PLS_INTEGER;
	v_details VARCHAR2(200);
	v_is_free_tier PLS_INTEGER;
BEGIN
	ret := DBMS_CLOUD_OCI_DB_DATABASE.LIST_AUTONOMOUS_DB_VERSIONS(
compartment_id=>'ocid1.compartment.oc1..aaaaaaaadpqaqexeoppghza34gpmcpueurjwc2xvyk6lqvizcyxblqi7nl4a',
region=>'eu-frankfurt-1', 
credential_name => 'OCI_NATIVE_CRED'
);
---
v_body := ret.response_body;
--
for i in 1..v_body.LAST
loop
	v_body_elem := v_body(i);
	--
	v_version := v_body_elem.version;
	v_workload := v_body_elem.db_workload;
	v_dedicated := v_body_elem.is_dedicated;
	v_details := v_body_elem.details;
	v_is_free_tier := v_body_elem.is_free_tier_enabled;
	--
	dbms_output.put_line ('Version=' ||  v_version || ' - ' || 'Workload=' ||  v_workload  || ' - ' || 'Dedicated=' || v_dedicated   || ' - ' || 'Details=' || v_details  || ' - ' || 'Free Tier=' || v_is_free_tier);
end loop;
--
END;
/

Version=18c - Workload= - Dedicated= - Details= - Free Tier=
Version=18c - Workload= - Dedicated= - Details= - Free Tier=
Version=19c - Workload= - Dedicated= - Details=www.oracle.com/atp - Free Tier=
Version=19c - Workload= - Dedicated= - Details=www.oracle.com/ajd - Free Tier=
Version=19c - Workload= - Dedicated= - Details=www.oracle.com/atp - Free Tier=

PL/SQL procedure successfully completed.

SQL>


--- Crear un bucket en Object Storage !!!

set serveroutput on

declare
  l_type_status  PLS_INTEGER;
  resp_body      dbms_cloud_oci_obs_object_storage_bucket_t;
  response       dbms_cloud_oci_obs_object_storage_create_bucket_response_t;
  bucket_details dbms_cloud_oci_obs_object_storage_create_bucket_details_t;
  l_json_obj     json_object_t;
  l_keys         json_key_list;
begin
  bucket_details := dbms_cloud_oci_obs_object_storage_create_bucket_details_t();
  bucket_details.name := 'ttbck';
  bucket_details.compartment_id := 'ocid1.compartment.oc1..aaaaaaaax5qzsdockq4uqp46tphvb3z6juvuvqhkizfe7wohh226keygraca';
  --Note the use of the native SDK function create_bucket
  response := dbms_cloud_oci_obs_object_storage.create_bucket(
                namespace_name => 'frmd0ia19p3d',
                opc_client_request_id => 'myid',
                create_bucket_details => bucket_details,
                credential_name => 'OCI_NATIVE_CRED',
                region => 'eu-frankfurt-1');
  resp_body := response.response_body;
  -- Response Headers
  dbms_output.put_line('Headers: ' || CHR(10) ||'------------');
  l_json_obj := response.headers;
  l_keys := l_json_obj.get_keys;
  for i IN 1..l_keys.count loop
     dbms_output.put_line(l_keys(i)||':'||l_json_obj.get(l_keys(i)).to_string);
  end loop;
  -- Response status code
  dbms_output.put_line('Status Code: ' || CHR(10) || '------------' || CHR(10) ||      response.status_code);
  dbms_output.put_line(CHR(10));
end;
/

Headers:
------------
Content-Type:"application/json"
location:"https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/frmd0ia19p3d/b/
ttbck"
etag:"43fd0164-c18f-4881-b3bf-8db33303ad5c"
connection:"close"
Content-Length:"758"
opc-client-request-id:"myid"
date:"Thu, 03 Dec 2020 17:02:32 GMT"
opc-request-id:"fra-1:0B69xahgpmIy90ozOPaDU7pQbOudNOIxfVuzxfk1bYzXSsKA9h3AlAhORF
K-VEnP"
x-api-id:"native"
access-control-allow-origin:"*"
access-control-allow-methods:"POST,PUT,GET,HEAD,DELETE,OPTIONS"
access-control-allow-credentials:"true"
access-control-expose-headers:"access-control-allow-credentials,access-control-a
llow-methods,access-control-allow-origin,connection,content-length,content-type,
date,etag,location,opc-client-info,opc-client-request-id,opc-request-id,x-api-id
"
Status Code:
------------
200



PL/SQL procedure successfully completed.

SQL>

--- Stop an ADW !!!

CREATE OR REPLACE NONEDITIONABLE TYPE dbms_cloud_oci_db_database_stop_autonomous_database_response_t FORCE AUTHID CURRENT_USER IS OBJECT (
  response_body dbms_cloud_oci_db_database_autonomous_database_t,
  headers json_object_t,
  status_code number 
) NOT PERSISTABLE;

set serveroutput on

declare
	v_ret dbms_cloud_oci_db_database_stop_autonomous_database_response_t;
BEGIN
	v_ret := DBMS_CLOUD_OCI_DB_DATABASE.stop_autonomous_database (
		autonomous_database_id => 'ocid1.autonomousdatabase.oc1.eu-frankfurt-1.abtheljso6jlqoexpzi3v2spxfv4omp6sti6lqslodgbo5ywwsixtcgajlvq',
		region => 'eu-frankfurt-1',
		credential_name => 'OCI_NATIVE_CRED'
		);
	dbms_output.put_line ('Status Code=' || 	v_ret.status_code);
END;
/

ERROR at line 1:
ORA-20000: ORA-29261: bad argument
ORA-06512: at "C##CLOUD$SERVICE.DBMS_CLOUD", line 995
ORA-06512: at "C##CLOUD$SERVICE.DBMS_CLOUD", line 3097
ORA-06512: at "C##CLOUD$SERVICE.DBMS_CLOUD_OCI_DB_DATABASE", line 25951
ORA-06512: at line 5
