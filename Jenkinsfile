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
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        echo "Deploying to centos-vm-qa-0 (on PVE2 node)"
                        def ansible_cmd = '. ./ansible-playbook.sh $USER $PASSWORD'
                        sshagent(['ControlServer']) {
                            sh "scp ansible-playbook.sh decepticon@192.168.5.12:~"
                            sh "ssh -o StrictHostKeyChecking=no decepticon@192.168.5.12 ${ansible_cmd}"
                        }
                    }
                }

            }
        }
    }
}
