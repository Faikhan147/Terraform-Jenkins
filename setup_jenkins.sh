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

# Jenkins groovy plugins dir
sudo mkdir -p /var/lib/jenkins/init.groovy.d
sudo chmod -R 777 /var/lib/jenkins/init.groovy.d
sudo chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d

# Write install-plugins.groovy content
cat <<EOF | sudo tee /var/lib/jenkins/init.groovy.d/install-plugins.groovy
def plugins = [
    "git-parameter",          
    "github-oauth",           
    "pipeline-github",        
    "generic-webhook-trigger",
    "git-push",               
    "sonar",                  
    "slack"                   
]

def jenkinsInstance = jenkins.model.Jenkins.getInstance()
def pluginManager = jenkinsInstance.getPluginManager()
def updateCenter = jenkinsInstance.getUpdateCenter()

plugins.each {
    def plugin = pluginManager.getPlugin(it)
    if (!plugin) {
        def pluginToInstall = updateCenter.getPlugin(it)
        if (pluginToInstall) {
            pluginToInstall.deploy()
            println("Plugin \${it} has been installed.")
        } else {
            println("Plugin \${it} not found.")
        }
    } else {
        println("Plugin \${it} is already installed.")
    }
}
jenkinsInstance.save()
EOF

# Set permissions for plugin script
sudo chown jenkins:jenkins /var/lib/jenkins/init.groovy.d/install-plugins.groovy
sudo chmod 755 /var/lib/jenkins/init.groovy.d/install-plugins.groovy

# Setup JCasC
sudo mkdir -p /var/lib/jenkins/casc_configs
sudo chown -R jenkins:jenkins /var/lib/jenkins/casc_configs

# Move pre-written YAML from /tmp to correct folder
sudo mv /tmp/slack-credentials.yaml /var/lib/jenkins/casc_configs/
sudo chown jenkins:jenkins /var/lib/jenkins/casc_configs/slack-credentials.yaml
sudo chmod 644 /var/lib/jenkins/casc_configs/slack-credentials.yaml

echo 'SLACK_SECRET=https://hooks.slack.com/services/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' | sudo tee -a /etc/default/jenkins
echo 'CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs' | sudo tee -a /etc/default/jenkins

# Install SSM Agent
sudo snap install amazon-ssm-agent --classic
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Final Jenkins restart
sudo systemctl restart jenkins
