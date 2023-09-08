package com.otpless.otplessflutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.otpless.utils.Utility
import com.otpless.main.OtplessManager
import com.otpless.main.OtplessView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject


/** OtplessFlutterPlugin */
class OtplessFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity
  private lateinit var otplessView: OtplessView

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "otpless_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    // safe check
    if (!this::otplessView.isInitialized) return
    when (call.method) {
      "openOtplessSdk", "openOtplessLoginPage" -> {
        result.success("")
        val jsonString = call.argument<String>("arg")
        val jsonObject = if (jsonString != null) {
          try {
            Log.d(Tag, "arg: $jsonString")
            JSONObject(jsonString)
          } catch (ex: Exception) {
            Log.d(Tag, "wrong json object is passed. error ${ex.message}")
            ex.printStackTrace()
            null
          }
        } else {
          Log.d(Tag, "No json object is passed.")
          null
        }
        if (call.method == "openOtplessSdk") {
          openOtpless(jsonObject)
        } else {
          openOtplessLoginPage(jsonObject)
        }
      }

      "onSignComplete" -> {
        activity.runOnUiThread {
          otplessView.onSignInCompleted()
        }
      }

      "hideFabButton" -> {
        activity.runOnUiThread {
          otplessView.showOtplessFab(false)
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

  fun onNewIntent(intent: Intent?) {
    intent ?: return
    otplessView.verifyIntent(intent)
  }

  private fun openOtpless(json: JSONObject?) {
    activity.runOnUiThread {
      otplessView.startOtpless(json) {
        Log.d(Tag, "callback openOtpless with response $it")
        channel.invokeMethod("otpless_callback_event", it.toJsonString())
      }
    }
  }

  private fun openOtplessLoginPage(json:JSONObject?) {
    activity.runOnUiThread {
      otplessView.showOtplessLoginPage(json) {
        Log.d(Tag, "callback openOtplessLoginPage with response $it")
        channel.invokeMethod("otpless_callback_event", it.toJsonString())
      }
    }
  }

  fun onBackPressed(): Boolean {
    return otplessView.onBackPressed()
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    otplessView = OtplessManager.getInstance().getOtplessView(activity)
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

  companion object {
    private const val Tag = "OtplessFlutterPlugin"
  }
}
