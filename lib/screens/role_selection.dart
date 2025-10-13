// Stepwise Changes / Improvements Needed

// Caption Upload Fix

// Right now, captions aren’t saving properly.

// DB is missing caption insertion when uploading.

// Also, status.uploaderName shows "Unknown" — need to fix this to fetch from DB correctly.

// SP-only Upload Button

// Already partly done (if (widget.isProvider)), but check logic:

// Only Service Providers see the Add button.

// Users should only view, not upload.

// Vertical Reel PageView

// Already set PageView.builder with scrollDirection: Axis.vertical.

// Enhance it with full-screen display, auto-fit video/image like Instagram.

// Optional: Add swipe animation/indicator if needed.

// Message/Chat Button

// Add a button linked to the Service Provider’s chat.

// Ensure the button appears only for users, not providers on their own reels.

// Like / Comment Functionality

// Right now, placeholder exists.

// Need backend + UI integration:

// Like: toggle + count

// Comment: open a small modal/input area

// Optional: Persist likes/comments in DB.

// HLS Video Support

// Already using VideoStatusViewer, need to make sure .m3u8 videos load smoothly.

// Ensure auto-play, loop, mute/unmute works like Instagram Reels.

// Uploader Name / Avatar

// Currently shows "Unknown" if null.

// Fetch uploader name + avatar correctly from backend when displaying public reels.

// Progress & Upload Feedback

// Already partially implemented (uploadProgress).

// Improve UI: overlay spinner with percentage + completion message.

// Public/Private Option

// Currently removed, but in future may want private stories.

// For now, make sure all uploads are public.

// Error Handling

// Image/video loading errors should show retry / error icon.

// Also for upload failures, provide toast/snackbar messages.

// Polish Reel UI

// Add subtle gradient overlay at bottom for caption.

// Possibly like/comment/share buttons overlayed like Instagram.

// 💡 Approach: