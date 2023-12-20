pipeline {
    agent any
    environment{
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_JENKINS_KEY')
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
        stage('Ensure kubernetes cluster is up') {
            steps {
                sh "cd deployment/terraform && terraform init && terraform apply -auto-approve"
            }
        }
        stage('deploy to k8s') {
            steps {
                sh "kubectl apply -f deployment/k8s/deployment.yaml"
                sh """
                kubectl patch deployment netflix-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"netflix-app","image":"yaswanth59/dockerworkshop:$BUILD_ID"}]}}}}'
                """
            }
        }

        stage('kubescape Scan') {
            steps {
                script {
                    sh "/home/ubuntu/.kubescape/bin/kubescape scan -t 40 deployment/k8s/deployment.yaml --format junit -o TEST-report.xml"
                    junit "**/TEST-*.xml"
                }
                
            }
        }
    }
}
