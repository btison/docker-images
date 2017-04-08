== TLS setup

=== Create certificates

Reference: https://access.redhat.com/node/15497[How do I configure a CA and sign certificates using OpenSSL in Red Hat Enterprise Linux?]

* Create supporting directories and files
+
----
# mkdir -p /etc/pki/CA/{certs,crl,newcerts}
# touch /etc/pki/CA/index.txt
# echo 01 > /etc/pki/CA/serial
----
* Create a openssl configuration file in /etc/pki/CA
+
----
# cp /etc/pki/tls/openssl.cnf /etc/pki/CA/
----
+
In the section 'CA_default', edit the following lines to read:
+
----
dir = /etc/pki/CA
certificate = $dir/my-ca.crt
crl = $dir/my-ca.crl
private_key = $dir/private/my-ca.key
----
+
In the section 'policy_match', edit the following lines to read:
+
----
[ policy_match ]
countryName             = optional
stateOrProvinceName     = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
----
+
These settings allow to have a CA with empty values for the attributes marked as optional.
* Create a private key and self-signed CA certificate
+
----
# cd /etc/pki/CA
# (umask 077; openssl genrsa -out private/my-ca.key -des3 2048)
# openssl req -new -x509 -key private/my-ca.key -days 365 > my-ca.crt
----

* Create a private key for the service (ex: ldap server)
+
----
# openssl genrsa 2048 > ldap_openldap.key
# openssl req -new -key ldap_openldap.key -out ldap_openldap.csr -subj "/CN=<FQDN>"
----
+
Make sure to have the CN set to the FQDN of the server where the service is deployed
* Sign the csr
+
----
# openssl ca -config openssl.cnf -out ldap_openldap.crt -infiles ldap_openldap.csr
----
* Create a 'p12' file out of the certificate and the private key:
+
----
# openssl pkcs12 -inkey ldap_openldap.key -in ldap_openldap.crt -export -out ldap_openldap.p12 -nodes -name 'LDAP-Certificate'
----

=== Mount the certificates in the Docker image

* Copy the CA certificate and the p12 file to the `openldap-secrets` volume.
* Set the `LDAP_TLS_xxx` variables to suitable values.
* To recreate the image, delete the `openldap-config` and `openldap-data` volumes.

== Initial import

ldif files mounted in the `openldap-import` volume will be imported on first run. 

Note: to create a MD5 password:
+
----
$ slappasswd -h "{MD5}"
----