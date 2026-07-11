// Project 1 - Enterprise CI Pipeline
//
// Flow: Git -> Checkout -> Maven Build -> Unit Test -> SonarQube -> Quality Gate
//       -> Parallel Stage -> Package Jar -> Publish to Nexus -> Docker Build
//       -> Push Docker Image
//
// Wired to this deployment's actual infrastructure (see jenkins/README.md
// for the exact one-time setup this Jenkinsfile assumes):
//   - Jenkins:    http://15.237.252.11:8080
//   - SonarQube:  http://35.180.226.19:9000
//   - Nexus:      http://13.36.239.212:8081
//   - Docker Hub: docker.io/devopstraining064
//
// Prerequisites:
//   - Jenkins tools configured: JDK named "java21", Maven named "maven3.9.16"
//   - Jenkins credentials: "dockerhub-credentials" and "nexus-credentials"
//     (both "Username with password"), scoped to this pipeline
//   - A SonarQube server configured in Jenkins named "sonarqube-server",
//     pointed at http://35.180.226.19:9000, with a webhook back to Jenkins
//     for the quality gate to report asynchronously
//   - docker CLI available on the Jenkins agent, logged-in-capable

pipeline {
    agent any

    tools {
        jdk 'java21'
        maven 'maven3.9.16'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '20'))
        disableConcurrentBuilds()
        timeout(time: 45, unit: 'MINUTES')
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        NEXUS_CREDENTIALS     = credentials('nexus-credentials')
        SONARQUBE_ENV         = 'sonarqube-server'
        IMAGE_NAME            = 'devopstraining064/devopstraining064'
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
                    script {
                        // pom.xml stays on the floating "-SNAPSHOT" dev version in git.
                        // Each build stamps a unique, immutable release version into the
                        // workspace copy only, so the artifact is never overwritten in
                        // Nexus and both Nexus and Docker Hub can always be traced back
                        // to the exact Jenkins build that produced them.
                        def devVersion = sh(
                            script: "mvn -B -ntp -q -DforceStdout help:evaluate -Dexpression=project.version",
                            returnStdout: true
                        ).trim()
                        env.IMAGE_TAG = "${devVersion.replace('-SNAPSHOT', '')}-${env.BUILD_NUMBER}"
                        sh "mvn -B -ntp versions:set -DnewVersion=${env.IMAGE_TAG} -DgenerateBackupPoms=false"
                    }
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

        stage('Publish to Nexus') {
            steps {
                dir('backend') {
                    // -s points at a settings.xml that's safe to commit (see that
                    // file's header) - it only references NEXUS_CREDENTIALS_USR/_PSW,
                    // which Jenkins injected above; no secret ever touches disk in git.
                    sh 'mvn -B -ntp deploy -DskipTests -s ../jenkins/nexus-settings.xml'
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
