[![GitHub Release](https://img.shields.io/github/release/dani-garcia/vaultwarden.svg)](https://github.com/domeger/Anjuna-VaultWithConsul/releases/latest)
[![GPL-3.0 Licensed](https://img.shields.io/github/license/dani-garcia/vaultwarden.svg)](https://www.gnu.org/licenses/gpl-3.0.txt)

# Anjuna Security: Hashicorp Vault with Consul

**Requirements:** Amazon AMI\
**Technologies:** Vault, Consul, Anjuna Runtime, and Docker\
**Instance Type:** m5.xlarge or higher instance

# Instance Preparation 
Complete the steps in our docs to be able to complete this step by step setup of Vault with Consul storage.

**Getting Started:**
[Anjuna Security Nitro Onboarding Tutorial](https://docs.anjuna.io/anjuna-nitro-runtime/anjuna-nitro/latest/getting_started/getting_the_runtime.html) or Register on the [Download Portal](downloads.anjuna.io), grab your API key, paste your API key into the .env file and run the ./deployment.sh 

# Consul Setup
**Step 1:**
`sudo yum install -y yum-utils`

**Step 2:** 
`sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo`

**Step 3**
`sudo yum -y install consul`

**Step 4**
Run the following command in a background process
`consul agent -server -advertise=127.0.0.1 -data-dir=consul/data/ -bootstrap &`

# Docker Setup
**Step 1:**
Installing Docker
`sudo yum install docker`

**Step 2:**
Enabling Docker
`sudo systemctl enable docker`

**Step 3:**
Starting Docker
`sudo systemctl start docker`

** Step 4:**
Verifying Docker is running.
`sudo systemctl status docker`

# Vault Client Setup
**Step 1:**
`sudo yum install -y yum-utils`

**Step 2:**
`sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo`

**Step 3:**
`sudo yum -y install vault`

# Vault Setup (Sealed Version)

**Step 1:**
Clone this repo to your /home/ec2-user/ instance and edit the config.json file.
`vi config.json`

**Step 2:**
In the config file change localhost to 192.168.127.254 as this is the static ip of the enclave.
```

SKIP_SETCAP = true
disable_mlock = true

storage "consul" {
address = "192.168.127.254:8500"
path = "vault"
}

listener "tcp" {
address = ":8200"
tls_disable = 1
}

```

**Step 3:**
In this step were going to build the docker image.
`docker build -t vault .`

**Step 4:**
Expose the port so the Enclave can talk to the EC2 Node
`/opt/anjuna/nitro/bin/anjuna-nitro-netd-parent --expose 8200 --daemonize`


**Step 5:**
We will than build the file and push it into the enclave environment.
`anjuna-nitro-cli build-enclave --docker-uri vault:latest --enclave-config-file enclave-config.yaml --output-file vault.eif`

Now Let Run the Enclave
```
anjuna-nitro-cli run-enclave \
 --cpu-count 2 \
 --memory 2048 \
 --eif-path vault.eif
 ```

**Step 6:**
We will than verify the enclave is running.
`anjuna-nitro-cli describe-enclaves | jq`

![Nitro Status](https://github.com/domeger/Anjuna-VaultWithConsul/blob/main/EnclaveStatus.png)

**Step 7:**
Verify you can communicate with your Vault instance
```
curl -s http://localhost:8200/v1/sys/health | jq -r 
export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN=
vault status
```

![Vault Status](https://github.com/domeger/Anjuna-VaultWithConsul/blob/main/VaultStatus.png)

**Step 8:**
Initialize the Vault Repo and make sure you copy the keys that are display on your screen, these will be necessary to unseal vault to access it.

```vault operator init```


**Optional:**
Terminate the instance if your done testing.

`anjuna-nitro-cli terminate-enclave`

# Copying or Reusing

This project has mixed licencing. You are free to copy, redistribute and/or modify aspects of this work under the terms of each licence accordingly (unless otherwise specified).

Included scripts are free software licenced under the terms of the [GNU General Public License, version 3](https://www.gnu.org/licenses/gpl-3.0.txt).
