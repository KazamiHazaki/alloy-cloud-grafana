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

#### 1. Configure Bot Telegram
1.1. chat with https://telegram.me/botfather and type `/start`  or 'start button' to activate bot

![image](https://github.com/user-attachments/assets/68515627-32e0-49a4-a62d-a153b3447029)


1.2. Create new bot '/newbot'
   
   ![image](https://github.com/user-attachments/assets/d32879cf-8b4f-4931-b324-f07dafa128ef)
   
1.3. set bot name then copy the API

![image](https://github.com/user-attachments/assets/5bab5520-6ea4-40c3-86a6-cbbb56c191ab)

1.4 Get Chat ID 

chat with https://t.me/RawDataBot 
paste your bots link and bot wil reply with json 

![image](https://github.com/user-attachments/assets/063b6375-0c5b-4dfa-92ff-c8059ffe2ec6)


#### 2. Create Grafana Cloud Account 
2.1 After sign up create domain that will used
   
![image](https://github.com/user-attachments/assets/da073e6b-a025-4e6a-b1c7-81ee7e8cd81f)

2.2. Select Quickstart
   
![image](https://github.com/user-attachments/assets/fddf2fed-22db-40d4-946f-999a4ca9dfda)

2.3. Choose Linux
   
![image](https://github.com/user-attachments/assets/6b03b815-bd77-4495-9471-2c54ed908622)

2.4. Craete API Token

Click Run Grafana Alloy then create new name token api, then craete token

![image](https://github.com/user-attachments/assets/9e98e76f-7ca5-4417-9cb3-fece746f8eeb)
![image](https://github.com/user-attachments/assets/58df889e-2e43-4915-8658-03f7c93cf10b)

Copy the token started with glc.....

![image](https://github.com/user-attachments/assets/b1aee98a-8b1c-4d0c-a7a7-96d60c127459)

Dont close grafana page and then install Alloy Exporter 

###### Install Alloy Exporter 

```shell
 wget -O alloy.sh https://raw.githubusercontent.com/KazamiHazaki/alloy-cloud-grafana/refs/heads/main/install_alloy.sh && bash alloy.sh
```
![image](https://github.com/user-attachments/assets/19208811-e814-43db-8c95-552b31fdea58)

Answer the question that asksed, and paste Token Grafana Cloud

After Install aloy test connection after success connection install dashboard

![image](https://github.com/user-attachments/assets/8972fbe8-fe57-4443-8b47-ebe075c1270d)

You can see the Dashboard in 

![image](https://github.com/user-attachments/assets/72c6cac2-dda3-4e1e-971e-9799230b7f68)
 


## Configure Grafana Cloud to send Alert in telegram

go to alerts -> contacts points 

![image](https://github.com/user-attachments/assets/d6a48b03-55e8-4955-b476-ec9911bb8b2f)

choose alert manager, dont use Grafana

![image](https://github.com/user-attachments/assets/fcc0a767-9c8e-4717-b81a-e9a08a4b6f44)

then add contact point 

![image](https://github.com/user-attachments/assets/f7f32a56-9a00-405b-9e6a-8389a903fa50)

set name contact point with 'Telegram' and choose integration with telegram

![image](https://github.com/user-attachments/assets/16260a08-1946-4f57-8fe4-068d1ff785e8)

Copy paste the chat id and bot token. save the contact point 

![image](https://github.com/user-attachments/assets/b236d14d-06fa-418e-b57a-226b2953537a)

Then go to notification policies

![image](https://github.com/user-attachments/assets/ac2cfc7b-3b3f-48f8-9ecc-fbc9acad7f70)

Make sure default contact point change to telegram then update it 

![image](https://github.com/user-attachments/assets/f8a92361-0959-4ac0-be8e-119d7abe7917)

![image](https://github.com/user-attachments/assets/4d83fb92-57e2-4bd3-bc9b-c9b6893996f8)

if success you will got alert in your bot 

![image](https://github.com/user-attachments/assets/207e5b16-b3bf-4642-bc52-ac71487632dc)
