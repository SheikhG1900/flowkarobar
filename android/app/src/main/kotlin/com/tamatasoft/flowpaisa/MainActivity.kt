package com.tamatasoft.flowpaisa

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tamatasoft.flowpaisa/native_share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareFile") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    shareFile(filePath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "File path is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun shareFile(filePath: String, result: MethodChannel.Result) {
        try {
            val sourceFile = File(filePath)
            
            if (!sourceFile.exists()) {
                result.error("FILE_NOT_FOUND", "File does not exist: $filePath", null)
                return
            }

            // Detect MIME type based on file extension
            val mimeType = getMimeType(filePath)
            val shareTitle = getShareTitle(mimeType)

            // Use FileProvider for sharing (works for all Android versions)
            // FileProvider creates a content:// URI that can be shared
            val fileUri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                sourceFile
            )
            
            // Create share intent with proper permissions
            val shareIntent = Intent().apply {
                action = Intent.ACTION_SEND
                type = mimeType
                putExtra(Intent.EXTRA_STREAM, fileUri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            // Create chooser and grant permissions to all potential target apps
            val chooserIntent = Intent.createChooser(shareIntent, shareTitle).apply {
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            
            // Grant permissions to all apps that can handle this intent
            val resInfoList = packageManager.queryIntentActivities(shareIntent, 0)
            for (resolveInfo in resInfoList) {
                val packageName = resolveInfo.activityInfo.packageName
                grantUriPermission(packageName, fileUri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            
            startActivity(chooserIntent)
            result.success(true)
        } catch (e: Exception) {
            result.error("SHARE_FAILED", "Failed to share file: ${e.message}", e.toString())
        }
    }

    private fun getMimeType(filePath: String): String {
        return when (filePath.substringAfterLast('.', "").lowercase()) {
            "pdf" -> "application/pdf"
            "csv" -> "text/csv"
            else -> "application/octet-stream"
        }
    }

    private fun getShareTitle(mimeType: String): String {
        return when (mimeType) {
            "application/pdf" -> "Share PDF File"
            "text/csv" -> "Share CSV File"
            else -> "Share File"
        }
    }

    private fun insertFileToDownloads(file: File, mimeType: String): Uri? {
        return try {
            val fileName = file.name
            val contentValues = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                put(MediaStore.Downloads.MIME_TYPE, mimeType)
                put(MediaStore.Downloads.RELATIVE_PATH, "Download")
            }
            
            val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            if (uri != null) {
                // Copy file content to the MediaStore URI
                contentResolver.openOutputStream(uri)?.use { outputStream ->
                    FileInputStream(file).use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
                uri
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }
}
