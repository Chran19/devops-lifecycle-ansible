# DevOps Configuration Management using Ansible & AWS EC2
> **CNAD / DevOps Engineering Assignment:** DevOps Case Study & Ansible Automation  
> **Student:** Ranjeet Choudhary (PRN: 202301100046)

---

## 📌 Project Overview
This repository contains the configuration management and automation solution for deploying a multi-tier web server infrastructure on AWS EC2 using **Ansible**. 

The playbook automates system updates, Nginx web server installation, service state verification, and web application code deployment across multiple EC2 target instances from a single Ansible Control Node.

Detailed academic analysis, DevOps lifecycle breakdown, and automation requirements are documented in [**DEVOPS_CASE_STUDY_REPORT.md**](file:///C:/Users/Ranjeet/Desktop/CNAD/cnad_activity_01/DEVOPS_CASE_STUDY_REPORT.md).

---

## 🏗️ Architecture & Workflow

```text
               +----------------------------------+
               |      Ansible Control Node        |
               |      (WSL / Local Machine)       |
               +----------------+-----------------+
                                |
                   SSH (Port 22) | Private Key (.pem)
                                |
               +----------------+-----------------+
               |                                  |
    +----------v----------+            +----------v----------+
    |  AWS EC2 Instance 1 |            |  AWS EC2 Instance 2 |
    |   (Target Web01)    |            |   (Target Web02)    |
    |    Nginx Server     |            |    Nginx Server     |
    +---------------------+            +---------------------+
```

---

## 🛠️ Tech Stack & Prerequisites
- **Cloud Provider:** AWS EC2 (Ubuntu 24.04 LTS / 22.04 LTS)
- **Configuration Management:** Ansible 2.15+ / 2.19+
- **Control Node Environment:** WSL (Ubuntu) / Linux / macOS
- **Text Editor & IDE:** Visual Studio Code
- **Remote Access:** SSH key pair (`ansible-key.pem`)
- **Web Server:** Nginx

---

## 📁 Repository Structure

```text
cnad_activity_01/
├── ansible.cfg                  # Ansible global default configurations
├── inventory/
│   └── aws_hosts.ini            # Target EC2 public IPs and SSH variables
├── site.yml                     # Playbook for installing Nginx & deploying site
├── index.html                   # Custom HTML web application landing page
├── DEVOPS_CASE_STUDY_REPORT.md  # Comprehensive DevOps Case Study & Demo Script
├── screenshots/                 # Execution evidence screenshots
│   └── README.md
└── README.md                    # Project documentation
```

---

## 🚀 Execution Guide

### 1. Configure Inventory
Update `inventory/aws_hosts.ini` with your active AWS EC2 Public IPv4 addresses:

```ini
[webservers]
web01 ansible_host=51.20.115.127
web02 ansible_host=16.171.242.90

[webservers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/ansible-key.pem
ansible_python_interpreter=/usr/bin/python3
```

### 2. Verify SSH Connectivity (Ping Test)
Run the Ansible ping module to verify connectivity to both target servers:

```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible webservers -i inventory/aws_hosts.ini -m ping
```

### 3. Run the Ansible Playbook
Execute the playbook to automate web server configuration:

```bash
ANSIBLE_CONFIG=./ansible.cfg ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/aws_hosts.ini site.yml
```

### 4. Web Verification
Navigate to `http://<EC2_PUBLIC_IP_1>` and `http://<EC2_PUBLIC_IP_2>` in a web browser to confirm the deployed application landing page.

---

## 🎥 Recorded Online Demonstration Link
- **Demo Video URL:** *[Insert your Loom / YouTube unlisted / Google Drive link here]*
- A complete, step-by-step speaker script for the demonstration is provided in [DEVOPS_CASE_STUDY_REPORT.md](file:///C:/Users/Ranjeet/Desktop/CNAD/cnad_activity_01/DEVOPS_CASE_STUDY_REPORT.md#8-recorded-online-demonstration-speaker-script-3-5-minutes).

---

## 👨‍💻 Author
- **Name:** Ranjeet Choudhary  
- **PRN:** 202301100046  
- **Course:** Cloud Native Application Development (CNAD)
