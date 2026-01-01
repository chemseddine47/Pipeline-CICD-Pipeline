pipeline {
    agent any 

    environment {
        // Keeps your SonarQube configuration centralized
        SONAR_HOST_URL = 'http://sonarqube:9000' 
    }

    stages {
        // STAGE 1: Build & Install
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
                
                // Save these so we don't have to download them again in the test stage
                stash includes: 'node_modules/', name: 'app_modules'
                stash includes: 'build/', name: 'app_build'
            }
        }

        // REMOVED: stage('Dependency Security Scan') 
        // Reason: GitHub Dependabot is now doing this 24/7 for free.

        // STAGE 2: Functional Testing
        stage('E2E Tests') {
            agent {
                docker {
                    // Using the official Playwright image
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                    args '--ipc=host --env CI=true' 
                }
            }
            steps {
                unstash 'app_modules'
                unstash 'app_build'
                // Starts the server and waits for it to be ready before testing
                sh 'npx serve -s build -l 3000 & npx wait-on http://localhost:3000 && npx playwright test' 
            }
        }

        // STAGE 3: Code Quality (SAST)
        stage('SonarQube Analysis') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                    // Connects to the specific Docker network so it can reach the Sonar server
                    args '--network=pipeline-cicd-pipeline_cicd-net'
                }
            }
            steps {
                withSonarQubeEnv('MySonarServer') { 
                    // Scans the code quality (bugs, code smells)
                    sh 'sonar-scanner' 
                }
            }
        }
    }
}