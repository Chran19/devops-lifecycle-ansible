# DevOps Case Study & Ansible Automation: Production Configuration Management
**Course:** Cloud Native Application Development (CNAD) / DevOps Engineering  
**Activity:** DevOps Case Study & Ansible Automation Assignment  
**Student Name:** Ranjeet Choudhary  
**PRN:** 202301100046  
**Date:** October 2026  

---

## 1. Executive Summary & Selected Real-World Application Scenario

### 1.1 Selected Scenario: High-Volume E-Commerce Platform ("ShopStream Web Tier")
To satisfy the requirements of this assignment, this case study examines **ShopStream**, a rapidly expanding cloud-hosted e-commerce retail platform. ShopStream experiences seasonal traffic spikes (e.g., flash sales, holiday promotions) requiring elastic horizontal scaling of its public-facing web tier across multiple AWS Elastic Compute Cloud (EC2) instances.

### 1.2 The Business & Operational Problem
Before adopting a formal DevOps methodology, ShopStream relied on manual system administration:
- **Configuration Drift:** Individual EC2 instances drifted in configuration due to ad-hoc manual hotfixes applied directly via SSH by different sysadmins.
- **Slow Deployment Cycles:** Manually provisioning web servers, updating package caches, installing Nginx, and deploying web bundles took over 45 minutes per instance.
- **Inconsistent Environments:** Discrepancies between staging and production instances led to subtle bugs, broken SSL certificates, and downtime during updates.
- **Lack of Auditability & Version Control:** System configurations were not documented as code, making disaster recovery and regulatory compliance auditing nearly impossible.

### 1.3 DevOps Objectives
1. **Infrastructure as Code (IaC) & Configuration Management (CM):** Codify entire server states in declarative, idempotent Ansible playbooks stored in version control (Git).
2. **Speed & Repeatability:** Reduce target server provisioning time from 45 minutes to under 60 seconds per instance.
3. **Zero Configuration Drift:** Enforce guaranteed identical states across all distributed nodes.
4. **Agentless Architecture:** Eliminate the resource overhead and security risks of background agents by utilizing native OpenSSH.

---

## 2. DevOps Lifecycle Analysis

The DevOps lifecycle for the ShopStream platform is organized into eight continuous, interconnected phases:

```
+------------+     +------------+     +------------+     +------------+
|   1. PLAN  | --> |  2. CODE   | --> |  3. BUILD  | --> |  4. TEST   |
+------------+     +------------+     +------------+     +------------+
                                                                |
+------------+     +------------+     +------------+            v
| 8. MONITOR | <-- | 7. OPERATE | <-- |  6. DEPLOY | <-- +------------+
+------------+     +------------+     +------------+     | 5. RELEASE |
                                                         +------------+
```

| Lifecycle Stage | Objectives & Activities | Tools & Technologies | Applied DevOps Practices |
| :--- | :--- | :--- | :--- |
| **1. Plan** | Requirements gathering, capacity planning for flash sales, sprint planning, and architecture design. | Jira / GitHub Projects, Confluence | Agile Planning, Backlog Grooming, Infrastructure Sizing |
| **2. Code** | Authoring web application artifacts (`index.html`), Ansible playbooks (`site.yml`), and inventory definitions. | Git, GitHub, VS Code | Infrastructure as Code (IaC), Git feature branching, peer code review |
| **3. Build** | Validating syntax of playbooks, compiling static web assets, and linting configurations. | `ansible-lint`, YAML validators, GitHub Actions | Continuous Integration (CI), automated linting |
| **4. Test** | Verifying target connectivity via SSH ping tests, syntax checking (`--syntax-check`), and dry-run execution (`--check`). | Ansible `ping` module, Molecule, Testinfra | Automated Testing, Shift-Left Quality Assurance |
| **5. Release** | Tagging verified playbook releases and artifact bundles ready for staging and production rollout. | Git Tags, GitHub Releases, AWS S3 Artifact Store | Versioned Releases, Change Management |
| **6. Deploy** | Automated push-based execution of Ansible playbook configuring Ubuntu EC2 instances and starting Nginx services. | Ansible Engine, AWS EC2, OpenSSH | Continuous Deployment (CD), Automated Configuration Management |
| **7. Operate** | Maintaining Nginx web server availability, system daemon auto-restart, OS patching, and security updates. | Systemd, Ubuntu Apt, AWS Security Groups | Self-Healing Daemons, Standardized Hardening |
| **8. Monitor** | Monitoring HTTP response codes, server CPU/memory metrics, SSH logs, and application uptime. | Prometheus, Grafana, AWS CloudWatch, Uptime Kuma | Continuous Observability, Proactive Alerting |

---

## 3. DevOps Architecture & End-to-End Workflow

### 3.1 Architectural Diagram
The configuration management infrastructure follows a push-based, agentless hub-and-spoke topology:

```text
                                  +---------------------------------------+
                                  |         Ansible Control Node          |
                                  |     (WSL / Local Admin Terminal)      |
                                  |                                       |
                                  |  - ansible.cfg (global settings)      |
                                  |  - inventory/aws_hosts.ini            |
                                  |  - site.yml (declarative tasks)       |
                                  |  - index.html (landing asset)         |
                                  +-------------------+-------------------+
                                                      |
                                     OpenSSH (Port 22) | Identity: ansible-key.pem
                                     Push Protocol    | Python 3 execution
                                                      |
                        +-----------------------------+-----------------------------+
                        |                                                           |
                        v                                                           v
        +-------------------------------+                           +-------------------------------+
        |    Target Node 1 (web01)      |                           |    Target Node 2 (web02)      |
        |  Public IP: 51.20.115.127     |                           |  Public IP: 16.171.242.90     |
        |  OS: Ubuntu 24.04/22.04 LTS   |                           |  OS: Ubuntu 24.04/22.04 LTS   |
        |  Role: Nginx Web Server       |                           |  Role: Nginx Web Server       |
        |  Service: Systemd (Port 80)   |                           |  Service: Systemd (Port 80)   |
        +-------------------------------+                           +-------------------------------+
                        |                                                           |
                        +-----------------------------+-----------------------------+
                                                      |
                                            HTTP Port 80 / Public Traffic
                                                      v
                                        +---------------------------+
                                        |  End Users / Web Clients  |
                                        +---------------------------+
```

### 3.2 End-to-End Workflow Execution
1. **Host Preparation:** Two Ubuntu EC2 target instances are provisioned on AWS with Security Group rules permitting inbound SSH (Port 22) and inbound HTTP (Port 80).
2. **Inventory Mapping:** The Control Node organizes target IPs into the `[webservers]` host group inside `inventory/aws_hosts.ini`.
3. **Authentication:** OpenSSH key-based authentication is established using `ansible-key.pem` with strictly controlled Unix permissions (`chmod 400`).
4. **Configuration Execution:**
   - Control node connects concurrently over SSH.
   - Sudo privileges (`become: yes`) are elevated.
   - Apt repository cache is updated.
   - Nginx package is installed idempotently.
   - Systemd ensures Nginx is enabled to survive reboots and is active.
   - The custom application `index.html` is transferred with `0644` permissions under `www-data` ownership.
5. **Validation:** Automated and browser-level HTTP queries confirm successful configuration on both nodes.

---

## 4. Automation Requirements & Tool Selection Rationale

### 4.1 Why Ansible for Configuration Management?
| Feature | Ansible | Shell Scripts (Bash) | Puppet / Chef |
| :--- | :--- | :--- | :--- |
| **Architecture** | **Agentless** (pure SSH & Python) | Agentless (SSH) | Requires heavy background agent daemon |
| **Idempotency** | **Native** (only applies changes when state differs) | Non-trivial (requires complex manual if/else checks) | Native |
| **Learning Curve** | **Low** (human-readable YAML) | Medium | Steep (Ruby / Domain Specific Languages) |
| **Configuration Drift** | **Automatically rectified** on each run | Prone to error on rerun | Automatically rectified |
| **Security Footprint** | Minimal; uses existing OS SSH infrastructure | Minimal | High (agent certificates, master-agent trust) |

### 4.2 Key Automation Requirements Identified
1. **Idempotence:** Re-running `site.yml` multiple times must produce zero unintended changes (`changed=0`), ensuring stability across multiple deployment runs.
2. **Declarative State Specification:** Specifying *what* the system state should be (e.g., `state: started`, `state: present`) rather than *how* to execute shell commands step-by-step.
3. **Multi-Host Concurrency:** The ability to configure 2, 20, or 200 servers simultaneously with a single command invocation.
4. **Environment Isolation & Portability:** Centralized configuration (`ansible.cfg`) allowing playbooks to execute reliably across different developer machines or CI/CD runners without machine-specific hardcoding.

---

## 5. Implementation Artifacts Deep Dive

### 5.1 Global Configuration (`ansible.cfg`)
Configures the runtime defaults to streamline operations and eliminate interactive prompt friction:
```ini
[defaults]
inventory = ./inventory/aws_hosts.ini
remote_user = ubuntu
private_key_file = ~/.ssh/ansible-key.pem
host_key_checking = False
retry_files_enabled = False
```
- `host_key_checking = False`: Prevents execution blocking caused by interactive SSH host key verification prompts during automated runs.
- `inventory`: Pre-binds the target inventory file so `-i` flags are optional.

### 5.2 Inventory Organization (`inventory/aws_hosts.ini`)
Defines the inventory structure and centralized connection parameters:
```ini
[webservers]
web01 ansible_host=51.20.115.127
web02 ansible_host=16.171.242.90

[webservers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/ansible-key.pem
ansible_python_interpreter=/usr/bin/python3
```
- Groups multiple instances logically under `[webservers]`.
- Uses group variables (`[webservers:vars]`) to avoid duplicating credentials across individual host lines.

### 5.3 Playbook Structure (`site.yml`)
The playbook encapsulates complete web server provisioning in four idempotent tasks:
```yaml
---
- name: Configure Webservers and Deploy Application
  hosts: webservers
  become: yes
  tasks:

    - name: Update apt package cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install Nginx Web Server
      apt:
        name: nginx
        state: present

    - name: Ensure Nginx service is started and enabled on boot
      service:
        name: nginx
        state: started
        enabled: yes

    - name: Deploy Custom HTML Index File
      copy:
        src: ./index.html
        dest: /var/www/html/index.html
        owner: www-data
        group: www-data
        mode: '0644'
```

---

## 6. Execution & Verification Guide

### 6.1 Step 1: Pre-flight Ping Verification
Tests end-to-end SSH connectivity and Python availability on all managed targets:
```bash
ansible webservers -i inventory/aws_hosts.ini -m ping
```
**Expected Successful Response:**
```json
web01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
web02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

### 6.2 Step 2: Playbook Execution
Executes the provisioning sequence:
```bash
ansible-playbook -i inventory/aws_hosts.ini site.yml
```
**Expected Play Recap Output:**
```text
PLAY RECAP *********************************************************************
web01                      : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
web02                      : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### 6.3 Step 3: Idempotency Validation (Second Run)
Executing the playbook a second time without modifications should yield `changed=0`:
```text
PLAY RECAP *********************************************************************
web01                      : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
web02                      : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### 6.4 Step 4: Web Browser Endpoint Verification
Open any modern web browser and navigate to:
- `http://51.20.115.127`
- `http://16.171.242.90`

Both targets display the custom landing page:
> **Automated Deployment via Ansible**  
> *Status: Active & Configured Successfully!*

---

## 7. Submission Deliverables Checklist & Demonstration Guide

### 7.1 Deliverables Checklist
- [x] **Ansible Inventory File:** `inventory/aws_hosts.ini`
- [x] **Ansible Global Config:** `ansible.cfg`
- [x] **Ansible Playbook:** `site.yml`
- [x] **Application Source Artifact:** `index.html`
- [x] **DevOps Case Study Documentation:** `DEVOPS_CASE_STUDY_REPORT.md` / `README.md`
- [ ] **Execution Screenshots:** Store in `screenshots/` directory
  - `01_aws_ec2_instances.png`: AWS Management Console showing active EC2 instances
  - `02_ansible_ping_test.png`: Terminal output showing ping pong success
  - `03_playbook_run.png`: Terminal output showing playbook execution and recap
  - `04_web_verification_web01.png`: Browser view of web01 public IP
  - `05_web_verification_web02.png`: Browser view of web02 public IP
- [ ] **Recorded Video Demonstration Link:** Embed Loom / YouTube unlisted / Google Drive link below.

---

## 8. Recorded Online Demonstration: Speaker Script (3-5 Minutes)

Use this structured script when recording your demonstration video:

### 🎬 Slide / Screen 1: Introduction (0:00 - 0:45)
- **What to show on screen:** Open the project in VS Code with `README.md` and `DEVOPS_CASE_STUDY_REPORT.md` visible.
- **What to say:**  
  *"Hello everyone, my name is Ranjeet Choudhary, PRN 202301100046. Today I am presenting my DevOps Case Study and Ansible Configuration Management Assignment. For this project, I selected an e-commerce web platform scenario where horizontal scalability and zero configuration drift across cloud servers are vital. I designed a DevOps lifecycle workflow and implemented automated configuration management using Ansible to provision multi-instance web servers on AWS EC2."*

### 🎬 Slide / Screen 2: Architecture & Project Structure (0:45 - 1:30)
- **What to show on screen:** Show the project folder tree (`ansible.cfg`, `inventory/aws_hosts.ini`, `site.yml`, `index.html`).
- **What to say:**  
  *"Let's look at the project architecture. Our Ansible Control Node connects over secure SSH to two target AWS EC2 instances running Ubuntu. Ansible is agentless, meaning no software needs to be pre-installed on the target nodes beyond Python. In `inventory/aws_hosts.ini`, we define our `webservers` group with the public IPv4 addresses and connection variables. Our `ansible.cfg` defines default parameters such as disabling host key checking for non-interactive automation."*

### 🎬 Slide / Screen 3: Playbook Walkthrough (1:30 - 2:30)
- **What to show on screen:** Open `site.yml` and highlight the tasks.
- **What to say:**  
  *"In `site.yml`, we define our declarative desired state with privilege escalation using `become: yes`. First, we update the Ubuntu apt package cache. Second, we install the Nginx web server using the `apt` module with `state: present`. Third, using the `service` module, we ensure Nginx is both enabled on boot and currently started. Finally, we copy our customized `index.html` application file to `/var/www/html/` with correct ownership and permissions."*

### 🎬 Slide / Screen 4: Live Execution & Demonstration (2:30 - 3:45)
- **What to show on screen:** Open your terminal (WSL / Linux).
- **What to say and do:**  
  1. Run: `ansible webservers -m ping`  
     *"First, we verify connectivity with an Ansible ping module test. Both nodes return SUCCESS with pong."*
  2. Run: `ansible-playbook site.yml`  
     *"Now, we execute the playbook. Ansible sequentially gathers facts, installs Nginx, configures the service, and deploys our code. Notice the play recap shows `ok=5` and `changed=4`."*
  3. Re-run: `ansible-playbook site.yml`  
     *"To demonstrate idempotence—a core DevOps principle—we run the playbook again. Notice that `changed=0`. Ansible detects that the system already matches the desired state and performs no redundant operations."*

### 🎬 Slide / Screen 5: Web Verification & Conclusion (3:45 - 4:30)
- **What to show on screen:** Switch to browser tabs showing `http://<web01-IP>` and `http://<web02-IP>`.
- **What to say:**  
  *"Finally, visiting both EC2 public IPs in the browser reveals our deployed application: 'Automated Deployment via Ansible'. This proves seamless, automated configuration management across distributed nodes. Thank you!"*

