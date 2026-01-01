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
                stash includes: 'node_modules/', name: 'app_modules'
                stash includes: 'build/', name: 'app_build'
            }
        }

        // DELETED: stage('Dependency Security Scan') 
        // GitHub Dependabot is now handling this!

        stage('E2E Tests') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                    args '--ipc=host --env CI=true' 
                }
            }
            steps {
                unstash 'app_modules'
                unstash 'app_build'
                sh 'npx serve -s build -l 3000 & npx wait-on http://localhost:3000 && npx playwright test' 
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
                    // Back to standard scan (without the XML report argument)
                    sh 'sonar-scanner' 
                }
            }
        }
    }
}