package com.example.multifileopener

import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "multifileopener/native"
    private val tag = "MultiFileOpener"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "listPdfApps" -> result.success(listPdfApps())
                    "openInApp" -> {
                        val path = call.argument<String>("filePath")
                        val pkg = call.argument<String>("packageName")
                        val mode = call.argument<String>("mode") ?: "open"
                        if (path == null || pkg == null) {
                            result.error("ARG", "filePath and packageName required", null)
                        } else {
                            result.success(openInApp(path, pkg, mode))
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** Apps that can VIEW or RECEIVE a PDF, de-duplicated by package. */
    private fun listPdfApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val viewIntent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(Uri.parse("content://com.example.multifileopener/dummy.pdf"), "application/pdf")
        }
        val sendIntent = Intent(Intent.ACTION_SEND).apply { type = "application/pdf" }

        val flags = PackageManager.MATCH_DEFAULT_ONLY
        val byPackage = LinkedHashMap<String, ResolveInfo>()
        for (ri in pm.queryIntentActivities(viewIntent, flags)) {
            val p = ri.activityInfo?.packageName ?: continue
            if (!byPackage.containsKey(p)) byPackage[p] = ri
        }
        for (ri in pm.queryIntentActivities(sendIntent, flags)) {
            val p = ri.activityInfo?.packageName ?: continue
            if (!byPackage.containsKey(p)) byPackage[p] = ri
        }
        byPackage.remove(packageName) // never list ourselves

        return byPackage.values.map { ri ->
            mapOf(
                "label" to ri.loadLabel(pm).toString(),
                "packageName" to ri.activityInfo.packageName,
                "icon" to drawableToPng(ri.loadIcon(pm))
            )
        }
    }

    /** Hands the file at [path] to [pkg] via VIEW ('open') or SEND ('share'). */
    private fun openInApp(path: String, pkg: String, mode: String): Boolean {
        return try {
            val file = File(path)
            if (!file.exists()) {
                Log.e(tag, "openInApp: file missing: $path")
                return false
            }
            val uri: Uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            val intent = if (mode == "share") {
                Intent(Intent.ACTION_SEND).apply {
                    type = "application/pdf"
                    putExtra(Intent.EXTRA_STREAM, uri)
                }
            } else {
                Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "application/pdf")
                }
            }
            intent.setPackage(pkg)
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            // Verify the target can actually handle this file/mode. Catches an
            // uninstalled app or "share" to an app that only opens (VIEW).
            if (intent.resolveActivity(packageManager) == null) {
                Log.e(tag, "openInApp: no activity in $pkg for mode=$mode")
                return false
            }
            // Explicit grant as a belt-and-suspenders measure for stricter apps.
            grantUriPermission(pkg, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            startActivity(intent)
            true
        } catch (e: Exception) {
            Log.e(tag, "openInApp failed: path=$path pkg=$pkg mode=$mode", e)
            false
        }
    }

    private fun drawableToPng(drawable: Drawable?): ByteArray? {
        if (drawable == null) return null
        return try {
            val bmp: Bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
                drawable.bitmap
            } else {
                val w = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
                val h = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
                val created = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(created)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                created
            }
            val stream = ByteArrayOutputStream()
            bmp.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            Log.w(tag, "drawableToPng failed", e)
            null
        }
    }
}
