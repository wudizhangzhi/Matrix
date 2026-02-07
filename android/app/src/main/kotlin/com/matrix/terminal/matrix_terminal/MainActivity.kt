package com.matrix.terminal.matrix_terminal

import android.content.ClipboardManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.matrix.terminal/clipboard"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getClipboardImage" -> {
                        val imageBytes = getClipboardImageBytes()
                        result.success(imageBytes)
                    }
                    "hasClipboardImage" -> {
                        result.success(hasClipboardImage())
                    }
                    else -> result.notImplemented()
                }
            }
    }

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
