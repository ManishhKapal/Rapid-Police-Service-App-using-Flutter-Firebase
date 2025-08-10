## Rapid Police Service App (Flutter & Firebase)

70% of the application is completed will complete it with future updates.
This mobile application provides a fast and efficient way to connect with police services during emergencies. Built with Flutter and Firebase, it offers real-time location sharing for a swift police response.

### Features

* Emergency contact button for immediate connection to police.
* Automatic live location sharing with the responding officer.
* User-friendly interface for quick and clear communication. 

### Prerequisites

* Flutter Development environment set up (including Flutter SDK and Dart).
* A Firebase project with the following services enabled:
    * Firebase Realtime Database (for live location sharing)
* Permissions for location access on the Android device.

### Installation

1. Clone this repository.
2. Navigate to the project directory in your terminal.
3. Run `flutter pub get` to install dependencies.

### Configuration

1. Create a `google_services.json` file in the project's root directory. Download it from the Firebase console after creating a project.
2. Configure Firebase Realtime Database rules to restrict access to sensitive location data. 
3. (Optional) Configure Cloud Messaging for two-way communication features, following Firebase documentation.

### Running the App

1. Connect an Android device to your development machine or start an emulator.
2. Run `flutter run` in the terminal to start the app.


### Deployment

1. Follow the instructions on the Firebase documentation for deploying Flutter apps to Android: [https://firebase.google.com/docs/flutter/setup](https://firebase.google.com/docs/flutter/setup)

### Contributing

Feel free to contribute to this project by creating pull requests with new features, bug fixes, or improvements.

### License

This project is licensed under the MIT License. See the LICENSE file for details.
