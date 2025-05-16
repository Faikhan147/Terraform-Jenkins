#!/bin/bash

# Update and install Java
sudo apt update -y
sudo apt install openjdk-21-jdk -y
java -version

# Install Jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y

# Replace jenkins.service content
cat <<EOF | sudo tee /usr/lib/systemd/system/jenkins.service > /dev/null
[Unit]
Description=Jenkins Continuous Integration Server
After=network.target

[Service]
Type=simple
EnvironmentFile=/etc/default/jenkins
ExecStart=/usr/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --webroot=/var/cache/jenkins/war --httpPort=8080
User=jenkins
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Replace /etc/default/jenkins content
cat <<EOF | sudo tee /etc/default/jenkins > /dev/null
# Jenkins home directory
JENKINS_HOME="/var/lib/jenkins"

CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs
EOF

# Reload systemd and start Jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install docker-ce -y
sudo usermod -aG docker jenkins
docker --version
sudo systemctl restart jenkins

# Install AWS CLI
sudo apt install unzip -y
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Install Trivy
sudo apt install wget curl -y
TRIVY_URL=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest \
  | grep "browser_download_url" \
  | grep "Linux-64bit.deb\"" \
  | head -n 1 \
  | cut -d '"' -f 4)
wget "$TRIVY_URL" -O trivy_latest.deb
sudo dpkg -i trivy_latest.deb
trivy --version

# Install Sonar Scanner
sudo mkdir -p /opt/sonar-scanner
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
sudo unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux/* /opt/sonar-scanner/
sudo rm -rf sonar-scanner-5.0.1.3006-linux
sudo chown -R jenkins:jenkins /opt/sonar-scanner
/opt/sonar-scanner/bin/sonar-scanner -v

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

# Install Node.js and npm
sudo apt install nodejs npm -y
node -v
npm -v

# Jenkins tmp permissions
sudo mkdir -p /var/lib/jenkins@tmp
sudo chmod -R 777 /var/lib/jenkins@tmp
sudo chown -R jenkins:jenkins /var/lib/jenkins@tmp

# Setup groovy and JCAS dir for Jenkins-Plugins and Jenkins-Pipelines  
sudo mkdir -p /var/lib/jenkins/init.groovy.d
sudo mkdir -p /var/lib/jenkins/casc_configs
sudo mkdir -p /var/lib/jenkins/dsl_scripts
sudo chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d
sudo chown -R jenkins:jenkins /var/lib/jenkins/casc_configs/
sudo chown -R jenkins:jenkins /var/lib/jenkins/dsl_scripts/
sudo chmod -R 777 /var/lib/jenkins/init.groovy.d
sudo find /var/lib/jenkins/casc_configs/ -type f -name "*.yaml" -exec chmod 777 {} \;
sudo find /var/lib/jenkins/dsl_scripts/ -type f -name "*.yaml" -exec chmod 777 {} \;

# Copy Jenkins Plugins  YAML file from S3 folder to Jenkins config folder
sudo aws s3 cp s3://terraform-backend-faisal-khan/Jenkins-Plugins/  /var/lib/jenkins/init.groovy.d/ --recursive

# Copy all Credentials YAML files from S3 folder to Jenkins config folder
sudo aws s3 cp s3://terraform-backend-faisal-khan/Jenkins-Credentials/ /var/lib/jenkins/casc_configs/ --recursive

# Copy SonarQube Authentication YAML file from S3 folder to Jenkins config folder
sudo aws s3 cp s3://terraform-backend-faisal-khan/Jenkins-System/sonar-authentication.yaml /var/lib/jenkins/casc_configs/

# Copy SonarQube Scanner YAML file from S3 folder to Jenkins config folder
sudo aws s3 cp s3://terraform-backend-faisal-khan/Jenkins-Tools/sonar-scanner.yaml /var/lib/jenkins/casc_configs/

# Copy seed Job  YAML file from S3 folder to Jenkins config folder
sudo aws s3 cp s3://terraform-backend-faisal-khan/Jenkins-Pipelines/seed-job /var/lib/jenkins/init.groovy.d/ --recursive

# Final Jenkins restart
sudo systemctl restart jenkins
