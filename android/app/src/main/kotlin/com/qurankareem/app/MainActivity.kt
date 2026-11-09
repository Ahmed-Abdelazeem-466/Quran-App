package com.qurankareem.app

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val pdfWorker = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var renderer: PdfRenderer? = null
    private var rendererAsset: String? = null
    private val allowedAssets = setOf(
        "assets/tafsir/tafsir_muyassar.pdf",
        "assets/tafsir/tafsir_ibn_kathir.pdf"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.qurankareem.app/tafsir_pdf")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "renderPage" -> {
                        val asset = call.argument<String>("asset")
                        val index = call.argument<Int>("page")
                        val width = (call.argument<Int>("width") ?: 1800).coerceIn(600, 2200)
                        if (asset !in allowedAssets || index == null || index < 0) {
                            result.error("INVALID_PAGE", "Invalid bundled Tafsir page", null)
                        } else {
                            pdfWorker.execute {
                                try {
                                    val document = documentFor(asset!!)
                                    require(index < document.pageCount) { "Page exceeds document bounds" }
                                    val output = document.openPage(index).use { page ->
                                        val height = (width.toDouble() * page.height / page.width).toInt().coerceAtLeast(1)
                                        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                                        try {
                                            bitmap.eraseColor(Color.WHITE)
                                            page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                                            val bytes = ByteArrayOutputStream().use { stream ->
                                                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                                                stream.toByteArray()
                                            }
                                            mapOf("bytes" to bytes, "width" to width, "height" to height, "pageCount" to document.pageCount)
                                        } finally {
                                            bitmap.recycle()
                                        }
                                    }
                                    mainHandler.post { result.success(output) }
                                } catch (error: Exception) {
                                    mainHandler.post { result.error("PDF_RENDER_FAILED", error.message, null) }
                                }
                            }
                        }
                    }
                    "release" -> pdfWorker.execute {
                        closeDocument()
                        mainHandler.post { result.success(null) }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // A seekable private cache copy is required by PdfRenderer. Stream the
    // bundled asset rather than loading a 70 MB file into Flutter/UI memory.
    private fun documentFor(asset: String): PdfRenderer {
        if (rendererAsset == asset && renderer != null) return renderer!!
        closeDocument()
        val directory = File(cacheDir, "tafsir_pdf").apply { mkdirs() }
        val file = File(directory, asset.substringAfterLast('/'))
        if (!file.exists()) {
            val temporary = File(directory, "${file.name}.tmp")
            try {
                assets.open("flutter_assets/$asset").use { input ->
                    temporary.outputStream().use { output -> input.copyTo(output) }
                }
                check(temporary.renameTo(file)) { "Cannot prepare Tafsir PDF" }
            } finally {
                temporary.delete()
            }
        }
        val descriptor = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        try {
            renderer = PdfRenderer(descriptor)
            rendererAsset = asset
        } catch (error: Exception) {
            descriptor.close()
            throw error
        }
        return renderer!!
    }

    private fun closeDocument() {
        renderer?.close()
        renderer = null
        rendererAsset = null
    }

    override fun onDestroy() {
        pdfWorker.execute { closeDocument() }
        pdfWorker.shutdown()
        super.onDestroy()
    }
}
