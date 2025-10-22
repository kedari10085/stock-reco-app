// Firebase Configuration for StockReco Pro Web App
// Replace these values with your actual Firebase project configuration

const firebaseConfig = {
    // Get these values from Firebase Console > Project Settings > General > Your apps > Web app
    apiKey: "AIzaSyBkZGQGPm8lRvKjKvKjKvKjKvKjKvKjKvK", // Replace with your actual API key
    authDomain: "stock-reco-app.firebaseapp.com", // Replace with your domain
    projectId: "stock-reco-app", // Replace with your project ID
    storageBucket: "stock-reco-app.appspot.com",
    messagingSenderId: "123456789012",
    appId: "1:123456789012:web:abcdef123456789012345",
    measurementId: "G-XXXXXXXXXX" // Optional: for Google Analytics
};

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
