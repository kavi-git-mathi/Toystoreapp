pipeline {
    agent any
    
    stages {
        stage('Git Checkout') {
            steps {
                echo "📥 Stage 1: Checking out code..."
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
        
        // STAGE 4: Trivy Security Scan
        stage('Trivy Security Scan') {
            steps {
                echo "🛡️ Stage 4: Running security scan..."
                sh '''
                    # Install Trivy to temp directory (no sudo needed)
                    mkdir -p /tmp/trivy-install
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /tmp/trivy-install
                    
                    # Run security scan
                    /tmp/trivy-install/trivy fs --severity HIGH,CRITICAL --exit-code 0 .
                    
                    echo "✅ Stage 4: Security scan completed"
                '''
            }
        }
    }
}