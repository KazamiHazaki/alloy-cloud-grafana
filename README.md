# alloy-cloud-grafana
Monitoring system linux vm with grafana cloud and grafana alloy. This monitoring tools is based on https://grafana.com/docs/grafana-cloud/monitor-infrastructure/integrations/integration-reference/integration-linux-node/

What will tool monitored? 
- CPU and system
- Filesystem and disks
- Fleet overview
- Logs
- Memory
- Network
  
## Requirement 
- Grafana Cloud Account https://grafana.com/products/cloud/
- Telegram Bot

### Prerequisites
##### Create Grafana Cloud Account 
1. After sign up create domain that will used
   
![image](https://github.com/user-attachments/assets/da073e6b-a025-4e6a-b1c7-81ee7e8cd81f)

2. Select Quickstart
   
![image](https://github.com/user-attachments/assets/fddf2fed-22db-40d4-946f-999a4ca9dfda)

3. Choose Linux
   
![image](https://github.com/user-attachments/assets/6b03b815-bd77-4495-9471-2c54ed908622)

4. Craete API Token

Click Run Grafana Alloy then create new name token api, then craete token

![image](https://github.com/user-attachments/assets/9e98e76f-7ca5-4417-9cb3-fece746f8eeb)
![image](https://github.com/user-attachments/assets/58df889e-2e43-4915-8658-03f7c93cf10b)

Copy the token started with glc.....

![image](https://github.com/user-attachments/assets/b1aee98a-8b1c-4d0c-a7a7-96d60c127459)


##### Install Alloy Exporter 

```shell
 wget -O alloy.sh https://raw.githubusercontent.com/KazamiHazaki/alloy-cloud-grafana/refs/heads/main/install_alloy.sh && bash alloy.sh
```
![image](https://github.com/user-attachments/assets/19208811-e814-43db-8c95-552b31fdea58)

Answer the question that asksed, and paste Token Grafana Cloud


