// Project 2 - CD to AWS EKS
//
// Flow: Git -> Jenkins -> Checkout -> Maven Build -> Unit Test -> SonarQube
//       -> Quality Gate -> Parallel Stage -> Package Jar -> Frontend Build
//       -> Docker Build (backend + frontend) -> Push Docker Images
//       -> Deploy to EKS -> Verify
//
// New in this project vs. project-01-ci-pipeline: the pipeline now also
// builds/tests the frontend, builds and pushes a second image, and deploys
// both to a Terraform-provisioned EKS cluster. See jenkins/README.md for
// the additional one-time setup (AWS credentials, kubectl/aws CLI on the
// agent) this project requires on top of project 1's.

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

        // Replace with your own Docker Hub namespace before running against a real registry.
        BACKEND_IMAGE   = 'yourdockerhubuser/enterprise-devops-backend'
        FRONTEND_IMAGE  = 'yourdockerhubuser/enterprise-devops-frontend'
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
                        // Backend and frontend always deploy together as one release
                        // unit (see "Deploy to EKS"), so both images share a single
                        // tag: the backend's pom.xml version plus the Jenkins build
                        // number. Traceable back to the exact build, same idea as
                        // project-01-ci-pipeline's Jenkinsfile.
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

        stage('Frontend Build') {
            steps {
                dir('frontend') {
                    sh 'npm ci'
                    sh 'CI=true npm test'
                    sh 'CI=true npm run build'
                }
            }
        }

        stage('Docker Build') {
            parallel {
                stage('Backend Image') {
                    steps {
                        sh """
                            docker build -f docker/backend-ci.Dockerfile \
                                -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest .
                        """
                    }
                }
                stage('Frontend Image') {
                    steps {
                        sh """
                            docker build -f docker/frontend-ci.Dockerfile \
                                -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:latest .
                        """
                    }
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                sh '''
                    echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                '''
                sh "docker push ${BACKEND_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${BACKEND_IMAGE}:latest"
                sh "docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${FRONTEND_IMAGE}:latest"
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
                    kubectl set image deployment/frontend frontend=${FRONTEND_IMAGE}:${IMAGE_TAG} \
                        -n ${K8S_NAMESPACE}
                """
            }
        }

        stage('Verify') {
            steps {
                sh """
                    kubectl rollout status deployment/backend -n ${K8S_NAMESPACE} --timeout=180s
                    kubectl rollout status deployment/frontend -n ${K8S_NAMESPACE} --timeout=180s
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
            echo "Deployed ${BACKEND_IMAGE}:${IMAGE_TAG} and ${FRONTEND_IMAGE}:${IMAGE_TAG} to ${EKS_CLUSTER_NAME}"
        }
        failure {
            echo 'Pipeline failed - see docs/06-Troubleshooting.md for common causes.'
        }
    }
}
