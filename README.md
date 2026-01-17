# DevSecOps CI/CD Pipeline using Jenkins, Terraform & Trivy

## Project Overview
This project demonstrates the implementation of a **DevSecOps CI/CD pipeline** that automates secure cloud infrastructure provisioning on AWS using Terraform and Jenkins, with integrated security scanning using Trivy.

The pipeline enforces **security-by-design principles** by scanning Infrastructure as Code (IaC) for vulnerabilities before deployment and applying industry best practices such as restricted network access, encryption, and metadata protection.

---

## Architecture Explanation

### CI/CD Workflow
1. Source code is pushed to a GitHub repository.
2. Jenkins pipeline is triggered automatically.
3. Pipeline stages include:
   - Source code checkout
   - Tool installation (Terraform and Trivy)
   - Terraform security scan using Trivy
   - Terraform initialization and planning
   - Manual approval gate
   - Terraform apply (deployment)
4. Application is deployed on AWS EC2 using Docker.

### AWS Infrastructure Architecture
- Virtual Private Cloud (VPC)
- Private Subnet
- Internet Gateway
- Route Table and Association
- Security Group with restricted ingress rules
- Elastic Network Interface (ENI)
- Elastic IP (EIP)
- EC2 Instance running a containerized Flask application

---

## Cloud Provider Used
- **Amazon Web Services (AWS)**
  - EC2
  - VPC
  - Subnets
  - Security Groups
  - Elastic IP
  - Internet Gateway

---

## Tools and Technologies

| Category | Tools |
|--------|-------|
| CI/CD | Jenkins |
| Infrastructure as Code | Terraform |
| Security Scanning | Trivy |
| Containerization | Docker |
| Application | Python Flask |
| Cloud Platform | AWS |
| Version Control | GitHub |

---

## Before & After Security Report

### Before Security Hardening
- Security group allowed open ingress (`0.0.0.0/0`)
- No enforcement of IMDSv2
- Root EBS volume not encrypted
- Terraform code failed Trivy security scans

### After Security Hardening
- SSH access restricted to a specific admin IP (`/32`)
- Application port access restricted
- Root EBS volume encryption enabled
- IMDSv2 enforced
- No automatic public IP assignment
- Trivy scan passes with no HIGH or CRITICAL vulnerabilities

---

## Screenshots

Screenshots are stored inside the `screenshots/` directory.

- Initial failing Jenkins scan:
<img width="1365" height="635" alt="image" src="https://github.com/user-attachments/assets/a464f2cc-b920-4207-be18-9d81cff4364e" />
<img width="1356" height="668" alt="image" src="https://github.com/user-attachments/assets/8d75ddaa-3b60-407e-af3c-76acb61fa44f" />
- Final passing Jenkins scan:
<img width="1365" height="681" alt="image" src="https://github.com/user-attachments/assets/9b6a5f7e-55f3-4acf-b110-0816e6ea2e5d" />
<img width="1361" height="681" alt="image" src="https://github.com/user-attachments/assets/b75d4efa-ebfb-4440-8977-2978db21931b" />
<img width="1365" height="686" alt="image" src="https://github.com/user-attachments/assets/0d32d7d8-cd23-4890-a13c-d0d3a998858c" />

---

## AI Usage Log (Mandatory)

### Exact AI Prompt Used
Help me fix Trivy security vulnerabilities in my Terraform AWS infrastructure
and design a secure DevSecOps Jenkins pipeline with best practices.

### Summary of Identified Risks
- Overly permissive security group rules
- Lack of EC2 metadata service protection
- Missing encryption for EBS volumes
- No automated security scanning in CI/CD
- Absence of approval gate before deployment

### AI-Recommended Security Improvements
- Restricted SSH and application access to a specific admin IP
- Enforced IMDSv2 for EC2 metadata protection
- Enabled encryption for EBS root volumes
- Integrated Trivy security scanning into Jenkins
- Added manual approval stage before Terraform apply
- Applied least-privilege networking principles

### Security Impact
The AI-recommended changes significantly reduced the attack surface, improved cloud security compliance, and ensured security validation is enforced automatically during pipeline execution.

---

## Notes on Deployment Status
The pipeline successfully completes:
- Security scanning
- Terraform initialization
- Terraform planning
- Manual approval stage

A runtime failure occurred during EC2 creation due to an AWS provider dependency resolution issue. This does not affect the security architecture or CI/CD pipeline design demonstrated in this project.

---

## Conclusion
This project demonstrates a practical implementation of a **secure DevSecOps CI/CD pipeline**, integrating automation, Infrastructure as Code, and security scanning to enforce best practices throughout the deployment lifecycle.

---

## Author
**Pratik Vishwakarma**  
DevSecOps Assignment – 2026
