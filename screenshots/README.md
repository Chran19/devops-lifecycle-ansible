# Execution Screenshots Directory

Please capture and save your assignment execution screenshots here with the following filenames:

1. **`01_aws_ec2_instances.png`**  
   Screenshot of the AWS EC2 Management Console showing your 2 running target instances (`web01` and `web02`) with active Public IPv4 addresses.

2. **`02_ansible_ping_test.png`**  
   Terminal screenshot showing the execution and success response of:
   ```bash
   ansible webservers -i inventory/aws_hosts.ini -m ping
   ```

3. **`03_playbook_run.png`**  
   Terminal screenshot showing the full execution of:
   ```bash
   ansible-playbook -i inventory/aws_hosts.ini site.yml
   ```
   (Make sure the PLAY RECAP at the bottom with `ok=5 changed=4` is clearly visible).

4. **`04_playbook_idempotence.png`** *(Optional but recommended for full marks)*  
   Terminal screenshot of running the playbook a second time showing `changed=0`, proving idempotence.

5. **`05_web_verification_web01.png`**  
   Web browser screenshot visiting `http://51.20.115.127` showing the "Automated Deployment via Ansible" page with URL bar visible.

6. **`06_web_verification_web02.png`**  
   Web browser screenshot visiting `http://16.171.242.90` showing the "Automated Deployment via Ansible" page with URL bar visible.

