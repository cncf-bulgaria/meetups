This presentation and demo were presented at CNCF Bulgaria Meetup Platform Engineering

📅 Date: July 25, 2024<br>
⏰ Time: 19:05<br>
📍 Location: [HyperScience](https://maps.app.goo.gl/8mLk6qimnu4bQ7NR9)<br>
🗓 Meetup: [Meetup July](https://www.meetup.com/cloud-native-computing-bulgaria/events/301994449/) <br>

[Welcome](./Welcome_jun_2024.pdf)  
[Presentation](./Revolutionizing_Cloud_Infrastructure.pdf)  

# Getting Started

1. Signup for early access to Unikraft Cloud  
   https://console.unikraft.cloud/signup

1. Install KraftKit
   ```bash
   curl -sSfL https://get.kraftkit.sh | sh
   ```
   [Git Repository](https://github.com/unikraft/kraftkit)

1. Check the installed version
   ```bash
   kraft version

   kraft 0.9.0 (ef8b2581b9a401f53beef7cfab23476d52710f1d) go1.22.3 2024-07-26T12:55:43Z
   ```
   Note: You need version 0.9.0 or newer.

1. Set the token and metro
   ```bash
   export UKC_TOKEN=<TOKEN>
   export UKC_METRO=fra0
   ```
   Note: You can list the metros as follows:
   ```bash
   kraft cloud metro ls

   CODE  IPV4           LOCATION        PROXY
   fra0  145.40.93.137  Frankfurt, DE   fra0.kraft.host
   dal0  147.28.196.53  Dallas, TX      dal0.kraft.host
   sin0  145.40.71.141  Singapore       sin0.kraft.host
   was1  3.211.205.241  Washington, DC  was1.kraft.host
   ```

1. Check your quota
   ```bash
   kraft cloud quotas

             user uuid: <USER_UUID>
             user name: <USERNAME>
   
         image storage: [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0 B/1.0 GiB
   
      active instances: [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0/16
       total instances: [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0/16
   
    active used memory: [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0 B/4.0 GiB
    memory size limits: 16 MiB-2.0 GiB
   
      exposed services: [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0/253
              services: [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0/253
   
               volumes: enabled
        active volumes: [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0/253
     used volume space: [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 0 B/1.0 GiB
    volume size limits: 1.0 MiB-1.0 GiB
   
             autoscale: enabled
       autoscale limit: 1-16
         scale-to-zero: enabled
   ```

1. Contacts  
   - [Discord](https://unikraft.cloud/discord)
   - [X](https://x.com/UnikraftCloud)
   - [Linkedin](https://linkedin.com/company/unikraft-sdk)
   - [GitHub](https://github.com/unikraft-cloud/examples)  
   You can reach the team on Discord.

1. Websites
   - [Unikraft](https://unikraft.org/)
   - [Unikraft Docs](https://unikraft.org/docs/)
   - [Unikraft Cloud](https://unikraft.cloud/)
   - [Unikraft Cloud Docs](https://unikraft.cloud/docs/)

# Demos

- [Running Unikraft unikernel locally](./running_locally.md)
- [Running Unikraft unikernel on Unikraft Cloud](./running_on_cloud.md)
- [Running Unikraft unikernel on Unikraft Cloud with scale-to-zero enabled](./running_on_cloud_scale_to_zero.md)
