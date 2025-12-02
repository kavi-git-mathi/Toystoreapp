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
        
        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE} .
                    docker tag ${DOCKER_IMAGE} ${ACR_REGISTRY}/${APP_NAME}:latest
                '''
            }
        }
        
        // STAGE 6: Push to ACR
        stage('Push to ACR') {
            steps {
                echo "🚀 Stage 6: Pushing to ACR..."
                
                withCredentials([usernamePassword(
                    credentialsId: 'acr-credentials',
                    usernameVariable: 'ACR_USER',
                    passwordVariable: 'ACR_PASS'
                )]) {
                    sh '''
                        docker login ${ACR_REGISTRY} -u $ACR_USER -p $ACR_PASS
                        docker push ${DOCKER_IMAGE}
                        docker push ${ACR_REGISTRY}/${APP_NAME}:latest
                        echo "✅ Stage 6: Images pushed to ACR"
                    '''
                }
            }
        }
    }
}