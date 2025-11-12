// Jenkinsfile (declarative pipeline)
// Place at the repository root

def installTerraform() {
    // check if terraform exists
    def terraformExists = sh(script: "which terraform >/dev/null 2>&1 || echo 1", returnStdout: true).trim()
    if (terraformExists != "") {
        echo "Installing Terraform..."
        sh '''
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

    environment {
        // Optional: set AWS env vars here if needed, or ensure the agent already has permissions.
        // AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        // AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        // AWS_DEFAULT_REGION = 'eu-north-1'
    }

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

        stage('Terraform Format & Validate') {
            steps {
                script {
                    dir('deployment') {
                        // optional: format/validate before running
                        sh '''
                            terraform fmt -check || terraform fmt
                            terraform init -input=false
                            terraform validate || true
                        '''
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    dir('deployment') {
                        // Pass Jenkins BUILD_NUMBER to terraform as variable "build_number"
                        sh """
                            terraform plan -out=tfplan -var \"build_number=$BUILD_NUMBER\"
                        """
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    dir('deployment') {
                        sh """
                            terraform apply -auto-approve -var \"build_number=$BUILD_NUMBER\"
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Show the build number and a small marker in console
                echo "Jenkins BUILD_NUMBER = ${env.BUILD_NUMBER}"
                echo "If Terraform created resources, instance Name tag will include the build number."
            }
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
