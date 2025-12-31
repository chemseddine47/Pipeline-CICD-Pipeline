pipeline {
    agent any 

    environment {
        SONAR_HOST_URL = 'http://sonarqube:9000' 
    }

    stages {
        stage('Build App') {
            agent {
                docker {

                    image 'node:22-alpine'
                    reuseNode true
                }
            }
            steps {
                sh 'npm ci'
                sh 'npm run build'
            }
        }

        stage('E2E Tests') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                    args '--ipc=host --env CI=true' 
                }
            }
            steps {
                sh 'npm ci'
                sh 'npx playwright test' 
            }
        }

        stage('SonarQube Analysis') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                    // IMPORTANT: Check your network name with "docker network ls" after starting!
                    args '--network=pipeline-cicd-pipeline_cicd-net'
                }
            }
            steps {
                withSonarQubeEnv('MySonarServer') { 
                    sh 'sonar-scanner -Dsonar.projectKey=react-cicd-demo -Dsonar.sources=src'
                }
            } 
        }
    }
}