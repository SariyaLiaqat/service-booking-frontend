// // ✅ Service Provider Status Feature – Todo / Checklist
// // 1️⃣ Database Setup

// //  provider_statuses table me provider_id FK correctly providers(user_id) se linked hai

// //  media_url, status_type, created_at, expires_at, is_active fields exist karte hain

// //  expires_at automatically 24h set ho (backend ya DB trigger)

// // 2️⃣ Backend: Upload Status API

// //  API route /statuses/upload create karein

// //  Only SP can upload → check current_user.role == 'provider'

// //  Accept media_url and status_type

// //  Set created_at = NOW()

// //  Set expires_at = NOW() + INTERVAL '24 HOURS'

// //  Insert into provider_statuses

// // 3️⃣ Backend: Fetch Status API

// //  API route /statuses/fetch create karein

// //  Only users with SP connection can fetch → join with tasks or conversations

// // Example query:

// // SELECT ps.*
// // FROM provider_statuses ps
// // JOIN tasks t ON t.provider_id = ps.provider_id
// // WHERE t.user_id = :current_user_id
// //   AND ps.is_active = TRUE
// //   AND ps.created_at > NOW() - INTERVAL '24 HOURS'
// // ORDER BY ps.created_at DESC;


// //  Return SP info + media_url + expires_at

// // 4️⃣ Backend: Auto Expire Status

// //  Cron job or DB trigger for auto-deactivate expired statuses:

// // UPDATE provider_statuses
// // SET is_active = FALSE
// // WHERE expires_at < NOW();

// // 5️⃣ Frontend: Status Display

// //  Status icon (like WhatsApp) in user home/chat screen

// //  Fetch statuses via /statuses/fetch API

// //  Show only is_active = TRUE statuses

// //  Auto refresh or real-time via Socket.IO optional

// //  Clicking status → open modal to see image/video + timestamp

// // 6️⃣ Frontend: Upload Status (SP Only)

// //  Upload button visible only if current_user.role == 'provider'

// //  Select image/video from gallery/camera

// //  Send to backend /statuses/upload

// //  Update local status list (optimistic UI)

// // 7️⃣ Optional Enhancements

// //  Show “viewed by X users” (if you want WhatsApp-like)

// //  Add typing/seen indicators

// //  Swipe to view next status

// //  Highlight new statuses for 2-3 seconds

// // Aap ye checklist ek page pe tick kar ke follow kar sakti ho.












// 🔒 1. Input Validations (Backend side)

// Abhi basic if(!name || !email...) type validations hain, lekin production me:

// Phone → Regex enforce karo (^[0-9]{10,15}$).

// Gov ID → CNIC/Passport ke liye regex (Pakistan ke CNIC ka xxxxx-xxxxxxx-x).

// Links (social/portfolio) → Regex check karo, sirf http:// / https:// se valid URL accept karo.

// Password → Abhi sirf hash hai, lekin complexity check missing hai (min 8 chars, at least 1 uppercase, 1 number, 1 special char).

// 👉 Suggestion: ek validators.js helper banao aur har route pe use karo, e.g.

// if(!/^[0-9]{10,15}$/.test(phone)) return res.status(400).json({ message: "Invalid phone number" });

// 🔑 2. Security Improvements

// Password Hashing – sahi hai (bcrypt use kar rahe ho). ✅

// JWT Expiry – abhi 1h hai, production me refresh token mechanism bhi zaroori hota hai.

// Error Messages – abhi directly "Invalid credentials" return kar rahe ho (theek hai) but avoid exposing DB/stacktrace in responses.

// res.status(500).json({ message: 'Server error' }); // no err.message in production


// Logging ke liye winston ya pino use karo.

// 📧 3. Email Verification

// Nodemailer sahi use ho raha hai ✅

// Production me Gmail service limit hoti hai → suggest: SMTP provider (SendGrid, Mailgun, Amazon SES).

// Verification token expiry add karo (e.g. 24h), warna link kabhi expire nahi hoga.

// 🖼 4. File Uploads (Base64 images)

// Abhi images directly uploads/ folder me save ho rahe hain.

// Production me suggest:

// Upload to cloud storage (AWS S3, Cloudinary, Firebase).

// Agar local rakhte ho to at least file size limit lagao (multer middleware).

// 🗂 5. Database Improvements

// email aur username unique constraint ho.

// CNIC / gov_id bhi unique ho agar required hai.

// skills, languages, social_links abhi {} string/array mixed aa rahe hain → store as JSONB in Postgres (cleaner queries).

// ⚡ 6. Error Handling

// Abhi har catch me console.error + res.status(500)... hai.

// Suggestion: Centralized error handler middleware banao.

// Timeout aur connection error ke liye separate messages bhejo (same jaise frontend me professional error handling chahiye).

// 🎯 7. Other Best Practices

// dotenv use karke config values (email, jwt secret, db) manage ho rahe hain (good ✅).

// Add rate limiting on signup/login (prevent brute force).

// Add CORS middleware properly configured.

// Add helmet for basic security headers.

// 🔍 Specific Changes Required

// Add regex + sanitization for:

// phone, gov_id, email, links, password.

// Add expiry for verification token (e.g. DB column verification_expires).

// Replace Gmail with SMTP service in production.

// Use JSONB arrays for skills, languages, social_links, etc.

// Implement refresh tokens along with JWT.

// Improve error handling → don’t expose raw err.message in API responses.

// File uploads ko Cloud storage ya kam az kam multer size limits ke sath protect karo.

// 👉 My lord, ye saare points karne ke baad aapki auth.js production-level secure ho jayegi.

// Kya aap chahte ho ke main step 1 (validators for phone, CNIC, links, password) ka exact code likh kar signup route me integrate karke dikhau?