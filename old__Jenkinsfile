pipeline {

    agent {
        label 'lb'
    }

    environment {
        IMAGE_NAME = "calcwebapp:${BUILD_NUMBER}"
        ECR_REPO = "964742912902.dkr.ecr.eu-west-2.amazonaws.com/calculatorapp"
        AWS_REGION = "eu-west-2"
        CLUSTER_NAME = "my-cluster"
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'master',
                url: 'https://github.com/Ashitoshchavan7/calcwebapp.git'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${IMAGE_NAME} .'
            }
        }

        stage('ECR Login') {
            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'my-aws-cred'
                ]]) {

                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin \
                    964742912902.dkr.ecr.eu-west-2.amazonaws.com
                    '''
                }
            }
        }

        stage('Tag Image') {
            steps {
                sh 'docker tag ${IMAGE_NAME} ${ECR_REPO}:${BUILD_NUMBER}'
            }
        }

        stage('Push Image') {
            steps {
                sh 'docker push ${ECR_REPO}:${BUILD_NUMBER}'
            }
        }

        stage('Deploy to EKS') {
            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'my-aws-cred'
                ]]) {

                    sh '''
                    aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

                    kubectl apply -f k8s-deployment.yaml

                    kubectl rollout status deployment/calculator-app
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {

                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'my-aws-cred'
                ]]) {

                    sh '''
                    aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

                    kubectl get nodes

                    kubectl get pods

                    kubectl get svc
                    '''
                }
            }
        }
    }

    post {

        success {
            echo 'Pipeline Success'
        }

        failure {
            echo 'Pipeline Failed'
        }
    }
}
