pipeline {
    agent {
        label 'ag-2'
    }
    environment {
        IMAGE_NAME = "calcwebappmvn:${BUILD_NUMBER}"
        my_aws_access = credentials('my-aws-cred')
    }
    tools {
        maven 'xyz-maven'
    }

    stages {

        stage('Git Checkout') {
            steps {
                git url: 'https://github.com/mayur-z/calcwebappmvn.git'
                echo "Code Checked-out Successfully!!";
                sh 'ls -la'
            }
        }

        stage('SonarQube analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        try {
                            def qg = waitForQualityGate()
                            echo "Quality Gate Status: ${qg.status}"
                            if (qg.status != 'OK') {
                                error "Quality Gate failed: ${qg.status}"
                            }
                        } catch (Exception e) {
                            echo "Quality Gate check failed: ${e.message}"
                            error "Quality Gate stage failed"
                        }
                    }
                }
            }
        }
 
        stage('Package Application .war') {
            steps {
                sh 'ls -la'
                sh 'mvn clean'
                sh 'mvn package'
                echo "Maven Package Goal Executed Successfully!";
                sh 'ls -la'
            }
        }
        stage('docker image build') {
            steps {
                sh 'which docker'
                sh 'docker --version'
                sh 'docker ps'
                sh 'docker images'
                //sh 'docker rmi -f ${docker images -q}'
                //docker system prune -a
                // sh 'docker build -t calcwebappmvn:v1 .' 
                sh 'docker build -t ${IMAGE_NAME} .'
                echo "Docker Image Built Successfully!!"
                sh 'docker images'
            }
        }

        stage('ECRLogin') {
            steps {
                sh 'aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 964742912902.dkr.ecr.us-west-2.amazonaws.com'
                echo "Logged in to AWS ECR Successfully!!"

                sh 'docker tag ${IMAGE_NAME} 964742912902.dkr.ecr.us-west-2.amazonaws.com/dev/calculator:${BUILD_NUMBER}'
                echo "Docker Image Tagged Successfully!!"
                sh 'docker images'
            }
        }

        stage('Push to ECR') {
            steps {
                sh 'docker push 964742912902.dkr.ecr.us-west-2.amazonaws.com/dev/calculator:${BUILD_NUMBER}'
                echo "Docker Image Pushed to ECR Successfully!!"
            }
        }


        stage('kubeconfig setup') {
            steps {
                sh 'aws eks update-kubeconfig --region us-west-2 --name my-cluster'
                echo "Kubeconfig setup completed successfully!!"
            }
        }

        stage('get all resources') {
            steps {

                sh 'kubectl get all'
                echo "Verified access to EKS cluster successfully!!"

                //sh 'kubectl apply -f k8s-deployment.yaml'
                //echo "Application Deployed to EKS Successfully!!"
            }
        }
    }
    post {
        success {
            echo 'pipeline is successful'
        }
        failure {
            echo 'pipeline is FAILED'
        }
    }
}
