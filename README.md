# Service Advertising Mobile App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

<p>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img alt="Dart" src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img alt="Firebase" src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
</p>

A mobile application built with **Flutter**, using **Firebase** as the backend, to connect customers with service providers. Customers can easily find, view, bookmark, chat with, and rate service providers. Any registered user can also become a service provider with a few simple steps.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)

## Features

- **Browse Services:** Users can view a wide range of available services.
- **Search Services:** Filter services by category or location.
- **Service Details:** View shop details, descriptions, service types, images, and contact info.
- **Bookmark Services:** Save favorite providers for quick access.
- **Real-time Chat:** In-app chat system to communicate directly with providers.
- **Ratings and Reviews:** Rate and review service providers after completing a job.
- **User Authentication:** Secure sign-up/sign-in with Firebase Auth.
- **Provider Onboarding:** Registered users can create shop profiles and offer services.
- **Shop Management:** Update shop page, services list, and images with ease.

## Tech Stack

- **Flutter:** Cross-platform mobile app development framework.
- **Dart:** Programming language used with Flutter.
- **Firebase:**
  - **Authentication:** Secure login and registration.
  - **Cloud Firestore:** Real-time NoSQL database.
  - **Firebase Storage:** Store user-uploaded images.
- **Cloudinary:** Image hosting and optimization.

## Installation

1. **Prerequisites:**
   - [Flutter SDK](https://flutter.dev/docs/get-started/install)
   - Dart (comes with Flutter)
   - Android Studio or VS Code with Flutter plugins
   - Firebase project (with Authentication, Firestore, and Storage enabled)
   - Optional: Cloudinary account for image uploads

2. **Clone the repository:**

```bash
git clone https://github.com/dananjaya2002/flutter-service-app.git
cd flutter-service-app
