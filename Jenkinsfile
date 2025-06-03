pipeline {
    agent any

    tools {
        jdk 'Java17'
        maven 'Maven3'
    }

    environment {
        AWS_REGION = 'ca-central-1'
        ECR_REPO_NAME = 'springboot-ecr'
        IMAGE_TAG = 'v1'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/snehabopche/spring-boot-k8s.git'
            }
        }

        stage('Build App') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Prepare JAR') {
            steps {
                sh 'cp target/spring-boot-2-hello-world-1.0.2-SNAPSHOT.jar app.jar'
            }
        }

        stage('Set Image Variables') {
            steps {
                script {
                    env.ECR_REGISTRY = "897722705551.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                    env.FULL_IMAGE_NAME = "${env.ECR_REGISTRY}/${env.ECR_REPO_NAME}:${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: '91e3d8da-d01c-4ffb-b7ab-55848d8f90b3'
                ]]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION |
                        docker login --username AWS --password-stdin 897722705551.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}
                    docker push ${FULL_IMAGE_NAME}
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: '91e3d8da-d01c-4ffb-b7ab-55848d8f90b3'
                ]]) {
                    sh '''
                        aws eks update-kubeconfig --region $AWS_REGION --name springboot-cluster
                        kubectl apply -f k8s/springboot-deployment.yaml
                        kubectl apply -f k8s/springboot-service.yaml
                    '''
                }
            }
        }
    }
}

