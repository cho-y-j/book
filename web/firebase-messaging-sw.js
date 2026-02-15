importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCfBIL70FT9xoa2bAbuexT5_TVi11uAxkU',
  appId: '1:447069044010:web:acad53d06b8bcbbb343253',
  messagingSenderId: '447069044010',
  projectId: 'book-bridge-2026',
  authDomain: 'book-bridge-2026.firebaseapp.com',
  storageBucket: 'book-bridge-2026.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  const notification = message.notification;
  if (!notification) return;
  return self.registration.showNotification(notification.title, {
    body: notification.body,
    icon: '/icons/Icon-192.png',
  });
});
