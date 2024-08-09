pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-west-1'
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
                    // Install tools if needed
                    sh '''
                    if ! command -v /opt/homebrew/bin/packer &> /dev/null
                    then
                        /opt/homebrew/bin/brew tap hashicorp/tap
                        /opt/homebrew/bin/brew install hashicorp/tap/packer
                    fi

                    if ! command -v /opt/homebrew/bin/ansible &> /dev/null
                    then
                        /opt/homebrew/bin/brew install ansible
                    fi

                    if ! command -v /opt/homebrew/bin/terraform &> /dev/null
                    then
                        /opt/homebrew/bin/brew install terraform
                    fi
                    '''
                }
            }
        }

        stage('Build AMI with Packer') {
            steps {
                sh '/opt/homebrew/bin/packer init ./packer-ansible/packer-template.pkr.hcl'
                sh '/opt/homebrew/bin/packer build ./packer-ansible/packer-template.pkr.hcl > build_output.txt 2>&1 || cat build_output.txt'
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
