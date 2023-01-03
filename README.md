# amazing_app

## Getting Started

This is a Junior Design project Instructed by DR. NABEEL MOHAMMED sir. 

Group Members:
HASIBULLAH HASIB, 
FAISAL AHMED SIFAT, 
NABIHA

![107](https://user-images.githubusercontent.com/41996704/210306117-60ec719b-e671-4818-add6-3b33f2905467.jpg)


# Introduction
“Amazing app” gives an interface to encrypt data (PDFs, Images, Docx) and upload them to Google Drive and view it. This app ensures that the person using the phone is the person who created the account. As a result, No one but the user can access the data inside the app. 

“Amazing app” uses one of the most secure encryption methods. The app lets users encrypt documents and upload the encrypted document to Google Drive. So, The uploaded file in Google Drive is secure. The user can view the file by decrypting it. To make sure the person accessing the file is the owner, it runs facial recognition and face anti-spoofing. If the facial recognition mismatch is detected, the app will close itself. When logging in for the first time, the user will have to take a picture of themselves. The App will use this picture for face recognition.  No one from outside the app can access the decrypted content.
The importance of protecting sensitive information cannot be overstated, particularly in today's digital age where data breaches and cyber threats are becoming increasingly common. Businesses and individuals alike are at risk of losing sensitive information to hackers, who can use this information for nefarious purposes such as identity theft or financial fraud.

Our app offers a range of core features that make it an essential tool for businesses and individuals alike such as 1. Google Sign In, 2. File encryption and decryption, 3. Upload the encrypted file to google drive, 4. Decrypt the encrypted files and view them within the app, 5. Facial recognition and anti-spoofing are required before performing every task. 

By using Google Sign-In, our app provides a secure and convenient way for users to access the
features and functionality it offers. Whether you're a frequent user or just signing in for the first time, all it takes is a single click to log in with your Google account. So why wait? Start using our app today and experience the convenience and security of Google Sign-In.

Our app makes it easy for users to upload their files to Google Drive, whether they are photos, documents, or any pdf files. Simply select the file you want to upload and our app will handle the rest, encrypting the file and transferring the file to your Google Drive account very quickly.

One of the standout features of the app is its use of facial recognition and anti-spoofing technology to verify the identity of the user before granting access to the encrypted files. This added layer of security helps to prevent unauthorized access to sensitive information, making it an essential tool for businesses and individuals alike. 

# Main Features
1. Google Authentication
2. Integrated Google Drive api's for drive access
3. Implemented file encryption and decryption
4. Implemented Facial Recognition
5. Implemented Anti Spoofing

# Application Flow Diagram
<img width="1250" alt="Screen Shot 2022-12-17 at 11 48 48 PM" src="https://user-images.githubusercontent.com/41996704/210306616-ea53265d-83f4-4651-bc82-a2815948bf28.png">

# System Design 

Here is a high-level system design diagram for an app that encrypts and decrypts files and uploads them to Google Drive and uses face recognition and anti-spoofing technology:
[User Device] <-> [App] <-> [Encryption/Decryption] <-> [Google Drive] <-> [Facial Recognition/Anti-Spoofing]
This system design consists of the following components:

1. User device: This is the device that the user is using to access the app, such as a smartphone or computer.
2. App: This is the main component of the system, which handles the user interface and the core functionality of the app, such as file encryption/decryption and facial recognition/anti-spoofing.
3. Encryption/decryption: This component is responsible for encrypting and decrypting the user's files as needed.
4. Google Drive: This component represents the user's Google Drive account, which is used to store and access encrypted files.
5. Facial recognition/anti-spoofing: This component is responsible for verifying the identity of the user using facial recognition and anti-spoofing technology.
Here is a more detailed system design diagram that shows the interactions between these components:

<img width="1276" alt="Screen Shot 2022-12-21 at 11 26 27 PM" src="https://user-images.githubusercontent.com/41996704/210306781-ad640cca-ee12-4cbd-8653-24c74ad21be4.png">

# System Evaluation
System evaluation is the process of assessing the performance and effectiveness of a system, in this case, an app that encrypts and decrypts files and uploads them to Google Drive and uses face recognition and anti-spoofing. Some key aspects that we considered evaluating in this app include:

1. Functionality: Does the app perform all of the intended functions as designed, such as encrypting and decrypting files, uploading them to Google Drive, and using face recognition and anti-spoofing measures?
2. Usability: Is the app easy to use and navigate for the intended users? Is the interface intuitive and user-friendly?
3. Performance: Does the app run smoothly and efficiently, without experiencing any delays or issues?
4. Security: Does the app adequately protect the confidentiality and integrity of the encrypted files? Does it effectively prevent attempts at spoofing or bypassing the face recognition feature?
5. Reliability: Is the app consistently available and able to perform its functions without experiencing any failures or errors?
6. Scalability: Is the app able to handle a large number of users and handle large files without experiencing any performance issues?
7. User satisfaction: Do users find the app useful and meet their needs and expectations?

To conduct a thorough evaluation of the app, we gathered data and feedback from a variety of sources, such as user surveys, performance logs, and error reports. Based on this data, the system is evaluated against established benchmarks or goals, and any necessary improvements were identified and implemented.

# Relevant Metrics

## Micro F1 Score:
The micro F1 score is a relevant metric for evaluating the performance of an app that uses facial recognition and anti-spoofing. This metric could be used to measure the app's accuracy in correctly identifying user faces and preventing attempts at spoofing or bypassing the facial recognition feature.
To calculate the micro F1 score for this app, we needed to collect data on the app's true positive, false positive, and false negative predictions. True positive predictions would be instances where the app correctly identified a user's face and did not trigger the anti-spoofing measures. False positive predictions would be instances where the app triggered the anti-spoofing measures but the user's face was actually genuine. False negative predictions would be instances where the app failed to identify a user's face or triggered the anti-spoofing measures when the user's face was genuine.
Using this data, we could calculate the precision and recall for the app, and then use these values to compute the micro F1 score. A higher micro F1 score would indicate better performance in terms of facial recognition accuracy and anti-spoofing effectiveness.
The micro F1 score is calculated as follows:

### Micro F1 = 2 * (precision * recall) / (precision + recall)

The micro F1 score ranges from 0 to 1, with higher scores indicating better performance. A score of 1 indicates perfect precision and recall, while a score of 0 indicates that the model is not making any true positive predictions.

## Accuracy
There are several metrics that could be used to measure the accuracy of the Amazing App:
1. True positive rate (TPR) or sensitivity: This is the proportion of genuine user faces that are correctly identified by the app. It can be calculated as the number of true positive predictions made by the app out of all the actual positive instances (genuine user faces).
2. True negative rate (TNR) or specificity: This is the proportion of non-genuine faces (e.g., spoofed faces) that are correctly identified by the app as non-genuine. It can be calculated as the number of true negative predictions made by the app out of all the actual negative instances (non-genuine faces).
3. False positive rate (FPR): This is the proportion of non-genuine faces (e.g., spoofed faces) that are incorrectly identified by the app as genuine. It can be calculated as the number of false positive predictions made by the app out of all the actual negative instances (non-genuine faces).
4. False negative rate (FNR): This is the proportion of genuine user faces that are incorrectly identified by the app as non-genuine. It can be calculated as the number of false negative predictions made by the app out of all the actual positive instances (genuine user faces).
5. Accuracy: This is the overall proportion of correct predictions made by the app. It can be calculated as the number of true positive and true negative predictions made by the app out of all predictions made.

By tracking these metrics, it is possible to gain insight into the app's performance in terms of facial recognition accuracy and anti-spoofing effectiveness. Besides that we also considered metrics that are relevant for other functionalities and usability of the app:

1. Number of files encrypted/decrypted: This metric provides insight into the overall usage of the app and the extent to which it is meeting the needs of its users.
2. Number of files successfully uploaded to Google Drive: This metric indicates the reliability of the app's file upload functionality.
3. Accuracy of face recognition: This metric measures the effectiveness of the app's face recognition feature in correctly identifying the users' faces.
4. Success rate of anti-spoofing measures: This metric measures the app's ability to prevent attempts at spoofing or bypassing the face recognition feature.
5. Time required to encrypt/decrypt files: This metric provides insight into the app's performance and efficiency in handling large files.
User satisfaction: This metric is collected through surveys  and provides insight into how well the app is meeting the needs and expectations of its users.
6. Number of active users: This metric provides insight into the overall popularity and adoption of the app.

# Use cases where anti-spoofing failed
5 ways in which we found anti-spoofing did not work as expected:

1. Poor lighting conditions: Our facial recognition system sometimes struggles to accurately recognize faces if the lighting is poor or uneven.
2. Occlusion: If part of the face is covered or obscured, the facial recognition system may be unable to recognize the person. For example, wearing sunglasses or using face masks.
3. Different angles or poses: The system has difficulty recognizing faces that are captured from unusual angles or pose. 
4. Changing facial features: Our facial recognition system sometimes struggles to recognize individuals who have undergone significant changes to their appearances, such as a haircut or facial hair growth.
5. Direct Sunlight: The system struggles to recognize faces if the picture is taken directly from the opposite of the sun where the sunlight hits the camera directly. 





