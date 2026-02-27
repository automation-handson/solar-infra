# Follow the below guide to create tls certificate for Hashicorp Vault with customer domain name the alts
## Note that all files with (.key, .crt, .csr, and .hclic) extensions will be ignored by git
### Generate the CA private key
```
openssl genrsa -out ca.key 4096
```

### Create a configuration file for the CA certificate
```
cat <<EOF > ca_cert_config.txt
[req]
distinguished_name = req_distinguished_name
x509_extensions    = v3_ca
prompt             = no

[req_distinguished_name]
countryName             = UK
stateOrProvinceName     = VOIS
localityName            = VCI
organizationName        = SMS
commonName              = devvf.com

[v3_ca]
basicConstraints        = critical,CA:TRUE
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always,issuer
EOF
```
### Generate a CA valid for 10 years
```
openssl req -new -x509 -days 3650 \
-config ca_cert_config.txt \
-key ca.key \
-out ca.crt
```

### Generate a private key for the server certificate
```
openssl genrsa -out tls.key 4096
```

### Create a configuration file for the server certificate
```
cat <<EOF > server_cert_config.txt
default_bit        = 4096
distinguished_name = req_distinguished_name
prompt             = no

[req_distinguished_name]
countryName             = UK
stateOrProvinceName     = VOIS
localityName            = VCI
organizationName        = SMS
commonName              = secrets.sandbox.devvf.com
EOF
```
### Create an extension and SAN file for the server certificate
### Add any additional SANs necessary for the Vault nodes
```
cat <<EOF > server_ext_config.txt
authorityKeyIdentifier = keyid,issuer
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage       = serverAuth, clientAuth
subjectAltName         = @alt_names

[alt_names]
DNS.1 = vault-0.vault-internal
DNS.2 = vault-1.vault-internal
DNS.3 = vault-2.vault-internal
DNS.4 = vault-3.vault-internal
DNS.5 = vault-4.vault-internal
DNS.6 = vault.vault
DNS.7 = vault-active.vault
DNS.8 = vault-internal.vault
DNS.9 = dr-secrets.sandbox.devvf.com
EOF
```

### Generate the Certificate Signing Request
```
openssl req -new -key tls.key -out tls.csr -config server_cert_config.txt
```

### Generate the signed certificate valid for 1 year
```
openssl x509 -req -in tls.csr -out tls.crt \
-CA ca.crt -CAkey ca.key -CAcreateserial \
-days 730 -sha512 -extfile server_ext_config.txt
```
