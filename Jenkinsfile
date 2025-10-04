pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'hello-world-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        REGISTRY = 'your-registry.com'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    def testContainer = docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").run('-p 8080:80')
                    try {
                        sleep 10
                        sh 'curl -f http://localhost:8080'
                    } finally {
                        testContainer.stop()
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Push to Registry') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY}", 'docker-registry-credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    // Add your staging deployment logic
                    sh '''
                        echo "Deploying to staging environment"
                        # kubectl set image deployment/hello-world hello-world=${REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    '''
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                script {
                    // Add your production deployment logic
                    sh '''
                        echo "Deploying to production environment"
                        # kubectl set image deployment/hello-world hello-world=${REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    '''
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            emailext (
                subject: "Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "Build failed. Check console output at ${env.BUILD_URL}",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
