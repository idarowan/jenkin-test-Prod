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
                    sh '''
                    if ! command -v /opt/homebrew/bin/ansible-playbook &> /dev/null
                    then
                        echo "Ansible-playbook not found, installing..."
                        /opt/homebrew/bin/brew install ansible
                    else
                        echo "Ansible-playbook is already installed"
                    fi
                    '''
                }
            }
        }

        stage('Build AMI with Packer') {
    steps {
        timeout(time: 15, unit: 'MINUTES') {
            sh '''
            /opt/homebrew/bin/packer init ./packer-ansible/packer-template.pkr.hcl
            /opt/homebrew/bin/packer build ./packer-ansible/packer-template.pkr.hcl > build_output.txt 2>&1 || cat build_output.txt
            '''
        }
    }
}

stage('Extract AMI ID') {
    steps {
        script {
            def amiId = sh(script: "grep 'ami-' build_output.txt | tail -n 1 | awk '{print \$2}'", returnStdout: true).trim()
            if (!amiId.startsWith('ami-')) {
                error "Failed to extract AMI ID from Packer output"
            }
            env.AMI_ID = amiId
            echo "Extracted AMI ID: ${env.AMI_ID}"
        }
    }
}



        stage('Deploy Infrastructure with Terraform') {
    when {
        expression {
            return env.AMI_ID != null && env.AMI_ID != 'null'
        }
    }
    steps {
        dir('terraform-ec2') {
            sh '/opt/homebrew/bin/terraform init'
            sh "/opt/homebrew/bin/terraform apply -var ami_id=${env.AMI_ID} -auto-approve"
        }
    }
}

stage('Debug Packer Output') {
    steps {
        sh 'cat build_output.txt'
    }
}


    }

    triggers {
        githubPush()
    }

}
