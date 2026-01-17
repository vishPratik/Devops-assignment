pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-credentials').username
        AWS_SECRET_ACCESS_KEY = credentials('aws-credentials').password
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    options {
        timestamps()
        ansiColor('xterm')
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📦 Checking out source code...'
                checkout scm
                sh 'ls -la'
            }
        }

        stage('Install Tools') {
            steps {
                script {
                    sh '''
                        set -e

                        echo "🔧 Installing prerequisites..."
                        apt-get update -y
                        apt-get install -y unzip curl gnupg

                        if ! command -v terraform >/dev/null 2>&1; then
                          echo "⬇️ Installing Terraform..."
                          curl -L -o /tmp/terraform.zip \
                            https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
                          unzip -o /tmp/terraform.zip -d /usr/local/bin
                          chmod +x /usr/local/bin/terraform
                        else
                          echo "✔ Terraform already installed"
                        fi

                        if ! command -v trivy >/dev/null 2>&1; then
                          echo "⬇️ Installing Trivy..."
                          curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
                            | sh -s -- -b /usr/local/bin v0.49.1
                        else
                          echo "✔ Trivy already installed"
                        fi

                        echo "🔍 Verifying tool versions..."
                        terraform -version
                        trivy --version
                    '''
                }
            }
        }

        stage('Security Scan - Terraform') {
            steps {
                echo '🔍 Running Terraform security scan...'
                dir('terraform') {
                    script {
                        // This should FAIL if vulnerabilities are found
                        sh '''
                            trivy config --severity HIGH,CRITICAL --exit-code 1 .
                        '''
                    }
                }
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            export AWS_DEFAULT_REGION=us-east-1
                            export AWS_EC2_METADATA_DISABLED=true

                            terraform init
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }


        stage('Manual Approval') {
             when {
                expression { env.SKIP_DEPLOYMENT != 'true' }
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    input(
                        message: 'Do you want to apply Terraform?',
                        ok: 'Apply Infrastructure'
                    )
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            set -e
                            terraform apply -auto-approve tfplan
                            export AWS_EC2_METADATA_DISABLED=true

                        '''
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                dir('terraform') {
                    script {
                        sh 'terraform output -raw public_ip > ip.txt'
                        def publicIp = readFile('ip.txt').trim()

                        echo "🌐 Application URL: http://${publicIp}:5000"

                        sh """
                            for i in {1..30}; do
                              if curl -sf http://${publicIp}:5000/health; then
                                echo "✅ Application is healthy"
                                exit 0
                              fi
                              sleep 5
                            done
                            echo "❌ Application did not become healthy"
                            exit 1
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning workspace'
            cleanWs()
        }
        success {
            echo '🎉 Pipeline completed successfully'
        }
        unstable {
            echo '⚠️ Pipeline completed with security warnings'
        }
        failure {
            echo '❌ Pipeline failed'
        }
    }
}
