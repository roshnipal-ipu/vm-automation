pipeline {
  agent any
  stages {
    stage('Terraform Init') {
      steps {
        dir('terraform') {
          sh 'terraform init'
        }
      }
    }
    stage('Terraform Apply') {
      steps {
        dir('terraform') {
          sh 'terraform apply -auto-approve'
        }
      }
    }
    stage('Run Ansible') {
      steps {
        sh 'terraform output -json > tf_output.json'
        script {
          def ips = sh(script: "jq -r '.vm_ips.value[]' tf_output.json", returnStdout: true).trim().split()
          writeFile file: 'ansible/inventory.ini', text: "[all]\n" + ips.collect { it + " ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa_jenkins" }.join("\n")
        }
        sh 'ansible-playbook -i ansible/inventory.ini ansible/playbook.yml'
      }
    }
    stage('Terraform Destroy') {
      when {
        expression { return params.DESTROY == true }
      }
      steps {
        dir('terraform') {
          sh 'terraform destroy -auto-approve'
        }
      }
    }
  }
  parameters {
    booleanParam(name: 'DESTROY', defaultValue: false, description: 'Destroy VMs?')
  }
}
