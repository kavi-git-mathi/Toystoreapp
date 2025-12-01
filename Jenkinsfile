pipeline {
    agent any
    
    environment {
        APP_NAME = 'toystoreapp'
        ACR_REGISTRY = 'kavitharc.azurecr.io'
        SONAR_PROJECT_KEY = 'toystoreapp'
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
                sh '''
                    dotnet test --configuration Release
                '''
            }
        }
        
        stage('SonarQube Scan') {
            steps {
                echo "📊 Stage 4: Running SonarQube scan..."
                withSonarQubeEnv('sonarqube') {
                    sh '''
                        dotnet sonarscanner begin /k:"${SONAR_PROJECT_KEY}"
                        dotnet build --configuration Release
                        dotnet sonarscanner end
                        echo "✅ Stage 4: SonarQube scan completed"
                    '''
                }
            }
        }
    }
}