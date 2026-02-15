const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

/**
 * 새 책이 등록되면 위시리스트 알림 확인 후 매칭 유저에게 푸시 전송
 */
exports.onBookCreated = onDocumentCreated("books/{bookId}", async (event) => {
  const snap = event.data;
  if (!snap) return;

  const book = snap.data();
  const bookId = event.params.bookId;

  // available 상태인 책만 처리
  if (book.status !== "available") return;

  const bookInfoId = book.bookInfoId;
  if (!bookInfoId) return;

  // 알림 활성화된 위시리스트 조회
  const wishlistSnap = await db
    .collection("wishlists")
    .where("bookInfoId", "==", bookInfoId)
    .where("alertEnabled", "==", true)
    .get();

  if (wishlistSnap.empty) return;

  const promises = [];

  for (const wishDoc of wishlistSnap.docs) {
    const wish = wishDoc.data();

    // 본인이 등록한 책은 알림 안 함
    if (wish.userUid === book.ownerUid) continue;

    // 상태 조건 필터
    if (
      wish.preferredConditions &&
      wish.preferredConditions.length > 0 &&
      !wish.preferredConditions.includes(book.condition)
    ) {
      continue;
    }

    // 거래 유형 필터
    if (
      wish.preferredListingTypes &&
      wish.preferredListingTypes.length > 0
    ) {
      const bookType = book.listingType || "exchange";
      if (
        !wish.preferredListingTypes.includes(bookType) &&
        !wish.preferredListingTypes.includes("both") &&
        bookType !== "both"
      ) {
        continue;
      }
    }

    // 매칭! 알림 생성 + FCM 전송
    const targetUid = wish.userUid;
    const conditionLabel = {
      best: "최상",
      good: "상",
      fair: "중",
      poor: "하",
    }[book.condition] || book.condition;

    const listingLabel = {
      exchange: "교환",
      sale: "판매",
      both: "교환/판매",
    }[book.listingType] || book.listingType;

    const notificationData = {
      targetUid,
      type: "wishlist_match",
      title: "원하시던 책이 등록되었어요!",
      body: `"${book.title}" (${conditionLabel}, ${listingLabel}) - 지금 바로 확인해보세요`,
      data: { type: "wishlist_match", id: bookId, bookInfoId },
      isRead: false,
      createdAt: new Date(),
    };

    // Firestore 알림 문서 생성
    promises.push(db.collection("notifications").add(notificationData));

    // isNotified 플래그 업데이트
    promises.push(wishDoc.ref.update({ isNotified: true }));

    // FCM 푸시 전송
    promises.push(
      (async () => {
        try {
          const userDoc = await db.collection("users").doc(targetUid).get();
          const fcmToken = userDoc.data()?.fcmToken;
          if (!fcmToken) return;

          await messaging.send({
            token: fcmToken,
            notification: {
              title: notificationData.title,
              body: notificationData.body,
            },
            data: {
              type: "wishlist_match",
              id: bookId,
            },
            android: {
              priority: "high",
            },
            apns: {
              payload: {
                aps: { sound: "default", badge: 1 },
              },
            },
          });
        } catch (err) {
          console.error(`FCM send failed for ${targetUid}:`, err.message);
        }
      })()
    );
  }

  await Promise.all(promises);
});
