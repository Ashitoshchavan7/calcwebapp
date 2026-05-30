pipeline {

    agent {
        label 'lb'
    }

    environment {
        IMAGE_NAME = "calcwebapp:${BUILD_NUMBER}"
        ECR_REPO = "964742912902.dkr.ecr.eu-west-2.amazonaws.com/calculatorapp"
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
            aws ecr get-login-password --region eu-west-2 | \
            docker login --username AWS --password-stdin 964742912902.dkr.ecr.eu-west-2.amazonaws.com
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
        sh '''
        docker push 964742912902.dkr.ecr.eu-west-2.amazonaws.com/calculatorapp:25
        '''
    }
} 
    
stage('Deploy to EKS') {
    steps {
        withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: 'aws-cred'
        ]])
           ecrLogin()
        {

            sh '''
            aws eks update-kubeconfig --region eu-west-2 --name my-cluster

            kubectl apply -f k8s-deployment.yaml
            
            '''
        }
    }
}

        stage('Verify Deployment') {
            steps {
                sh 'kubectl get pods'
                sh 'kubectl get svc'
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
