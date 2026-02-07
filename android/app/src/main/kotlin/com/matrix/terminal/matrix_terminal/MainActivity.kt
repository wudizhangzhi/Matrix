package com.matrix.terminal.matrix_terminal

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.provider.Settings
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CLIPBOARD_CHANNEL = "com.matrix.terminal/clipboard"
    private val ISLAND_CHANNEL = "com.matrix.terminal/super_island"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CLIPBOARD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getClipboardImage" -> {
                        result.success(getClipboardImageBytes())
                    }
                    "hasClipboardImage" -> {
                        result.success(hasClipboardImage())
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ISLAND_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSuperIslandVersion" -> {
                        result.success(getSuperIslandVersion())
                    }
                    "showIslandNotification" -> {
                        val channelId = call.argument<String>("channelId") ?: "connection_status"
                        val channelName = call.argument<String>("channelName") ?: "Connection Status"
                        val title = call.argument<String>("title") ?: ""
                        val body = call.argument<String>("body") ?: ""
                        val notifId = call.argument<Int>("notificationId") ?: 100
                        val focusParam = call.argument<String>("focusParam") ?: ""
                        val importance = call.argument<Int>("importance") ?: NotificationManager.IMPORTANCE_DEFAULT

                        showIslandNotification(
                            channelId, channelName, title, body,
                            notifId, focusParam, importance
                        )
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getSuperIslandVersion(): Int {
        return try {
            Settings.System.getInt(
                contentResolver,
                "notification_focus_protocol",
                0
            )
        } catch (e: Exception) {
            0
        }
    }

    private fun showIslandNotification(
        channelId: String,
        channelName: String,
        title: String,
        body: String,
        notificationId: Int,
        focusParam: String,
        importance: Int
    ) {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val channel = NotificationChannel(channelId, channelName, importance)
        nm.createNotificationChannel(channel)

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()

        // Add Super Island parameters
        if (focusParam.isNotEmpty()) {
            notification.extras.putString("miui.focus.param", focusParam)
        }

        nm.notify(notificationId, notification)
    }

    // --- Clipboard methods ---

    private fun hasClipboardImage(): Boolean {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = clipboard.primaryClip ?: return false
        if (clip.itemCount == 0) return false
        val item = clip.getItemAt(0)
        val uri = item.uri ?: return false
        val mimeType = contentResolver.getType(uri) ?: return false
        return mimeType.startsWith("image/")
    }

    private fun getClipboardImageBytes(): ByteArray? {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = clipboard.primaryClip ?: return null
        if (clip.itemCount == 0) return null

        val item = clip.getItemAt(0)
        val uri = item.uri ?: return null

        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream.close()

            if (bitmap == null) return null

            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            bitmap.recycle()
            outputStream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }
}
