pipeline {
    agent any

    environment {
        AWS_REGION = 'ca-central-1'
        ECR_REPO_NAME = 'springboot-ecr'
        IMAGE_TAG = 'v1'
        ECR_REGISTRY = '897722705551.dkr.ecr.${AWS_REGION}.amazonaws.com'
        FULL_IMAGE_NAME = "${ECR_REGISTRY}/${ECR_REPO_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/snehabopche/spring-boot-k8s.git'
            }
        }

        stage('Build App') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_REGION |
                    docker login --username AWS --password-stdin $ECR_REGISTRY
                '''
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
                sh '''
                    aws eks update-kubeconfig --region $AWS_REGION --name springboot-cluster
                    kubectl apply -f k8s/springboot-deployment.yaml
                    kubectl apply -f k8s/springboot-service.yaml
                '''
            }
        }
    }
}

