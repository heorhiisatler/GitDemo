pipeline {
    agent any
    
    tools {
        maven 'maven-3.8.3'
    }
   
    stages {
        stage('Build jar') {
            steps {
                script {
                    echo "Building the application" 
                    sh 'mvn package'
                }            
            }
        }
        stage('Build Docker image') {
            steps {
                script {
                    echo "Building the docker image"
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        sh 'docker build -t decepticon1984/java-demo:1.0 .'
                        sh "echo $PASSWORD | docker login -u $USER --password-stdin"
                        sh 'docker push decepticon1984/java-demo:1.0'
                    }
                    
                }            
            }
        }
        stage('Deploy to QA-server') {
            steps {
                script {
                    echo "Deploying to centos-vm-qa-0 (on PVE2 node)"
                    def ansible_cmd = 'ansible-playbook -i hosts remoteplaybook_centos_dhub.yml'
                    sshagent(['ControlServer']) {
                        sh "ssh -o StrictHostKeyChecking=no decepticon@192.168.5.12 ${ansible_cmd}"
                    }
                }

            }
        }
    }
}
