pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-west-1'
        PACKER_TEMPLATE = 'packer-template.pkr.hcl'
        ANSIBLE_PLAYBOOK = '/ansible/playbook.yml'
        TERRAFORM_CONFIG_DIR = 'terraform-ec2'
        PACKER_DIR = "${env.WORKSPACE}/packer-bin"
        TERRAFORM_BIN_DIR = "${env.WORKSPACE}/terraform-bin"
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

        stage('Install Terraform') {
            steps {
                script {
                    sh '''
                    # Determine the OS and Architecture
                    OS=$(uname | tr '[:upper:]' '[:lower:]')
                    ARCH=$(uname -m)
                    TERRAFORM_VERSION="1.1.7"
                    
                    if [ "$ARCH" == "x86_64" ]; then
                        ARCH="amd64"
                    fi
                    
                    TERRAFORM_BINARY="terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"

                    # Install Terraform if not already installed
                    if ! command -v terraform &> /dev/null
                    then
                        echo "Terraform could not be found. Installing..."
                        if command -v curl &> /dev/null
                        then
                            curl -o $TERRAFORM_BINARY https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_BINARY}
                        else
                            echo "curl could not be found. Exiting..."
                            exit 1
                        fi
                        unzip $TERRAFORM_BINARY
                        mkdir -p ${TERRAFORM_BIN_DIR}
                        mv terraform ${TERRAFORM_BIN_DIR}/
                    fi

                    # Add Terraform directory to PATH
                    export PATH=${TERRAFORM_BIN_DIR}:$PATH
                    '''
                }
            }
        }

        stage('Install Ansible') {
            steps {
                script {
                    sh '''
                    # Determine the OS and Architecture
                    OS=$(uname | tr '[:upper:]' '[:lower:]')
                    ARCH=$(uname -m)

                    if [ "$ARCH" == "x86_64" ]; then
                        ARCH="amd64"
                    fi
                    
                    # Install Ansible if not already installed
                    if ! command -v ansible-playbook &> /dev/null
                    then
                        echo "Ansible could not be found. Installing..."
                        
                        if [ "$OS" == "linux" ]; then
                            sudo apt-get update
                            sudo apt-get install -y software-properties-common
                            sudo apt-add-repository --yes --update ppa:ansible/ansible
                            sudo apt-get install -y ansible
                        elif [ "$OS" == "darwin" ]; then
                            echo "Installing Ansible on macOS..."
                            if command -v python3 &> /dev/null
                            then
                                PYTHON=python3
                            elif command -v python &> /dev/null
                            then
                                PYTHON=python
                            else
                                echo "Python is not installed. Exiting..."
                                exit 1
                            fi
                            curl -O https://bootstrap.pypa.io/get-pip.py
                            $PYTHON get-pip.py --user
                            $PYTHON -m pip install --user ansible
                        else
                            echo "Unsupported OS. Exiting..."
                            exit 1
                        fi

                        # Add Ansible directory to PATH
                        export PATH=${HOME}/.local/bin:$PATH
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
                    sh '''
                    # Add Packer directory to PATH for this step
                    export PATH=${PACKER_DIR}:$PATH

                    # Change directory to where the Packer template is located
                    cd packer-ansible

                    packer init .
                    packer build ${PACKER_TEMPLATE} | tee ../packer_output.txt
                    '''
                    AMI_ID = sh(script: "grep -o 'ami-\\w\\+' ../packer_output.txt | tail -1", returnStdout: true).trim()
                    echo "AMI ID: ${AMI_ID}"
                }
            }
        }

        stage('Deploy EC2 Instances with Terraform') {
            steps {
                script {
                    writeFile file: "${TERRAFORM_CONFIG_DIR}/ami.tfvars", text: "ami_id = \"${AMI_ID}\""

                    dir("${TERRAFORM_CONFIG_DIR}") {
                        sh '''
                        # Add Terraform directory to PATH for this step
                        export PATH=${TERRAFORM_BIN_DIR}:$PATH
                        
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
