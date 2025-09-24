importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAfB6rM7DsbiiwoWP0HsKp7rqjvo9dJQQM",
        authDomain: "serviceproviderapp-63814.firebaseapp.com",
        projectId: "serviceproviderapp-63814",
        storageBucket: "serviceproviderapp-63814.firebasestorage.app",
        messagingSenderId: "581489219756",
        appId: "1:581489219756:web:d1ca68b15ebecc73abe709",
        measurementId: "G-4K5N8PMP8D",
});

const messaging = firebase.messaging();
