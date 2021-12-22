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
                        sh 'echo $PASSWORD | docker login -u $USER --password-stdin'
                        sh 'docker push decepticon1984/java-demo:1.0'
                    }
                    
                }            
            }
        }
        stage('Deploy to QA-server on AWS EC2') {
            when {
                expression { choise == 'aws' }
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        echo 'Deploying to AWS EC2'
                        def ansible_cmd = '. ./ansible-playbook.sh $USER $PASSWORD'
                        sshagent(['ControlServer']) {
                            sh 'scp ansible-playbook.sh remoteplaybook_aws.yml decepticon@192.168.5.12:~'
                            sh "ssh -o StrictHostKeyChecking=no decepticon@192.168.5.12 ${ansible_cmd}"
                        }
                    }
                }

            }
        }
        stage('Deploy to QA-server on PVE2') {
            when {
                expression { choise == 'pve' }
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        echo 'Deploying to PVE2'
                        def ansible_cmd = '. ./ansible-playbook.sh $USER $PASSWORD'
                        sshagent(['ControlServer']) {
                            sh 'scp ansible-playbook.sh remoteplaybook_centos_dhub.yml decepticon@192.168.5.12:~'
                            sh "ssh -o StrictHostKeyChecking=no decepticon@192.168.5.12 ${ansible_cmd}"
                        }
                    }
                }

            }
        }
    }
}
