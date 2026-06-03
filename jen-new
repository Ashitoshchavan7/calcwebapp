pipeline {
    agent {
        label 'ag-2'
    }
    environment {
        cluster_name = "my-cluster-1"
        Region = "us-west-2"
        IMAGE_NAME = "calcwebappmvn:v1"
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

                sh 'docker tag ${IMAGE_NAME} 964742912902.dkr.ecr.us-west-2.amazonaws.com/dev/calculator:v1'
                echo "Docker Image Tagged Successfully!!"
                sh 'docker images'
            }
        }

        stage('Push to ECR') {
            steps {
                sh 'docker push 964742912902.dkr.ecr.us-west-2.amazonaws.com/dev/calculator:v1'
                echo "Docker Image Pushed to ECR Successfully!!"
            }
        }


        stage('kubeconfig setup') {
            steps {
                sh 'aws eks update-kubeconfig --region ${Region} --name ${cluster_name}'
                // sh '''kubectl create secret docker-registry my-ecr-secret-cbz \
                //       --docker-server=964742912902.dkr.ecr.${Region}.amazonaws.com \
                //       --docker-username=AWS \
                //       --docker-password=$(aws ecr get-login-password --region ${Region})'''

                
                echo "Kubeconfig setup and secret creation completed successfully!!"
            }
        }

        stage('get all resources') {
            steps {

                sh 'kubectl get all'
                sh 'kubectl get secrets'
                echo "Verified access to EKS cluster successfully!!"

                //sh 'kubectl apply -f k8s-deployment.yaml'
                //echo "Application Deployed to EKS Successfully!!"
            }
        }

        stage('deploy to eks') {
            steps {

                sh 'kubectl apply -f calc-deployment-svc.yaml'
                sh 'kubectl get all'
                sh 'sleep 20'
                sh 'kubectl get svc -o wide'
                echo ".war application deployed to EKS cluster successfully!!"

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
