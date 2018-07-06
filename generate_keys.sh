sudo apt-get install -y wget openssl python-pip
openssl ecparam -genkey -name prime256v1 -noout -out ec_private.pem
openssl ec -in ec_private.pem -pubout -out ec_public.pem
wget -N https://pki.goog/roots.pem
