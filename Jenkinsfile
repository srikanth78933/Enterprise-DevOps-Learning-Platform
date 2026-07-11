// Project 1 - Enterprise CI Pipeline
//
// Flow: Git -> Checkout -> Maven Build -> Unit Test -> SonarQube -> Quality Gate
//       -> Parallel Stage -> Package Jar -> Docker Build -> Push Docker Image
//
// Prerequisites (see jenkins/README.md for full setup):
//   - Jenkins tools configured: JDK named "jdk21", Maven named "maven3"
//   - Jenkins credentials: "dockerhub-credentials" (username/password), scoped to this pipeline
//   - A SonarQube server configured in Jenkins named "sonarqube-server", with the
//     SonarQube Scanner for Jenkins plugin installed and a webhook back to Jenkins
//     for the quality gate to report asynchronously (Manage Jenkins > System > SonarQube servers)
//   - docker CLI available on the Jenkins agent, logged-in-capable (docker.sock mounted
//     if the agent itself runs in a container)

pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven3'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timeout(time: 45, unit: 'MINUTES')
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        SONARQUBE_ENV         = 'sonarqube-server'
        // Replace with your own Docker Hub namespace before running against a real registry.
        IMAGE_NAME            = 'yourdockerhubuser/enterprise-devops-backend'
        IMAGE_TAG             = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                dir('backend') {
                    sh 'mvn -B -ntp clean compile'
                }
            }
        }

        stage('Unit Test') {
            steps {
                dir('backend') {
                    sh 'mvn -B -ntp test'
                }
            }
            post {
                always {
                    junit testResults: 'backend/target/surefire-reports/*.xml', allowEmptyResults: false
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('backend') {
                    withSonarQubeEnv("${SONARQUBE_ENV}") {
                        sh 'mvn -B -ntp sonar:sonar'
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                // Waits for the webhook callback from SonarQube. Aborts the build
                // if coverage, duplication, or new-code issue thresholds are breached.
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Parallel Stage') {
            parallel {
                stage('Publish Coverage Report') {
                    steps {
                        dir('backend') {
                            recordCoverage tools: [[parser: 'JACOCO', pattern: 'target/site/jacoco/jacoco.xml']]
                        }
                    }
                }
                stage('Dependency Tree Audit') {
                    steps {
                        dir('backend') {
                            sh 'mvn -B -ntp dependency:tree -DoutputFile=target/dependency-tree.txt'
                        }
                    }
                }
            }
        }

        stage('Package Jar') {
            steps {
                dir('backend') {
                    sh 'mvn -B -ntp package -DskipTests'
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'backend/target/enterprise-devops-backend.jar', fingerprint: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                    docker build \
                        -f docker/backend-ci.Dockerfile \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest \
                        .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                '''
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker push ${IMAGE_NAME}:latest"
                sh 'docker logout'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline succeeded. Image published: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo 'Pipeline failed - see docs/06-Troubleshooting.md for common causes.'
        }
    }
}
