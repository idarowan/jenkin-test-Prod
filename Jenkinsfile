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
                    // Install Packer if not installed
                    sh '''
                    if ! command -v packer &> /dev/null
                    then
                        echo "Packer not found, installing..."
                        brew tap hashicorp/tap
                        brew install hashicorp/tap/packer
                    else
                        echo "Packer is already installed"
                    fi
                    '''

                    // Install Ansible if not installed
                    sh '''
                    if ! command -v ansible &> /dev/null
                    then
                        echo "Ansible not found, installing..."
                        brew install ansible
                    else
                        echo "Ansible is already installed"
                    fi
                    '''
                }
            }
        }

        stage('Build AMI with Packer') {
            steps {
                sh 'packer init ./packer-ansible/packer-template.pkr.hcl'
                sh 'packer build ./packer-ansible/packer-template.pkr.hcl > output.txt'
                script {
                    def amiId = sh(script: "grep 'ami-' output.txt | tail -n 1 | awk '{print \$2}'", returnStdout: true).trim()
                    env.AMI_ID = amiId
                }
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
