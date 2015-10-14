@echo off
setlocal
:PROMPT
SET /P AREYOUSURE=Are you sure you want to recreate keys prior keys will be deleted (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END
del index.txt
del serial
del *.PEM
del *.attr
del *.old
copy NUL index.txt
echo 1000 >serial
@Echo On
@Echo ---------------------------------------
@Echo This script creates a Root CA, then a certificate signed with that CA.
@Echo This is for a developers machine to use during local machine testing.
@Echo.
@Echo Don't use this for production code, instead purchase a certificate or
@Echo follow a complete guide for doing this in a much safer way.
@Echo https://jamielinux.com/docs/openssl-certificate-authority/index.html
@Echo ---------------------------------------
@Echo .
@Echo .
@Echo ---------------------------------------
@Echo Create Root CA private key
@Echo Typically stronger than the keys/certs needed later.
@Echo Enter password when requested
@Echo ---------------------------------------
openssl genrsa -des3 -out ca.key.pem 4096
@Echo ---------------------------------------
@Echo Creating Root CA Certificate
@Echo Please supply prompted information.
@Echo ---------------------------------------
openssl req -config root-openssl.cnf -key .\ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out ca.cert.pem
@Echo ---------------------------------------
@Echo Verifing Root Certificate file.
@Echo ---------------------------------------
openssl x509 -noout -text -in ca.cert.pem
@Echo ---------------------------------------
@Echo Creating Private Key for Server
@Echo Note: the shorter length
@Echo if -aes256 is omitted then the password is not needed, 
@Echo Delphi Indy SSL Sockets have an easy way to supply password
@Echo so it's recommended to keep it
@ECho Typcially the password here will be different from the original root cert
@Echo ---------------------------------------
openssl genrsa -aes256 -out localhost.key.pem 2048
@Echo ---------------------------------------
@Echo Creating Certificate Request for localhost Server
@Echo Please supply prompted information.
@Echo Note: Common Name should be a fully qualified domain name.
@Echo       For single machine development purposes you can use "localhost" 
@ECho       The resulting file will say localhost regardless of input, but can be renamed after this process.
@Echo ---------------------------------------
openssl req -config root-openssl.cnf -key .\localhost.key.pem -new -sha256 -out localhost.csr.pem
@Echo ---------------------------------------
@Echo Signing Certificate Request to create certificate
@Echo ---------------------------------------
openssl ca -config root-openssl.cnf -extensions server_cert -days 375 -notext -md sha256 -in .\localhost.csr.pem -out localhost.cert.pem
:END
endlocal
