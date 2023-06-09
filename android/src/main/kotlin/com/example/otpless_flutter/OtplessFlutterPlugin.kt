package com.example.otpless_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import com.otpless.utils.Utility
import com.otpless.views.OtplessManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** OtplessFlutterPlugin */
class OtplessFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "otpless_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "openOtplessSdk" -> {
        result.success("")
        openOtpless()
      }

      "onSignComplete" -> {
        activity.runOnUiThread {
          OtplessManager.getInstance().onSignInCompleted()
        }
      }

      "hideFabButton" -> {
        activity.runOnUiThread {
          OtplessManager.getInstance().showFabButton(false)
        }
      }

      "isWhatsAppInstalled" -> {
        result.success(Utility.isWhatsAppInstalled(activity))
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    OtplessManager.getInstance().onActivityResult(requestCode, resultCode, data)
  }

  private fun openOtpless() {
    activity.runOnUiThread {
      OtplessManager.getInstance().startLegacy(activity) {
        channel.invokeMethod("otpless_callback_event", it.toJsonString())
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    return
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    return
  }

  override fun onDetachedFromActivity() {
    return
  }
}
