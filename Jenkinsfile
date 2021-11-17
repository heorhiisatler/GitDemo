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
        stage('Deploy') {
            steps {
                echo "Deploy"
            }
        }
    }
}
