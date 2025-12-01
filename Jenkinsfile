pipeline {
    agent any
    
    environment {
        APP_NAME = 'toystoreapp'
        ACR_REGISTRY = 'kavitharc.azurecr.io'
    }
    
    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
                echo "✅ Stage 1: Git checkout completed"
            }
        }
        
        stage('.NET Restore & Build') {
            steps {
                sh '''
                    dotnet restore
                    dotnet build --configuration Release
                '''
            }
        }
        
        stage('.NET Tests') {
            steps {
                echo "🧪 Stage 3: Running tests..."
                sh '''
                    dotnet test --configuration Release
                    echo "✅ Stage 3: Tests completed"
                '''
            }
        }
    }
}