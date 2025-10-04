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
                    withCredentials([kubeconfigFile(credentialsId: 'kubeconfig-staging', variable: 'KUBECONFIG')]) {
                        sh '''
                            echo "Deploying to staging environment"
                            chmod +x scripts/deploy-staging.sh
                            export REGISTRY=${REGISTRY}
                            export IMAGE_NAME=${DOCKER_IMAGE}
                            ./scripts/deploy-staging.sh ${DOCKER_TAG}
                        '''
                    }
                }
            }
            post {
                success {
                    slackSend channel: '#deployments', 
                             color: 'good', 
                             message: "✅ Staging deployment successful! Image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
                failure {
                    slackSend channel: '#deployments', 
                             color: 'danger', 
                             message: "❌ Staging deployment failed! Build: ${env.BUILD_URL}"
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy',
                      submitterParameter: 'DEPLOYER'
                script {
                    withCredentials([kubeconfigFile(credentialsId: 'kubeconfig-production', variable: 'KUBECONFIG')]) {
                        sh '''
                            echo "Deploying to production environment"
                            echo "Deployer: ${DEPLOYER}"
                            chmod +x scripts/deploy-production.sh
                            export REGISTRY=${REGISTRY}
                            export IMAGE_NAME=${DOCKER_IMAGE}
                            ./scripts/deploy-production.sh ${DOCKER_TAG}
                        '''
                    }
                }
            }
            post {
                success {
                    slackSend channel: '#deployments', 
                             color: 'good', 
                             message: "🚀 Production deployment successful! Image: ${DOCKER_IMAGE}:${DOCKER_TAG} by ${env.DEPLOYER}"
                    emailext subject: "Production Deployment Successful",
                             body: "Successfully deployed ${DOCKER_IMAGE}:${DOCKER_TAG} to production by ${env.DEPLOYER}",
                             to: "team@company.com"
                }
                failure {
                    slackSend channel: '#deployments', 
                             color: 'danger', 
                             message: "💥 Production deployment failed! Build: ${env.BUILD_URL}"
                    emailext subject: "Production Deployment Failed",
                             body: "Production deployment failed. Check console output at ${env.BUILD_URL}",
                             to: "team@company.com"
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
