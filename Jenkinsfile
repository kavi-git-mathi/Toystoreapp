pipeline {
    agent any
    
    environment {
        APP_NAME = 'toystoreapp'
        ACR_REGISTRY = 'kavitharc.azurecr.io'
        DOCKER_IMAGE = "${ACR_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}"
        SONAR_PROJECT_KEY = 'toystoreapp'
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
                    dotnet test --configuration Release --logger "trx;LogFileName=test-results.trx" --results-directory ./TestResults
                '''
            }
        }
        
 stage('SonarQube Analysis') {
    steps {
        echo "📊 Stage 4: Running SonarQube analysis..."
        
        script {
            // Install SonarScanner for .NET and add to PATH
            sh '''
                echo "Installing SonarScanner for .NET..."
                export PATH="$PATH:$HOME/.dotnet/tools"
                dotnet tool install --global dotnet-sonarscanner --version 5.13.0 || true
            '''
            
            // Using SonarQube token from Jenkins (Secret text)
            withCredentials([string(
                credentialsId: 'Sonarqube-token',
                variable: 'SONAR_TOKEN'
            )]) {
                // Run SonarQube analysis
                withSonarQubeEnv('sonarqube-local') {
                    sh '''
                        echo "Starting SonarQube scan..."
                        # Add dotnet tools to PATH
                        export PATH="$PATH:$HOME/.dotnet/tools"
                        
                        dotnet sonarscanner begin \
                          /k:"${SONAR_PROJECT_KEY}" \
                          /d:sonar.host.url="${SONAR_HOST_URL}" \
                          /d:sonar.login="${SONAR_TOKEN}" \
                          /d:sonar.cs.vstest.reportsPaths="**/TestResults/*.trx"
                        
                        dotnet build --configuration Release
                        
                        dotnet sonarscanner end /d:sonar.login="${SONAR_TOKEN}"
                        
                        echo "✅ SonarQube scan submitted"
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo "Waiting for SonarQube Quality Gate..."
            script {
                // Wait for quality gate result
                timeout(time: 5, unit: 'MINUTES') {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                        error "❌ SonarQube Quality Gate failed: ${qg.status}"
                    }
                    echo "✅ SonarQube Quality Gate passed: ${qg.status}"
                }
            }
        }
    }
}

        
        stage('Trivy Security Scan') {
            steps {
                echo "🛡️ Stage 5: Running security scan..."
                sh '''
                    mkdir -p /tmp/trivy-install
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /tmp/trivy-install
                    /tmp/trivy-install/trivy fs --severity HIGH,CRITICAL --exit-code 0 .
                    echo "✅ Security scan completed"
                '''
            }
        }
        
        stage('Docker Build') {
            steps {
                echo "🐳 Stage 6: Building Docker image..."
                sh '''
                    docker build -t ${DOCKER_IMAGE} .
                    docker tag ${DOCKER_IMAGE} ${ACR_REGISTRY}/${APP_NAME}:latest
                    echo "✅ Docker image built"
                '''
            }
        }
        
        stage('Push to ACR') {
            steps {
                echo "🚀 Stage 7: Pushing to ACR..."
                
                withCredentials([usernamePassword(
                    credentialsId: 'acr-credentials',
                    usernameVariable: 'ACR_USER',
                    passwordVariable: 'ACR_PASS'
                )]) {
                    sh '''
                        docker login ${ACR_REGISTRY} -u $ACR_USER -p $ACR_PASS
                        docker push ${DOCKER_IMAGE}
                        docker push ${ACR_REGISTRY}/${APP_NAME}:latest
                        echo "✅ Images pushed to ACR"
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo "🎉 All 7 stages completed successfully!"
            echo "SonarQube Dashboard: http://localhost:9000/dashboard?id=${SONAR_PROJECT_KEY}"
            echo "ACR Images:"
            echo "  - ${DOCKER_IMAGE}"
            echo "  - ${ACR_REGISTRY}/${APP_NAME}:latest"
        }
    }
}