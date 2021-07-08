mkdir /home/opc/TESTKEY
openssl genrsa -out /home/opc/TESTKEY/oci_api_key.pem 2048
chmod go-rwx /home/opc/TESTKEY/oci_api_key.pem
openssl rsa -pubout -in /home/opc/TESTKEY/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
openssl rsa -pubout -outform DER -in /home/opc/TESTKEY/oci_api_key.pem | openssl md5 -c



[DEFAULT]
user=ocid1.user.oc1..aaaaaaaapzn2ucldqjek3qrfo5jnk4ikdf7sz4z5iqw5ffzjoitqdidpu73a
fingerprint=8c:41:2c:fb:58:12:52:8c:08:75:01:88:95:75:df:40
tenancy=ocid1.tenancy.oc1..aaaaaaaanws4oifjsjatcxnvngqqfa7p2htaoqt6uvxgtswn2bsdmgpafi3q
region=eu-frankfurt-1
key_file=<path to your private keyfile> # TODO


BEGIN
DBMS_CLOUD.drop_credential (credential_name => 'OCI_NATIVE_CRED');
  DBMS_CLOUD.CREATE_CREDENTIAL (
    credential_name => 'OCI_NATIVE_CRED',
    user_ocid              => 'ocid1.user.oc1..aaaaaaaapzn2ucldqjek3qrfo5jnk4ikdf7sz4z5iqw5ffzjoitqdidpu73a',
    tenancy_ocid           => 'ocid1.tenancy.oc1..aaaaaaaanws4oifjsjatcxnvngqqfa7p2htaoqt6uvxgtswn2bsdmgpafi3q',
    private_key            => 'MIIEpAIBAAKCAQEA4qG/nDlb65frm3kFlH1VyxWzBcWB2yPbARntEnrEOfMx5NLx' ||
'30MA6tAsrohSonTw9nR+PfutEhyVwxSOrbdOodgRiItX59vRtCA1zcDzs/OwxqUQ' ||
'/3/sUb9XJ6pmn6o25tOgexxUps5vzNl9VsO3bOk7SZSlaf7R48BDz+MrrHz8HKDc' ||
'PddpDQwqRn0twZJXDQEqnhD/jJk34oJeM0NLIfBDjme5zGxo3ETMfy2x4L84bwDK' ||
'tGvIhVs7+9Jj84WDLSYgPCMzwi/OcVaESVZUap5ozrBSxVemuicuLyvgguAsq0X3' ||
'SaJYwepx1JB2ZwbEz5NoVM63xPGeyeU09S5+5QIDAQABAoIBAQDBSDuXbB/mBLIO' ||
'7Z8Brgb+ZepBcNm34JOGE+tpiERUPAIAapuX0pg0qwiAbYk0PlHHj0CfckZ/nNto' ||
'/d5Vb3FjfFgvwM9e0c2+Nn5MlVQC1EGemOavURVl/q7BCIXvhAbAxBopBNd5T7Rv' ||
'28kWt2J3Q06qCVkt1gKBn9b1tIPp3S8zgQkHUEq4cBRLopf6jwMv1yXXmu6M8d8W' ||
't4wNXyiuu7EFhwNSGmzHF3APuYtTKlkmcuLRBIff5IeolqBnPZs6oDppgo8wpHOn' ||
'6u5bQoqo2Zyypvk4pKqma5hTiHepw2kKzFQ5yIjkp9Em+SblKBKhGy+sO1Ho3ubE' ||
'S5LGF8YBAoGBAPm7XFqB1Uyq1CBnmIcF3zKGhFECtp+CvDRpPQLrxdtuz6+hergX' ||
'6ELnSFXYiFHLSFrY4IYgzltkh7ccQVjlmjdc1aOuhHdTWF5RGKZ+RsKg6nngPNjY' ||
'RTxe44itH0mXxBSG0u2V2kWHWmcEhyvCrERLAXvlaWbMGzO2B0B4DteBAoGBAOhR' ||
'9aW6e0ixjZj4ddJmYoKAjN0hUK7Ka9wtetJyXmC8nHDV8mcec81Z3RkDVRNMZ7L7' ||
'hse+h5amc343v1p5rU5LjRwQUfk/aAFjpT6Oy5dAETTIVhl9/Bl3LefS528oI+sL' ||
'g17m+to7bNEj1XjWFwAUYklAJYu5x0z+fDRbN/llAoGBAJzI9VVZN8nXYjAp+gej' ||
'Nxqoez/E/VStpm0dORGxZlm6eydfsQUM9WOzgqVquULo5jcq++MZi5SzS8U5NwmR' ||
'tL1XSkVmFoI30D3+mgRFOTWOA0ea8XiOZwFc7Wrsjb0NTCw67Qf+UbffH3GX1Skz' ||
'IiYKFRds0zyXnehcOrdN6LuBAoGAKDEVuGg8r+TXxGEnsRC5di5bMF51IOgwJNVR' ||
'bFsQ7Nd0kSjSWPixvBMR5yPmcgJD5nkRZjkWJ///9xQZ7MMkMmlrrjE8nUxU5/if' ||
'O+VkX3RcBa+rBZoAJT+zF2orU9Wz8RP61E5Nk7e4Ka5zXgZb0E22e0m3tSaczjsw' ||
'rbYiRukCgYA6Vjnl5P/d024YcMeFHdNlCTfMtlh6TfTtYys9k9b4CtDh/i2t+HbY' ||
'0UqJexzhEOfkcgjZsLEKeZbizLaiOr0inRx0AJzLuGDlnFOKvdo6I8+PcyOSfYkh' ||
'U+2+wZZ2Um+SiV6m8kvrQJSdfq+8W22I8l7Qk6yuRQqGGrZ8oP6YYA==',
    fingerprint            => '8c:41:2c:fb:58:12:52:8c:08:75:01:88:95:75:df:40');
END;
/

Topic OCID = ocid1.onstopic.oc1.eu-frankfurt-1.aaaaaaaaj7gskaxf2ab3jykrb57hvqljepdrjugspe4mqksiewauljvjabaq
Region = eu-frankfurt-1

create or replace function fn_notify(
    topic_ocid VARCHAR2, 
    region VARCHAR2, 
    cred VARCHAR2,
    title VARCHAR2,
    body VARCHAR2) 
return VARCHAR2 as 
  message_details DBMS_CLOUD_OCI_ONS_MESSAGE_DETAILS_T;
  result dbms_cloud_oci_ons_notification_data_plane_publish_message_response_t;
  v_title VARCHAR2(30);
  v_body VARCHAR2(300);
begin
  -- Define the title and body for the notification
  v_title := title;
  v_body := body;
  --
  message_details := DBMS_CLOUD_OCI_ONS_MESSAGE_DETAILS_T(v_title, v_body);
  result := dbms_cloud_oci_ons_notification_data_plane.publish_message( topic_id => topic_ocid,
  message_details => message_details, region => region, credential_name=>cred);
  return result.status_code;
end;
/

declare  
    status varchar2(300);  
    topic_ocid VARCHAR2(100) := 'ocid1.onstopic.oc1.eu-frankfurt-1.aaaaaaaaj7gskaxf2ab3jykrb57hvqljepdrjugspe4mqksiewauljvjabaq';  
    region VARCHAR2(30) := 'eu-frankfurt-1';  
    cred VARCHAR2(30) := 'OCI_NATIVE_CRED';
    v_title VARCHAR2(30) := 'Message Title';
    v_body VARCHAR2(300) := 'Message body: this is a sample message';
begin  
    status := fn_notify(topic_ocid, region, cred, v_title, v_body);
end;
/




