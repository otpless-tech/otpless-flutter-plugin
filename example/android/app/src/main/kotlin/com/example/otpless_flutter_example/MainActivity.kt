package com.example.otpless_flutter_example

import com.otpless.otplessflutter.OtplessFlutterPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onBackPressed() {
        val plugin = flutterEngine?.plugins?.get(OtplessFlutterPlugin::class.java)
        if (plugin is OtplessFlutterPlugin) {
            if (plugin.onBackPressed()) return
        }
        super.onBackPressed()
    }
}
