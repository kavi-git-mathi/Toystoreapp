pipeline {
    agent any
    
    environment {
        APP_NAME = 'toystoreapp'
        ACR_REGISTRY = 'kavitharc.azurecr.io'
        DOCKER_IMAGE = "${ACR_REGISTRY}/${APP_NAME}:${BUILD_NUMBER}"
    }
    
    options {
        // Automatically clean workspace before build
        cleanWs(before: true, deleteDirs: true)
        
        // Only keep last 5 builds to save space
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
        
        // Timeout after 30 minutes
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        // STAGE 1: Git Checkout
        stage('Git Checkout') {
            steps {
                echo "✅ Stage 1: Checking out code..."
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [
                        // Clean workspace before checkout
                        [$class: 'CleanBeforeCheckout'],
                        // Shallow clone to save space
                        [$class: 'CloneOption', depth: 1, shallow: true],
                        // Prune stale branches
                        [$class: 'PruneStaleBranch']
                    ],
                    userRemoteConfigs: [[
                        url: 'https://github.com/kavi-git-mathi/Toystoreapp.git'
                    ]]
                ])
                
                sh '''
                    echo "Workspace size after checkout:"
                    du -sh . || true
                '''
            }
        }
        
        // STAGE 2: .NET Build
        stage('.NET Build') {
            steps {
                echo "🔨 Stage 2: Building application..."
                sh '''
                    # Clean obj/bin directories first
                    rm -rf bin/ obj/ || true
                    
                    dotnet restore --verbosity minimal
                    dotnet build --configuration Release --no-restore --verbosity minimal
                    
                    echo "Build output size:"
                    du -sh bin/ || true
                '''
            }
        }
        
        // STAGE 3: .NET Tests
        stage('.NET Tests') {
            steps {
                echo "🧪 Stage 3: Running tests..."
                sh '''
                    dotnet test --configuration Release --no-build --verbosity minimal --logger "console;verbosity=minimal"
                '''
            }
        }
        
        // STAGE 4: Trivy Security Scan
        stage('Security Scan') {
            steps {
                echo "🛡️ Stage 4: Security scanning..."
                script {
                    // Check disk space before scan
                    sh '''
                        echo "=== Disk Space Before Scan ==="
                        df -h .
                        echo "=== Workspace Size ==="
                        du -sh . || true
                    '''
                    
                    // Install Trivy to temp directory
                    sh '''
                        TRIVY_DIR="${WORKSPACE}/.temp/trivy"
                        mkdir -p ${TRIVY_DIR}
                        
                        echo "Installing Trivy..."
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ${TRIVY_DIR}
                        
                        echo "Running security scan..."
                        ${TRIVY_DIR}/trivy fs --severity HIGH,CRITICAL --exit-code 0 --quiet .
                    '''
                }
            }
            
            post {
                always {
                    // Clean Trivy temp files
                    sh '''
                        echo "Cleaning Trivy temp files..."
                        rm -rf ${WORKSPACE}/.temp || true
                    '''
                }
            }
        }
        
        // STAGE 5: Docker Build
        stage('Docker Build') {
            steps {
                echo "🐳 Stage 5: Building Docker image..."
                script {
                    // Clean Docker cache before build
                    sh '''
                        echo "=== Docker Disk Usage Before ==="
                        docker system df || true
                        
                        echo "Cleaning unused Docker images..."
                        docker image prune -f || true
                    '''
                    
                    // Build Docker image
                    sh '''
                        docker build \
                          --tag ${DOCKER_IMAGE} \
                          --tag ${ACR_REGISTRY}/${APP_NAME}:latest \
                          --label "build=${BUILD_NUMBER}" \
                          --label "commit=${GIT_COMMIT}" \
                          .
                        
                        echo "Docker images created:"
                        docker images --filter "reference=*${APP_NAME}*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
                    '''
                }
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
                        # Login to ACR
                        docker login ${ACR_REGISTRY} -u $ACR_USER -p $ACR_PASS
                        
                        # Push images
                        docker push ${DOCKER_IMAGE}
                        docker push ${ACR_REGISTRY}/${APP_NAME}:latest
                        
                        echo "✅ Images pushed:"
                        echo "- ${DOCKER_IMAGE}"
                        echo "- ${ACR_REGISTRY}/${APP_NAME}:latest"
                    '''
                }
            }
            
            post {
                success {
                    // Remove pushed images to save space
                    sh '''
                        echo "Cleaning up Docker images after push..."
                        docker rmi ${DOCKER_IMAGE} ${ACR_REGISTRY}/${APP_NAME}:latest || true
                        docker image prune -f
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo "📦 Final cleanup..."
            
            script {
                // Comprehensive cleanup
                sh '''
                    echo "=== Cleaning Workspace ==="
                    # Remove build artifacts
                    rm -rf bin/ obj/ TestResults/ .temp/ || true
                    
                    # Remove Docker build cache
                    docker builder prune -f || true
                    
                    # Clean Docker images
                    docker image prune -f || true
                    
                    echo "=== Final Disk Usage ==="
                    df -h .
                    echo "Workspace size:"
                    du -sh . || true
                    echo "Docker disk usage:"
                    docker system df || true
                '''
                
                // Send disk usage notification
                sh '''
                    echo "Build #${BUILD_NUMBER} completed with cleanup"
                    echo "Workspace: $(du -sh . | cut -f1)"
                    echo "Docker: $(docker system df --format "{{.TotalSpace}} used: {{.Active}}")"
                '''
            }
        }
        
        success {
            echo "✅ Pipeline completed successfully with cleanup!"
        }
        
        failure {
            echo "❌ Pipeline failed - cleanup still performed"
        }
    }
}