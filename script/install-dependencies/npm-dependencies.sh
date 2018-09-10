dpkg -s nodejs &> /dev/null

if [ $? -eq 1  ]; then
  sudo apt install -y curl
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  sudo apt install -y nodejs ruby-execjs ruby-uglifier
  
  # javascript framework to run end-to-end tests.
  npm install cypress
fi
