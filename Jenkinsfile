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
                sh 'npm install -g serve'
                sh 'npx serve -s build -l 3000 & sleep 10 && npx playwright test' 
            }
        }

        stage('SonarQube Analysis') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
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