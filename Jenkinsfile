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
            }
        }

        stage('Install Packer and Ansible') {
            steps {
                script {
                    // Use the absolute path to Homebrew
                    sh '''
                    if ! command -v /opt/homebrew/bin/packer &> /dev/null
                    then
                        echo "Packer not found, installing..."
                        /opt/homebrew/bin/brew tap hashicorp/tap
                        /opt/homebrew/bin/brew install hashicorp/tap/packer
                    else
                        echo "Packer is already installed"
                    fi
                    '''

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
            }
        }

        stage('Deploy Infrastructure with Terraform') {
            steps {
                dir('terraform-ec2') {
                    sh 'terraform init'
                    sh "terraform apply -var ami_id=${env.AMI_ID} -auto-approve"
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
