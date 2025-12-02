pipeline {
    agent any
    
    environment {
        APP_NAME = 'toystoreapp'
        ACR_REGISTRY = 'kavitharc.azurecr.io'
        DOCKER_IMAGE = "${ACR_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}"
    }
    
    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
                echo "✅ Stage 1: Git checkout completed"
            }
        }
        
        stage('.NET Build') {
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
        
        stage('Trivy Security Scan') {
            steps {
                sh '''
                    mkdir -p /tmp/trivy-install
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /tmp/trivy-install
                    /tmp/trivy-install/trivy fs --severity HIGH,CRITICAL --exit-code 0 .
                '''
            }
        }
        
        // STAGE 5: Docker Build
        stage('Docker Build') {
            steps {
                echo "🐳 Stage 5: Building Docker image..."
                sh '''
                    docker build -t ${DOCKER_IMAGE} .
                    docker tag ${DOCKER_IMAGE} ${ACR_REGISTRY}/${APP_NAME}:latest
                    echo "✅ Stage 5: Docker image built"
                '''
            }
        }
    }
}