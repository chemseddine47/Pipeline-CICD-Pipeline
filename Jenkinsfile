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
                
                // OPTIMIZATION 1: Save these folders to pass to the next stage
                // This prevents re-downloading 1500+ packages
                stash includes: 'node_modules/', name: 'app_modules'
                stash includes: 'build/', name: 'app_build'
            }
        }

        stage('E2E Tests') {
            agent {
                docker {
                    // Keeping the version that matches your package.json
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                    args '--ipc=host --env CI=true' 
                }
            }
            steps {
                // OPTIMIZATION 1: Restore the folders we saved
                unstash 'app_modules'
                unstash 'app_build'

                // OPTIMIZATION 2: Smart waiting
                // We use 'npx wait-on' to poll localhost:3000 until it replies
                // This replaces the flaky 'sleep 10'
                sh 'npx serve -s build -l 3000 & npx wait-on http://localhost:3000 && npx playwright test' 
            }
        }

        stage('SonarQube Analysis') {
            agent {
                docker {
                    image 'sonarsource/sonar-scanner-cli:latest'
                    // Your network name (verified from previous steps)
                    args '--network=pipeline-cicd-pipeline_cicd-net'
                }
            }
            steps {
                withSonarQubeEnv('MySonarServer') { 
                    // detailed config will move to a separate file in the next step
                    sh 'sonar-scanner'
                }
            }
        }
    }
}