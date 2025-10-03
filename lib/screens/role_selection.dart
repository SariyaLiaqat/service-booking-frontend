// // Smooth Video Playback Plan (WhatsApp style)
// // Step 1: Video Processing / Compression on Server

// // Video upload hone ke baad turant compressed version ready ho.

// // Optionally, HLS (m3u8) format me convert karo taake streaming smooth ho.

// // FFmpeg commands:

// // Simple mp4 compression:

// // ffmpeg -i input.mp4 -vcodec libx264 -crf 23 -preset fast -acodec aac output.mp4


// // HLS (chunked streaming):

// // ffmpeg -i input.mp4 -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls output.m3u8


// // Save compressed file path / m3u8 URL in database.

// // Step 2: Serve Video via Proper URL

// // Backend should return compressed video URL or HLS playlist URL immediately.

// // Ensure CORS enabled for video URL.

// // If HLS, return .m3u8 file URL, not .mp4.

// // Step 3: Flutter Frontend Video Player Update

// // Use video_player + chewie with network URL (compressed mp4 or HLS).

// // For HLS, video_player automatically streams chunks → playback starts instantly.

// // Optional: Preload / caching for smoother playback.

// // Step 4: Test Playback

// // Upload a video → immediately fetch URL → verify playback starts without delay.

// // Test multiple video durations (7 sec, 1 min, 3 min).

// // Ensure audio/video sync and proper looping.

// // Step 5: Optimize (Optional)

// // Adaptive bitrate for larger videos.

// // Thumbnails for preview in status list.

// // Background download for offline playback.

// // 💡 Summary:
// // 1️⃣ Compress / HLS conversion on server
// // 2️⃣ Serve proper video URL
// // 3️⃣ Flutter player update for network/HLS playback
// // 4️⃣ Test immediately
// // 5️⃣ Optional optimizations



// Step 1: Backend folder structure

// Create folders if not exist:

// uploads/
//    original/    → raw uploaded files
//    compressed/  → compressed mp4 files
//    hls/         → HLS chunks


// Ye har upload ke liye automatically check & create karna chahiye.

// Step 2: Receive upload (API)

// Jab koi provider video upload kare → save to uploads/original/{filename}.

// Example: uploads/original/status_12345.mp4

// Step 3: Compress video (FFmpeg)

// Backend me automatically FFmpeg command run karo after upload:

// ffmpeg -i uploads/original/status_12345.mp4 -vcodec libx264 -crf 23 -preset fast -acodec aac uploads/compressed/status_12345.mp4


// Compressed version size chhoti → fast loading.

// Step 4: Optional HLS for chunked streaming
// ffmpeg -i uploads/compressed/status_12345.mp4 -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls uploads/hls/status_12345.m3u8


// Ye frontend me streaming ke liye use hoga.

// Step 5: Save paths in DB

// Original: uploads/original/status_12345.mp4

// Compressed: uploads/compressed/status_12345.mp4

// HLS playlist: uploads/hls/status_12345.m3u8

// Frontend use karega compressed ya HLS URL.

// ✅ Iska benefit:

// Har provider ka video automatically compress aur HLS me convert ho jaye.

// Frontend smooth playback: short chunks → instant play.

// WhatsApp jaise experience possible.

// Agar chaho, mai tumhe exact No