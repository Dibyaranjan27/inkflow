package com.dibya.inkflow

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.dibya.inkflow/config"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getGoogleBooksApiKey") {
                val apiKey = try {
                    val resId = resources.getIdentifier("google_books_api_key", "string", packageName)
                    if (resId != 0) getString(resId) else ""
                } catch (e: Exception) {
                    ""
                }
                result.success(apiKey)
            } else {
                result.notImplemented()
            }
        }
    }
}
