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
        stage('Checkout Code') {
            steps {
                // Ensure this URL and branch are correct
                git branch: 'main', url: 'https://github.com/idarowan/jerk_test.git'
            }
        }

        stage('Build AMI with Packer') {
            steps {
                script {
                    // Ensure packer is installed and configured
                    sh """
                    packer init .
                    packer build ${PACKER_TEMPLATE} | tee packer_output.txt
                    """
                    // Extract AMI ID from Packer output
                    AMI_ID = sh(script: "grep -oP 'ami-\\w+' packer_output.txt | tail -1", returnStdout: true).trim()
                    echo "AMI ID: ${AMI_ID}"
                }
            }
        }

        stage('Deploy EC2 Instances with Terraform') {
            steps {
                script {
                    // Write the AMI ID to a Terraform variable file
                    writeFile file: "${TERRAFORM_DIR}/ami.tfvars", text: "ami_id = \"${AMI_ID}\""

                    dir("${TERRAFORM_DIR}") {
                        // Ensure terraform is installed and configured
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
