if [ -f .env ]; then
  export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
fi

cat << "EOF"
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄        ▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄        ▄  ▄▄▄▄▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ 
▐░░░░░░░░░░░▌▐░░▌      ▐░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░▌      ▐░▌▐░░░░░░░░░░░▌   ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀█░▌▐░▌░▌     ▐░▌ ▀▀▀▀▀█░█▀▀▀ ▐░▌       ▐░▌▐░▌░▌     ▐░▌▐░█▀▀▀▀▀▀▀█░▌    ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌
▐░▌       ▐░▌▐░▌▐░▌    ▐░▌      ▐░▌    ▐░▌       ▐░▌▐░▌▐░▌    ▐░▌▐░▌       ▐░▌        ▐░▌     ▐░▌       ▐░▌
▐░█▄▄▄▄▄▄▄█░▌▐░▌ ▐░▌   ▐░▌      ▐░▌    ▐░▌       ▐░▌▐░▌ ▐░▌   ▐░▌▐░█▄▄▄▄▄▄▄█░▌        ▐░▌     ▐░▌       ▐░▌
▐░░░░░░░░░░░▌▐░▌  ▐░▌  ▐░▌      ▐░▌    ▐░▌       ▐░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌        ▐░▌     ▐░▌       ▐░▌
▐░█▀▀▀▀▀▀▀█░▌▐░▌   ▐░▌ ▐░▌      ▐░▌    ▐░▌       ▐░▌▐░▌   ▐░▌ ▐░▌▐░█▀▀▀▀▀▀▀█░▌        ▐░▌     ▐░▌       ▐░▌
▐░▌       ▐░▌▐░▌    ▐░▌▐░▌      ▐░▌    ▐░▌       ▐░▌▐░▌    ▐░▌▐░▌▐░▌       ▐░▌        ▐░▌     ▐░▌       ▐░▌
▐░▌       ▐░▌▐░▌     ▐░▐░▌ ▄▄▄▄▄█░▌    ▐░█▄▄▄▄▄▄▄█░▌▐░▌     ▐░▐░▌▐░▌       ▐░▌ ▄  ▄▄▄▄█░█▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌
▐░▌       ▐░▌▐░▌      ▐░░▌▐░░░░░░░▌    ▐░░░░░░░░░░░▌▐░▌      ▐░░▌▐░▌       ▐░▌▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
 ▀         ▀  ▀        ▀▀  ▀▀▀▀▀▀▀      ▀▀▀▀▀▀▀▀▀▀▀  ▀        ▀▀  ▀         ▀  ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀ 
EOF

echo "Installting AWS Linux Extra"
echo "---------------------------"
sudo amazon-linux-extras install -y aws-nitro-enclaves-cli
echo "Installing AWS Nitro Dev and OpenSSL Env"
sudo yum install -y aws-nitro-enclaves-cli-devel jq openssl11-libs
echo -ne '>>>                       [20%]\r'
sleep 2
clear

echo "Modifying EC2 User"
echo "---------------------------"
sudo usermod -aG ne ec2-user
echo "Adding EC2-USER to Docker Group"
sudo usermod -aG docker ec2-user
echo -ne '>>>>>>>                   [40%]\r'
sleep 2
clear

echo "Installing Docker"
echo "---------------------------"
sudo yum install -y docker
echo -ne '>>>>>>>                   [45%]\r'
sleep 2
clear

echo "Enable Docker"
echo "---------------------------"
sudo systemctl enable docker
sleep 2
echo -ne '>>>>>>>>>                 [50%]\r'
clear 

echo "Enable Kernel Module"
echo "---------------------------"
echo 'KERNEL=="vsock", MODE="660", GROUP="ne"' | sudo tee /etc/udev/rules.d/51-vsock.rules
sleep 2
echo -ne '>>>>>>>>>>>>>>            [60%]\r'
clear 

echo "Reloading UDEVADM" 
echo "---------------------------"
sudo udevadm control --reload
echo -ne '>>>>>>>>>>>>>>            [65%]\r'

clear 

echo "Trigger UDEVADM"
echo "---------------------------"
sudo udevadm trigger
sleep 2
echo -ne '>>>>>>>>>>>>>>            [70%]\r'
clear

echo "Change Allocator Memory"
echo "---------------------------"
sudo sed -i 's/^memory_mib:.*/memory_mib: $MEMORY/' /etc/nitro_enclaves/allocator.yaml
sleep 2
echo -ne '>>>>>>>>>>>>>>            [75%]\r'
clear

echo "Starting Allocator"
echo "---------------------------"
sudo systemctl start nitro-enclaves-allocator.service
sleep 2
echo -ne '>>>>>>>>>>>>>>            [76%]\r'
clear

echo "Enable Allocator" 
echo "---------------------------"
sudo systemctl enable nitro-enclaves-allocator.service
sleep 2
echo -ne '>>>>>>>>>>>>>>            [78%]\r'
clear

echo "Start and Enable Docker"
echo "---------------------------"
sudo systemctl start docker && sudo systemctl enable docker
sleep 2
echo -ne '>>>>>>>>>>>>>>            [80%]\r'
clear

echo "Create Opt Directory"
echo "---------------------------"
sudo mkdir -p /opt/anjuna/nitro
sleep 2
echo -ne '>>>>>>>>>>>>>>>>          [84%]\r'
clear

echo "Download Binary"
echo "---------------------------"
wget https://api.downloads.anjuna.io/v1/releases/anjuna-nitro-runtime.$VERSION.tar.gz \
  --header="X-Anjuna-Auth-Token:$APIKEY"
sleep 2
echo -ne '>>>>>>>>>>>>>>>>>>        [86%]\r'
clear

echo "Extract Binary"
echo "---------------------------"
sudo tar -xvoz -C /opt/anjuna/nitro -f anjuna-nitro-runtime.$VERSION.tar.gz
sleep 2
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>   [90%]\r'
clear

echo "Net Cap Enabled"
echo "---------------------------"
sudo setcap cap_net_bind_service=+ep  /opt/anjuna/nitro/bin/anjuna-nitro-netd-parent
sleep 2
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>  [94%]\r'
clear

echo "Export Variables"
echo "---------------------------"
export PATH=$PATH:/opt/anjuna/nitro/bin
sleep 2
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>> [96%]\r'
clear

echo "Create Log Directory"
echo "---------------------------"
sudo mkdir -p /var/log/nitro_enclaves
sleep 2
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>> [98%]\r'
clear

echo "Completed"
echo -ne '>>>>>>>>>>>>>>>>>>>>>>>>>>[100%]\r'
echo -ne '\n'
