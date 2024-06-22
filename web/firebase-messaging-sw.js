importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js');

// Cấu hình Firebase
firebase.initializeApp({
  apiKey: "AIzaSyAUG9ufw5az3TJDkJD-fb0jmMPgdoaumos",
  projectId: "swd-quannhaurestaurant-se2024",
  storageBucket: "swd-quannhaurestaurant-se2024.appspot.com",
  messagingSenderId: "306142775890",
  appId: "1:306142775890:android:ed6beee59b6af49eafed8b"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = 'Background Message Title';
  const notificationOptions = {
    body: 'Background Message body.',
    icon: '/firebase-logo.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
