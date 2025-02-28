pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "sindhhuja/mini-k8s-demo:latest"
        MINIKUBE_HOME = "/home/jenkins/.minikube"
        KUBECONFIG = "/home/jenkins/.kube/config"
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    retry(3) {
                        checkout([$class: 'GitSCM', 
                            branches: [[name: '*/main']], 
                            userRemoteConfigs: [[url: 'https://github.com/gsindhuja1311/mini-k8s-demo.git']]
                        ])
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE app/'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        sh 'docker push sindhhuja/mini-k8s-demo:latest'
                    }
                }
            }
        }

        stage('Configure Minikube') {
            steps {
                script {
                    sh '''
                        echo "🔹 Setting up Minikube for Jenkins..."

                        # Ensure correct permissions for .kube and .minikube
                        sudo mkdir -p /home/jenkins/.kube /home/jenkins/.minikube
                        sudo chown -R jenkins:jenkins /home/jenkins/.kube /home/jenkins/.minikube
                        sudo chmod -R 755 /home/jenkins/.kube /home/jenkins/.minikube

                        # Ensure KUBECONFIG is writable
                        sudo touch /home/jenkins/.kube/config
                        sudo chown jenkins:jenkins /home/jenkins/.kube/config
                        sudo chmod 600 /home/jenkins/.kube/config

                        # Delete old Minikube instance if present (run as Jenkins user)
                        minikube delete || true

                        # Start Minikube as Jenkins (NO SUDO)
                        export MINIKUBE_HOME=/home/jenkins/.minikube
                        export KUBECONFIG=/home/jenkins/.kube/config
                        
                        minikube start --driver=docker --cpus=2 --memory=4096 --disk-size=10g --wait=all

                        # Ensure kubectl uses the correct Minikube config
                        minikube update-context
                    '''
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh '''
                        echo "🚀 Deploying to Minikube..."
                        export KUBECONFIG=/home/jenkins/.kube/config

                        # Apply Kubernetes manifests
                        kubectl apply -f k8s/namespace.yaml
                        kubectl apply -f k8s/configmap.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml

                        # Wait for deployment rollout
                        kubectl -n mini-demo rollout status deployment/flask-app

                        # Get Minikube service URL
                        minikube service flask-app -n mini-demo --url
                    '''
                }
            }
        }
    }
}