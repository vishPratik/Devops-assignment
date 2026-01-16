// Jenkinsfile
pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📦 Checking out source code...'
                git branch: 'main', 
                    url: 'https://github.com/vishPratik/Devops-assignment.git' 
                sh 'ls -la'
            }
        }
        
        stage('Install Tools') {
            steps {
                script {
                    sh '''
                        echo "Updating and installing prerequisites..."
                        apt-get update && apt-get install -y unzip curl gnupg
                        
                        echo "Installing Terraform..."
                        curl -L -o terraform.zip https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
                        unzip -o terraform.zip
                        mv terraform /usr/local/bin/
                        
                        echo "Installing Trivy..."
                        curl -sfL --connect-timeout 30 --retry 5 https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.49.1
                        
                        echo "Verifying Installations..."
                        terraform -version
                        trivy --version
                    '''
                }
            }
        }
        
        stage('Security Scan - Terraform') {
            steps {
                echo '🔍 Scanning Terraform for security vulnerabilities...'
                dir('terraform') {
                    script {
                        try {
                            // Scan with Trivy
                            sh 'trivy config --severity HIGH,CRITICAL .'
                            echo '✅ Security scan passed!'
                        } catch (Exception e) {
                            echo '❌ Security scan failed with vulnerabilities!'
                            echo '📋 Vulnerability report saved for AI analysis'
                            
                            // Save detailed report
                            sh 'trivy config --format json --output trivy-report.json .'
                            sh 'cat trivy-report.json'
                            
                            // Continue anyway for demo, but mark as unstable
                            currentBuild.result = 'UNSTABLE'
                        }
                    }
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                echo '📋 Running Terraform Plan...'
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials', // You'll create this in Jenkins
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            terraform init
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }
        
        stage('Manual Approval') {
            steps {
                echo '⏳ Waiting for manual approval...'
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        input(
                            message: 'Do you want to apply Terraform?',
                            ok: 'Apply Infrastructure'
                        )
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                echo '🚀 Applying Terraform...'
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh 'terraform apply -auto-approve tfplan'
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '✅ Verifying deployment...'
                script {
                    // Get public IP from Terraform output
                    dir('terraform') {
                        sh 'terraform output public_ip > ip.txt'
                        def public_ip = readFile('ip.txt').trim()
                        
                        echo "🌐 Web app should be available at: http://${public_ip}:5000"
                        
                        // Wait for app to be ready
                        sh """
                            for i in {1..30}; do
                                if curl -s -f http://${public_ip}:5000/health; then
                                    echo "✅ Application is healthy!"
                                    exit 0
                                fi
                                sleep 5
                            done
                            echo "❌ Application not responding"
                            exit 1
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo '🎉 Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
        unstable {
            echo '⚠️ Pipeline completed with vulnerabilities!'
        }
    }
}