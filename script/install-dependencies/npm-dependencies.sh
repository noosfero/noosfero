# Use a newest node version.
apt remove -y nodejs npm
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt install -y nodejs ruby-execjs ruby-uglifier

# javascript framework to run end-to-end tests.
npm install cypress
