sudo apt-get update
sudo apt-get install -y fonts-liberation libappindicator3-1 libasound2 \
                        libatk-bridge2.0-0 libatspi2.0-0 libgtk-3-0 libnspr4 \
                        libnss3 libx11-xcb1 libxss1 libxtst6 xdg-utils \
                        apt-transport-https
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
          -O google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo rm google-chrome-stable_current_amd64.deb
run bundle
