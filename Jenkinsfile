pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-west-1'
        PATH = "/opt/homebrew/bin:$PATH"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/idarowan/jerk_test.git'
            }
        }

        stage('Print Working Directory') {
            steps {
                sh 'pwd'
                sh 'ls -R' // List all files and directories in the workspace
            }
        }

        stage('Install Packer, Ansible, and Terraform') {
            steps {
                script {
                    // Use the full path to the Ansible binary
                    sh '''
                    if ! command -v /opt/homebrew/bin/ansible &> /dev/null
                    then
                        echo "Ansible not found, installing..."
                        /opt/homebrew/bin/brew install ansible
                    else
                        echo "Ansible is already installed"
                    fi
                    '''
                }
            }
        }

        stage('Build AMI with Packer') {
            steps {
                sh '/opt/homebrew/bin/packer init ./packer-ansible/packer-template.pkr.hcl'
                sh '/opt/homebrew/bin/packer build ./packer-ansible/packer-template.pkr.hcl > build_output.txt 2>&1 || cat build_output.txt'
                script {
                    def amiId = sh(script: "grep 'ami-' build_output.txt | tail -n 1 | awk '{print \$2}'", returnStdout: true).trim()
                    if (amiId) {
                        env.AMI_ID = amiId
                    } else {
                        error("Failed to retrieve AMI ID from Packer output")
                    }
                }
            }
        }

        stage('Deploy Infrastructure with Terraform') {
            steps {
                dir('terraform-ec2') {
                    sh '/opt/homebrew/bin/terraform init'
                    sh "/opt/homebrew/bin/terraform apply -var ami_id=${env.AMI_ID} -auto-approve"
                }
            }
        }
    }

    triggers {
        githubPush()
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
