def installTerraform() {
    // Check if terraform is already installed
    def terraformExists = sh(script: 'which terraform', returnStatus: true)

    if (terraformExists != 0) {
        sh '''
            echo "Installing Terraform..."
            wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip
            unzip terraform_1.0.0_linux_amd64.zip
            sudo mv terraform /usr/local/bin/terraform
            rm -f terraform_1.0.0_linux_amd64.zip
            terraform --version
        '''
    } else {
        echo "Terraform already installed!"
    }
}

pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('Install Terraform') {
            steps {
                script {
                    installTerraform()
                }
            }
        }

        stage('Terraform Deployment') {
            steps {
                dir('deployment') {
                    sh '''
                        terraform init
                        terraform plan
                        terraform apply -auto-approve
                    '''
                }
            }
        }
    }
 }
}
