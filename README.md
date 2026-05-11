# AttenDID: Attendance System Using Virtual Card

This project introduces a smart attendance system leveraging Near Field Communication (NFC) technology to digitize and simplify attendance tracking in educational institutions. By simulating a virtual card via a mobile application, the system eliminates the need for physical tokens, reduces forgery risks through "Device Binding," and provides real-time data synchronization with cloud-based analytics.

### 1.0 PROJECT OVERVIEW
***
Traditional attendance tracking methods like manual sign-in and biometric sensors are time-intensive, error-prone, and susceptible to proxy check-ins. **AttenDID** addresses these gaps by utilizing Host Card Emulation (HCE) to turn smartphones into secure digital identities.

#### Key Objectives

* **Requirement Research:** Gather requirements for NFC virtual and physical cards within secure recording contexts.


* **System Development:** Create an NFC tag-based check-in application that confirms student identity using unique card IDs.


* **Cloud Integration:** Develop a safe cloud-based data pipeline (Firebase) to organize and save authorized attendance incidents.


* **Predictive Analytics:** Implement predictive models to identify chronic absenteeism risk trends.



### 2.0 TECHNICAL ARCHITECTURE
***
The system is built on a client-server architecture designed for high availability and real-time responsiveness.

#### Technology Stack

* **Frontend:** Developed using the **Flutter** framework and **Dart** for efficient performance on Android devices.


* **Backend:** Built on **Google Firebase**, specifically **Cloud Firestore**, for its scalable NoSQL document model and real-time synchronization.


* **Security:** Payloads are encrypted using **AES-256**, and network traffic is secured via SSL/TLS.


* **Integrity:** Employs a **One Device Policy** by capturing unique device IDs during login to prevent students from marking attendance for others.



### 3.0 SYSTEM DEVELOPMENT & TESTING
***
The project followed the **Rapid Application Development (RAD)** methodology, emphasizing quick prototyping and iterative user feedback.

#### Performance & Testing

* **Black Box Testing:** Conducted to verify major operations like NFC registration and push notifications from the end-user perspective.


* **User Acceptance Testing (UAT):** Completed by multiple testers who confirmed the system behaves as intended and meets university requirements.


* **Benchmarking:** The system is designed to process an NFC scan and update the database within two seconds.



### 4.0 KEY FEATURES
***
* **Virtual Card Activation:** Students can convert their physical ID data into a secure digital profile.


* **Role-Based Access:** Distinct interfaces and functionalities for students, lecturers, and administrators.


* **Real-time Monitoring:** Lecturers can monitor attendance live and export reports immediately after class.


* **Fallback Mechanism:** Includes a manual attendance recording option for devices that lack NFC support or encounter hardware errors.



### 5.0 PREREQUISITES
***
#### Environment

* **Mobile:** Android 8.0+ devices with embedded NFC hardware.


* **Web:** React.js dashboard served over HTTPS.



#### Libraries & Setup

* **Core Libraries:** `nfc_manager` for tag communication, `cloud_firestore` for database operations, and `google_fonts` for UI consistency.


* **Backend Setup:** Requires a Firebase project with Cloud Firestore and Firebase Functions enabled.


### ***📝 CONTRIBUTORS***
***
* ***Fatheen Sara Sofiah binti Romy Norfidzy*** 
  * Responsible for Problem Statement, Database Design, UI/UX Prototype Development, and Future Enhancements
  <br>
* ***Nur Farisya Adila Binti Razaly*** 
  * Responsible for Project Objectives, System Implementation, System Testing, and Quality Assurance
<br>

***This project is for educational purposes.***
