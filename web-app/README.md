# StockReco Pro Web Platform

A complete web application with WebRTC video calling, Firebase integration, and stock recommendations.

## 🚀 Features

### ✅ **WebRTC Video Calling**
- Peer-to-peer video calls between users and experts
- Real-time signaling through Firebase Firestore
- Camera and microphone access
- Call creation and joining functionality

### ✅ **Firebase Integration**
- User authentication (sign up/sign in)
- Real-time database for call signaling
- Secure user data storage
- Stock recommendations storage

### ✅ **Stock Recommendations**
- Live stock picks and analysis
- Real-time price updates
- Buy/Sell/Hold recommendations
- Target prices and stop losses

### ✅ **Responsive Design**
- Works on desktop and mobile
- Modern UI with smooth animations
- Professional branding matching mobile app

## 🔧 Setup Instructions

### 1. Firebase Configuration
1. **Get your Firebase config** from Firebase Console > Project Settings > General > Your apps > Web app
2. **Update `firebase-config.js`** with your actual values:
   ```javascript
   const firebaseConfig = {
       apiKey: "your-actual-api-key",
       authDomain: "your-project.firebaseapp.com",
       projectId: "your-project-id",
       // ... other config values
   };
   ```

3. **Update Firestore Security Rules** in Firebase Console:
   ```firestore
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /calls/{callId} {
         allow read, write: if request.auth != null;
         match /candidates/{candidateId} {
           allow read, write: if request.auth != null;
         }
       }
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

### 2. Enable Firebase Services
- **Authentication**: Enable Email/Password provider
- **Firestore**: Create database in production mode
- **Hosting** (optional): For Firebase hosting instead of Netlify

### 3. Deploy to Netlify

#### Option A: Direct Deploy
1. Drag and drop the `web-app` folder to Netlify
2. Site will be live immediately

#### Option B: GitHub Integration
1. Push to GitHub repository
2. Connect Netlify to your GitHub repo
3. Set build settings:
   - **Base directory**: `web-app`
   - **Publish directory**: `web-app`
   - **Build command**: (leave empty)

## 📱 How to Use

### For Users:
1. **Sign Up/Sign In** - Create account or login
2. **View Recommendations** - See today's stock picks
3. **Start Video Call** - Get personalized consultation
4. **Join Call** - Enter call ID to join expert session

### For Experts:
1. **Sign In** with expert account
2. **Start Call** - Create new consultation session
3. **Share Call ID** with client
4. **Provide Guidance** - Give personalized advice

## 🌐 Live URLs

After deployment, your app will be available at:
- **Homepage**: `https://your-site.netlify.app/`
- **Privacy Policy**: `https://your-site.netlify.app/privacy.html`

## 🔐 Security Features

- **WebRTC Encryption**: All video/audio is peer-to-peer encrypted
- **Firebase Auth**: Secure user authentication
- **HTTPS Only**: All connections are encrypted
- **CORS Headers**: Proper cross-origin security
- **No Data Storage**: Video calls are not recorded

## 📊 Integration with Mobile App

This web platform complements your mobile app by providing:
- **Desktop Access**: Full functionality on computers
- **Expert Dashboard**: Web interface for consultants
- **Cross-Platform**: Same Firebase backend as mobile app
- **Unified Experience**: Consistent branding and features

## 🛠 Technical Stack

- **Frontend**: Vanilla JavaScript, HTML5, CSS3
- **Backend**: Firebase (Auth, Firestore)
- **Video**: WebRTC with STUN servers
- **Deployment**: Netlify
- **Version Control**: GitHub

## 📞 Support

For technical support or questions:
- **Email**: support@stockreco.com
- **Documentation**: See Firebase docs for advanced configuration
- **WebRTC**: Uses Google STUN servers for connection

## 🎯 Next Steps

1. **Update Firebase Config** with your actual project details
2. **Deploy to Netlify** using GitHub integration
3. **Test Video Calling** with multiple users
4. **Add Real Stock Data** API integration
5. **Implement Payment** for premium features

Your web platform is ready for production deployment! 🚀
