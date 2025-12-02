pipeline {
    agent any
    
    stages {
        // STAGE 1: Git Checkout
        stage('Git Checkout') {
            steps {
                echo "📥 Stage 1: Checking out code..."
                checkout scm
                echo "✅ Stage 1: Git checkout completed"
            }
        }
    }
}