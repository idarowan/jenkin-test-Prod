pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-west-1'
        PACKER_TEMPLATE = 'packer-ansible/packer-template.pkr.hcl'  // updated for simplicity
        ANSIBLE_PLAYBOOK = 'packer-ansible/ansible/playbook.yml'
        TERRAFORM_DIR = 'terraform-ec2'
        AMI_ID = ''
        PACKER_DIR = "${env.WORKSPACE}/packer-bin"
    }

    stages {
        stage('Install Packer') {
            steps {
                script {
                    sh '''
                    # Determine the OS and Architecture
                    OS=$(uname | tr '[:upper:]' '[:lower:]')
                    ARCH=$(uname -m)
                    PACKER_VERSION="1.7.8"
                    
                    if [ "$ARCH" == "x86_64" ]; then
                        ARCH="amd64"
                    fi
                    
                    PACKER_BINARY="packer_${PACKER_VERSION}_${OS}_${ARCH}.zip"

                    # Install Packer if not already installed
                    if ! command -v packer &> /dev/null
                    then
                        echo "Packer could not be found. Installing..."
                        if command -v curl &> /dev/null
                        then
                            curl -o $PACKER_BINARY https://releases.hashicorp.com/packer/${PACKER_VERSION}/${PACKER_BINARY}
                        else
                            echo "curl could not be found. Exiting..."
                            exit 1
                        fi
                        unzip $PACKER_BINARY
                        mkdir -p ${PACKER_DIR}
                        mv packer ${PACKER_DIR}/
                    fi

                    # Add Packer directory to PATH
                    export PATH=${PACKER_DIR}:$PATH
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
                    sh '''
                    # Add Packer directory to PATH for this step
                    export PATH=${PACKER_DIR}:$PATH

                    # Change directory to where the Packer template is located
                    cd packer-ansible

                    packer init .
                    packer build ${PACKER_TEMPLATE} | tee ../packer_output.txt
                    '''
                    AMI_ID = sh(script: "grep -oP 'ami-\\w+' ../packer_output.txt | tail -1", returnStdout: true).trim()
                    echo "AMI ID: ${AMI_ID}"
                }
            }
        }

        stage('Deploy EC2 Instances with Terraform') {
            steps {
                script {
                    writeFile file: "${TERRAFORM_DIR}/ami.tfvars", text: "ami_id = \"${AMI_ID}\""

                    dir("${TERRAFORM_DIR}") {
                        sh '''
                        terraform init
                        terraform apply -var-file=ami.tfvars -auto-approve
                        '''
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