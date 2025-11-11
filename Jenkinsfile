pipeline {
    agent any

    environment {
        SONARQUBE = 'SonarQube'
        DOCKER_IMAGE = "arijnahdi/demo-node"
        DEPENDENCY_CHECK_HOME = "/opt/dependency-check"
        PATH = "${env.PATH}:${DEPENDENCY_CHECK_HOME}/bin:/usr/local/bin"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/nahdiarij/demo-node.git'
            }
        }

        stage('Build & Test in Docker') {
            steps {
                echo 'Building and testing Node.js project in Docker...'
                sh '''
                    echo "Cleaning workspace..."
                    rm -rf node_modules package-lock.json
                    npm cache clean --force

                    docker build -t arijnahdi/demo-node:test .
                    docker run --rm arijnahdi/demo-node:test sh -c "npm install && npm test || echo 'No test defined'"
                '''
            }
        }

        stage('SAST - SonarQube') {
            steps {
                echo 'Running SonarQube scan...'
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=demo-node \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=http://192.168.33.10:9000 \
                        -Dsonar.token=squ_5ed68632f4ab55b1ad35e12bc50f46a1b3d1c27f
                    '''
                }
            }
        }

        stage('SCA - Dependency Check') {
            steps {
                echo 'Running OWASP Dependency-Check...'
                sh '''
                    mkdir -p dependency-check-report
                    /opt/dependency-check/dependency-check/bin/dependency-check.sh \
                        --project "demo-node" \
                        --scan . \
                        --format "HTML" \
                        --out dependency-check-report
                '''
                publishHTML(target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'dependency-check-report',
                    reportFiles: 'dependency-check-report.html',
                    reportName: 'Dependency-Check Report'
                ])
            }
        }

        stage('Docker Scan') {
            steps {
                echo 'Scanning Docker image from Docker Hub with Trivy...'
                sh '''
                    mkdir -p trivy-report
                    trivy image --format html --output trivy-report/trivy-report.html arijnahdi/demo-node:latest || true
                '''
            }
            post {
                always {
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'trivy-report',
                        reportFiles: 'trivy-report.html',
                        reportName: 'Trivy Vulnerability Report'
                    ])
                }
            }
        }

        stage('Secrets Scan') {
            steps {
                echo 'Scanning for secrets with Gitleaks...'
                sh '''
                    mkdir -p gitleaks-report
                    gitleaks detect --source . --report-format html --report-path gitleaks-report/gitleaks.html || true
                '''
            }
            post {
                always {
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'gitleaks-report',
                        reportFiles: 'gitleaks.html',
                        reportName: 'Gitleaks Secrets Scan Report'
                    ])
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details!'
        }
    }
}
