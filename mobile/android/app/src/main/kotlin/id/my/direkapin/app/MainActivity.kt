package id.my.direkapin.app

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.concurrent.thread

private const val GALLERY_CHANNEL = "direkapin/gallery"
private const val LINKS_CHANNEL = "direkapin/links"
private const val GALLERY_ALBUM = "Direkapin"
private const val STORAGE_PERMISSION_REQUEST = 1

class MainActivity : FlutterActivity() {
    private var waitingForPermission: ((Boolean) -> Unit)? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GALLERY_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "saveJpeg") return@setMethodCallHandler result.notImplemented()
                val bytes = call.argument<ByteArray>("bytes")!!
                val fileName = call.argument<String>("fileName")!!
                withStoragePermission { granted ->
                    if (granted) {
                        saveInBackground(bytes, fileName, result)
                    } else {
                        result.error("permission_denied", "Izin penyimpanan ditolak", null)
                    }
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LINKS_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "open") return@setMethodCallHandler result.notImplemented()
                try {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(call.argument<String>("url")!!)))
                    result.success(null)
                } catch (e: ActivityNotFoundException) {
                    result.error("no_browser", e.message, null)
                }
            }
    }

    /** Android 10 ke atas boleh menulis ke MediaStore tanpa izin. */
    private fun withStoragePermission(onResult: (Boolean) -> Unit) {
        val permission = Manifest.permission.WRITE_EXTERNAL_STORAGE
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q ||
            checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
        ) {
            return onResult(true)
        }
        waitingForPermission = onResult
        requestPermissions(arrayOf(permission), STORAGE_PERMISSION_REQUEST)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != STORAGE_PERMISSION_REQUEST) return
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        waitingForPermission?.invoke(granted)
        waitingForPermission = null
    }

    private fun saveInBackground(bytes: ByteArray, fileName: String, result: MethodChannel.Result) {
        thread {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    saveToMediaStore(bytes, fileName)
                } else {
                    saveToPublicFolder(bytes, fileName)
                }
                runOnUiThread { result.success(null) }
            } catch (e: Exception) {
                runOnUiThread { result.error("save_failed", e.message, null) }
            }
        }
    }

    private fun saveToMediaStore(bytes: ByteArray, fileName: String) {
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
            put(MediaStore.Images.Media.RELATIVE_PATH, "${Environment.DIRECTORY_PICTURES}/$GALLERY_ALBUM")
            // Galeri baru melihat foto setelah filenya utuh.
            put(MediaStore.Images.Media.IS_PENDING, 1)
        }
        val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("MediaStore menolak file baru")
        try {
            contentResolver.openOutputStream(uri)!!.use { it.write(bytes) }
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            contentResolver.update(uri, values, null, null)
        } catch (e: Exception) {
            contentResolver.delete(uri, null, null)
            throw e
        }
    }

    @Suppress("DEPRECATION") // Android 8-9 belum punya RELATIVE_PATH.
    private fun saveToPublicFolder(bytes: ByteArray, fileName: String) {
        val pictures = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
        val folder = File(pictures, GALLERY_ALBUM).apply { mkdirs() }
        val file = File(folder, fileName).apply { writeBytes(bytes) }
        MediaScannerConnection.scanFile(this, arrayOf(file.path), arrayOf("image/jpeg"), null)
    }
}
