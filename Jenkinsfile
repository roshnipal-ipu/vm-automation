pipeline {
    agent any

    parameters {
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'Destroy VMs after provisioning?')
    }

    environment {
        SSH_KEY = credentials('github-ssh-key') // For GitHub SSH
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'git@github.com:roshnipal-ipu/vm-automation.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'vsphere-creds', usernameVariable: 'VSPHERE_USER', passwordVariable: 'VSPHERE_PASS')]) {
                    dir('terraform') {
                        sh '''
                        export TF_VAR_vsphere_user=$VSPHERE_USER
                        export TF_VAR_vsphere_password=$VSPHERE_PASS
                        terraform init
                        terraform validate
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return params.DESTROY == false }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'vsphere-creds', usernameVariable: 'VSPHERE_USER', passwordVariable: 'VSPHERE_PASS')]) {
                    dir('terraform') {
                        sh '''
                        export TF_VAR_vsphere_user=$VSPHERE_USER
                        export TF_VAR_vsphere_password=$VSPHERE_PASS
                        terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Generate Ansible Inventory') {
            when {
                expression { return params.DESTROY == false }
            }
            steps {
                sh 'terraform output -json > tf_output.json'
                script {
                    def ips = sh(script: "jq -r '.vm_ips.value[]' tf_output.json", returnStdout: true).trim().split('\\n')
                    def inventoryContent = "[all]\\n" + ips.collect { it + " ansible_user=root ansible_ssh_private_key_file=/var/lib/jenkins/.ssh/id_rsa" }.join("\\n")
                    writeFile file: 'ansible/inventory.ini', text: inventoryContent
                }
            }
        }

        stage('Run Ansible') {
            when {
                expression { return params.DESTROY == false }
            }
            steps {
                sh 'ansible-playbook -i ansible/inventory.ini ansible/playbook.yml'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { return params.DESTROY == true }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'vsphere-creds', usernameVariable: 'VSPHERE_USER', passwordVariable: 'VSPHERE_PASS')]) {
                    dir('terraform') {
                        sh '''
                        export TF_VAR_vsphere_user=$VSPHERE_USER
                        export TF_VAR_vsphere_password=$VSPHERE_PASS
                        terraform destroy -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'terraform/*.tfstate, tf_output.json, ansible/inventory.ini', fingerprint: true
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
