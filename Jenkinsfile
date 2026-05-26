pipeline {
    agent any

    stages {
        stage('Git Checkout') {
            steps {
                git url: 'https://github.com/Ashitoshchavan7/calcwebapp.git'
                echo "Code Checked-out Successfully!!"
            }
        }
    }

    post {
        success {
            echo 'Checkout completed successfully'
        }
        failure {
            echo 'Checkout failed'
        }
    }
}
