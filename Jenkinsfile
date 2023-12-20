pipeline {
    agent any
    environment{
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_JENKINS_KEY')
        AWS_DEFAULT_REGION = 'us-west-2'

    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/Yaswanth5951/Dec1623.git'
            }
        }
        stage('Build docker image') {
            steps {
                sh "docker image build -t yaswanth59/dockerworkshop:$BUILD_ID ."
            }
        }
        stage('Trivy Scan') {
            steps {
                script {
                    sh "trivy image --format json -o trivy-report.json yaswanth59/dockerworkshop:$BUILD_ID"
                }
                publishHTML([reportName: 'Trivy Vulnerability Report', reportDir: '.', reportFiles: 'trivy-report.json', keepAll: true, alwaysLinkToLastBuild: true, allowMissing: false])
            }
        }
        stage('publish docker image') {
            steps {
                withCredentials([string(credentialsId: 'JENKINS', variable: 'Docker')]) {

                sh "docker login -u yaswanth59 -p ${Docker}"
                sh "docker image push yaswanth59/dockerworkshop:$BUILD_ID"
                }
            }
        }
        stage('intializing terraform'){
            steps{
                script{
                    dir('AWS-EKS-CLUSTER'){
                        sh 'terraform init'
                    }
                }
            }
        }
        stage("alignment the terraform code"){
            steps{
                script{
                    dir('AWS-EKS-CLUSTER'){
                        sh "terraform fmt"
                    }
                }
            }
        }
        stage("validating terraform code"){
            steps{
                script{
                    dir('AWS-EKS-CLUSTER'){
                        sh "terraform validate"
                    }
                }
            }
        }
        stage('previewing terraform infra'){
            steps{
                script{
                    dir('AWS-EKS-CLUSTER'){
                        sh ' terraform plan -var-file=values.tfvars'
                    }
                    input(message: "are you sure to proceed?", ok: "proceed")
                }
            }
        }
        stage('creating/destroying EKS cluster'){
            steps{
                script{
                    dir('AWS-EKS-CLUSTER'){
                        sh 'terraform $action -var-file=./values.tfvars --auto-approve'
                    }
                }
            }
        }
        stage('deploying application'){
            steps{
                script{
                    dir('AWS-EKS-CLUSTER/manifestFiles'){
                        sh 'aws eks update-kubeconfig --name my-eks-cluster'
                        sh 'kubectl apply -f deployment.yaml'
                        sh 'kubectl apply -f service.yaml'
                    }
                }
            }
        }
    }
}


