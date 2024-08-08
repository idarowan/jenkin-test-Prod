pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-west-1'
        PACKER_TEMPLATE = 'packer-ansible/packer-template.json'
        ANSIBLE_PLAYBOOK = 'packer-ansible/ansible/playbook.yml'
        TERRAFORM_DIR = 'terraform-ec2'
        AMI_ID = ''
    }

    stages {
        stage('Install Packer') {
            steps {
                script {
                    sh '''
                    # Install Packer if not already installed
                    if ! command -v packer &> /dev/null
                    then
                        echo "Packer could not be found. Installing..."
                        wget https://releases.hashicorp.com/packer/1.7.8/packer_1.7.8_linux_amd64.zip
                        unzip packer_1.7.8_linux_amd64.zip
                        sudo mv packer /usr/local/bin/
                    fi
                    '''
                }
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/idarowan/jerk_test.git'
            }
        }

        stage('Build AMI with Packer') {
            steps {
                script {
                    sh """
                    packer init .
                    packer build ${PACKER_TEMPLATE} | tee packer_output.txt
                    """
                    AMI_ID = sh(script: "grep -oP 'ami-\\w+' packer_output.txt | tail -1", returnStdout: true).trim()
                    echo "AMI ID: ${AMI_ID}"
                }
            }
        }

        stage('Deploy EC2 Instances with Terraform') {
            steps {
                script {
                    writeFile file: "${TERRAFORM_DIR}/ami.tfvars", text: "ami_id = \"${AMI_ID}\""

                    dir("${TERRAFORM_DIR}") {
                        sh """
                        terraform init
                        terraform apply -var-file=ami.tfvars -auto-approve
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
