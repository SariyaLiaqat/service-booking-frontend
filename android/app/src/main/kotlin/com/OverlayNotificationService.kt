package com.example.servicebookingapp


import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.WindowManager
import android.widget.TextView
import android.widget.LinearLayout

class OverlayNotificationService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: LinearLayout? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra("title") ?: ""
        val body = intent?.getStringExtra("body") ?: ""

        if (windowManager == null) {
            windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

            val layoutParams = WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
            )

            layoutParams.gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            layoutParams.x = 0
            layoutParams.y = 100

            overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_notification, null) as LinearLayout

            val titleText = overlayView?.findViewById<TextView>(R.id.notificationTitle)
            val bodyText = overlayView?.findViewById<TextView>(R.id.notificationBody)

            titleText?.text = title
            bodyText?.text = body

            windowManager?.addView(overlayView, layoutParams)

            // Auto dismiss after 3 seconds
            overlayView?.postDelayed({
                removeOverlay()
            }, 3000)
        }

        return START_NOT_STICKY
    }

    private fun removeOverlay() {
        if (overlayView != null) {
            windowManager?.removeView(overlayView)
            overlayView = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        removeOverlay()
    }
}
