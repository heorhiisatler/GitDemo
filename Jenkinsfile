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
                        sh '''
                            docker build -t decepticon1984/java-demo:1.0 .
                            echo $PASSWORD | docker login -u $USER --password-stdin
                            docker push decepticon1984/java-demo:1.0
                        '''
                    }
                    
                }            
            }
        }
        stage('Provisioning with Terraform') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
                TF_VAR_env_prefix = 'test'
            }
            when {
                expression { choise == 'aws' }
            }
            steps {
                script {
                    dir('terraform') {
                        sh '''
                            terraform init
                            terraform plan
                            terraform apply --auto-approve
                        '''
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output -json ec2_public_ip | jq -r '.[0]'",
                            returnStdout: true
                        ).trim()
                        sh """
                            echo ${EC2_PUBLIC_IP}
                            echo ubuntu@${EC2_PUBLIC_IP} > ../hosts
                        """
                    }
                }

            }
        }
        stage('Deploy to QA-server on AWS EC2') {
            environment {
                ANSIBLE_HOST = '192.168.5.12'
            }
            when {
                expression { choise == 'aws' }
            }
            steps {
                script {
                    echo 'Waiting for ec2 instance ready...'
                    sleep(time: 90, unit: "SECONDS")
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                        echo 'Deploying to AWS EC2'
                        // def ansible_cmd = '. ./ansible-playbook-aws.sh $USER $PASSWORD'
                        sshagent(['ControlServer']) {
                            // Copy required files to the ansible server and runing playbook 
                            sh '''
                                scp hosts ansible-playbook-aws.sh remoteplaybook_aws.yml decepticon@$ANSIBLE_HOST:~
                                ssh -o StrictHostKeyChecking=no decepticon@$ANSIBLE_HOST \
                                . ./ansible-playbook-aws.sh $USER $PASSWORD
                            '''
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
                        def ansible_cmd = '. ./ansible-playbook-pve.sh $USER $PASSWORD'
                        sshagent(['ControlServer']) {
                            sh 'scp ansible-playbook-pve.sh remoteplaybook_centos_dhub.yml decepticon@$ANSIBLE_HOST:~'
                            sh "ssh -o StrictHostKeyChecking=no decepticon@$ANSIBLE_HOST ${ansible_cmd}"
                        }
                    }
                }

            }
        }
    }
}
