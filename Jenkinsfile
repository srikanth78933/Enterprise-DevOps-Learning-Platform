// Project 2 - CD to AWS EKS
//
// Flow: Git -> Jenkins -> Checkout -> Maven Build -> Unit Test -> SonarQube
//       -> Quality Gate -> Parallel Stage -> Package Jar -> Docker Build
//       -> Push Docker Image -> Deploy to EKS -> Verify
//
// New in this project vs. project-01-ci-pipeline: the pipeline now deploys
// the backend to an existing EKS cluster (provisioned and managed outside
// this repo). See jenkins/README.md for the additional one-time setup (AWS
// credentials, kubectl/aws CLI on the agent) this project requires on top
// of project 1's. (This branch is backend-only, frontend/ was removed
// entirely - see architecture/README.md for why.)
//
// Wired to this deployment's actual infrastructure:
//   - Docker Hub:   docker.io/devopstraining064
//   - EKS cluster:  eks-cluster (eu-west-3)

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
        timeout(time: 60, unit: 'MINUTES')
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')

        SONARQUBE_ENV   = 'sonarqube-server'
        AWS_REGION      = 'eu-west-3'
        EKS_CLUSTER_NAME = 'eks-cluster'
        K8S_NAMESPACE   = 'enterprise-devops'

        BACKEND_IMAGE   = 'devopstraining064/enterprise-devops-backend'
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
                        // IMAGE_TAG is the backend's pom.xml version plus the Jenkins
                        // build number, e.g. 1.0.0-42 - same technique as
                        // project-01-ci-pipeline's Jenkinsfile, so the Docker tag is
                        // always traceable back to the exact build that produced it.
                        def devVersion = sh(
                            script: "mvn -B -ntp -q -DforceStdout help:evaluate -Dexpression=project.version",
                            returnStdout: true
                        ).trim()
                        env.IMAGE_TAG = "${devVersion.replace('-SNAPSHOT', '')}-${env.BUILD_NUMBER}"
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
                    docker build -f docker/backend-ci.Dockerfile \
                        -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                '''
                sh "docker push ${BACKEND_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${BACKEND_IMAGE}:latest"
                sh 'docker logout'
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                    aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}

                    kubectl apply -k kubernetes/

                    kubectl set image deployment/backend backend=${BACKEND_IMAGE}:${IMAGE_TAG} \
                        -n ${K8S_NAMESPACE}
                """
            }
        }

        stage('Verify') {
            steps {
                sh """
                    kubectl rollout status deployment/backend -n ${K8S_NAMESPACE} --timeout=180s
                """
                script {
                    sh './scripts/verify-deployment.sh'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Deployed ${BACKEND_IMAGE}:${IMAGE_TAG} to ${EKS_CLUSTER_NAME}"
        }
        failure {
            echo 'Pipeline failed - see docs/06-Troubleshooting.md for common causes.'
        }
    }
}
