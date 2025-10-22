// Firebase Configuration for StockReco Pro Web App
// Project: liftweb-17a0d - https://console.firebase.google.com/project/liftweb-17a0d/overview

const firebaseConfig = {
    // API Key for liftweb-17a0d project
    apiKey: "AIzaSyB3HsJn-1WB52I5SjbuiomvAIWKgjq8uwA",

    // Auth Domain for liftweb-17a0d project
    authDomain: "liftweb-17a0d.firebaseapp.com",

    // Project ID
    projectId: "liftweb-17a0d",

    // Storage Bucket
    storageBucket: "liftweb-17a0d.firebasestorage.app",

    // Messaging Sender ID
    messagingSenderId: "687812437823",

    // App ID
    appId: "1:687812437823:web:06ef3ad0c811e32aa9d58a",

    // Measurement ID for Google Analytics
    measurementId: "G-B5S931DP6H"
};

// Firebase project is ready! Make sure to:
// 1. Enable Authentication: Authentication > Sign-in method > Email/Password (Enable)
// 2. Enable Firestore: Firestore Database > Create database
// 3. Deploy the security rules below

// Firestore Security Rules for your Firebase project:
/*
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Allow authenticated users to create and join video calls
    match /calls/{callId} {
      allow read, write: if request.auth != null;

      // Allow access to call candidates (ICE candidates for WebRTC)
      match /candidates/{candidateId} {
        allow read, write: if request.auth != null;
      }
    }

    // Stock recommendations - read access for authenticated users
    match /recommendations/{recId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        (request.auth.token.admin == true || request.auth.uid in resource.data.authorized_users);
    }

    // User subscriptions and payments
    match /subscriptions/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Q&A system
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == resource.data.user_id;
      allow update: if request.auth != null &&
        (request.auth.token.admin == true || request.auth.uid == resource.data.user_id);
    }
  }
}
*/

// Export configuration
if (typeof module !== 'undefined' && module.exports) {
    module.exports = firebaseConfig;
}
