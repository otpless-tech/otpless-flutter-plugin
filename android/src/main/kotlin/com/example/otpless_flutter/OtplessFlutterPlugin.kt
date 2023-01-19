package com.example.otpless_flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class statusMessages{
  var WHATSAPP_LINK_CREATE_ERROR = "Unable to create WhatsApp Data Link"
  var WHATSAPP_NOT_FOUND = "Unable to open WhatsApp"
  var WHATSAPP_URL_NOT_FOUND = "WhatsApp URL not found"
  var WHATSAPP_URL_FOUND = "Valid URL Scheme"
  var URL_TOKEN = "token"
  var URL_TOKEN_FOUND = "Deeplink token found"
  var URL_TOKEN_NOT_FOUND = "Deeplink token not found"
  var INVALID_URL = "Invalid url"
}

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
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }else if(call.method=="openWhatsapp"){
      initiateOtplessFlow(call.argument("uri"),result)
    } else {
      return
    }
  }

  fun isAppInstalled(packageName: String?): Boolean {
    return try {
      context.packageManager.getApplicationInfo(packageName!!, 0).enabled
    } catch (e: PackageManager.NameNotFoundException) {
      Log.d("plygin",e.toString())
      false
    }
  }

  private fun initiateOtplessFlow(intentUri:String?,result: Result) {
    if(isAppInstalled("com.whatsapp") || isAppInstalled("com.whatsapp.w4b")){
      val openURL = Intent(android.content.Intent.ACTION_VIEW)
      openURL.data = Uri.parse(intentUri)
      activity.startActivity(openURL)
      return
    }
    result.success("581-Unable to open WhatsApp")
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
