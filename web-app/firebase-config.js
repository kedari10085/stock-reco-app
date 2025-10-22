// Firebase Configuration for StockReco Pro Web App
// GET THESE VALUES FROM: https://console.firebase.google.com/project/stock-reco-app/settings/general/web

const firebaseConfig = {
    // 1. API Key - Found in Firebase Console > Project Settings > General > Your apps > Web app > SDK setup and configuration
    apiKey: "YOUR_API_KEY_HERE", // Copy from "apiKey" field

    // 2. Auth Domain - Auto-generated, should be your-project.firebaseapp.com
    authDomain: "YOUR_PROJECT.firebaseapp.com", // Replace YOUR_PROJECT with your Firebase project ID

    // 3. Project ID - Found in Firebase Console > Project Settings > General > Project ID
    projectId: "YOUR_PROJECT_ID", // Copy from "Project ID" field (e.g., "stock-reco-app")

    // 4. Storage Bucket - Auto-generated, should be your-project.appspot.com
    storageBucket: "YOUR_PROJECT.appspot.com",

    // 5. Messaging Sender ID - Found in Firebase Console > Project Settings > Cloud Messaging > Sender ID
    messagingSenderId: "YOUR_SENDER_ID",

    // 6. App ID - Found in Firebase Console > Project Settings > General > Your apps > Web app > App ID
    appId: "1:YOUR_PROJECT_NUMBER:web:YOUR_WEB_APP_ID",

    // 7. Measurement ID (Optional) - Found in Firebase Console > Analytics > Measurement ID
    measurementId: "G-XXXXXXXXXX" // Optional: for Google Analytics
};

// IMPORTANT SETUP STEPS:
// 1. Go to Firebase Console: https://console.firebase.google.com/
// 2. Select your project "stock-reco-app"
// 3. Go to Project Settings > General > Your apps
// 4. If no web app exists, click "Add app" > Web app (</>)
// 5. Register your app and copy the config values above
// 6. Enable Authentication: Authentication > Sign-in method > Email/Password (Enable)
// 7. Enable Firestore: Firestore Database > Create database
// 8. Copy security rules from below and deploy them

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
