package com.otpless.otplessflutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.otpless.dto.HeadlessRequest
import com.otpless.dto.HeadlessResponse
import com.otpless.dto.OtpDeliveryChannel
import com.otpless.dto.OtpLength
import com.otpless.dto.OtplessRequest
import com.otpless.main.OtplessManager
import com.otpless.main.OtplessView
import com.otpless.tesseract.OtplessSecureService
import com.otpless.tesseract.sim.OtplessSimStateReceiverApi
import com.otpless.utils.Utility
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.NewIntentListener
import org.json.JSONObject


/** OtplessFlutterPlugin */
class OtplessFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener, NewIntentListener {
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
    fun parseJsonArg(): JSONObject {
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
      if (jsonObject == null) {
        throw Exception("json argument not provided")
      }
      return jsonObject
    }
    when (call.method) {
      "openOtplessLoginPage" -> {
        result.success("")
        openOtplessLoginPage(parseJsonArg())
      }

      "setLoaderVisibility" -> {
        val visibility = call.argument<Boolean>("arg") ?: true
        result.success("")
        activity.runOnUiThread {
          otplessView.setLoaderVisibility(visibility)
        }
      }

      "isWhatsAppInstalled" -> {
        result.success(Utility.isWhatsAppInstalled(activity))
      }

      "startHeadless" -> {
        result.success("")
        startHeadless(parseJsonArg())
      }

      "initHeadless" -> {
        val appId = call.argument<String>("arg") ?: ""
        result.success("")
        activity.runOnUiThread {
          otplessView.initHeadless(appId)
        }
      }

      "setHeadlessCallback" -> {
        result.success("")
        otplessView.setHeadlessCallback(this::onHeadlessResultCallback)
      }

      "setWebviewInspectable" -> {
        // webview is always inspectable in debug mode
      }

      "enableDebugLogging" -> {
        val isEnabled = call.argument<Boolean>("arg") ?: false
        result.success("")
        Utility.debugLogging = isEnabled
      }

      "showPhoneHintLib" -> {
        val showFallback = call.argument<Boolean>("arg") ?: true
        showPhoneHint(showFallback) {
          result.success(it)
        }
      }

      "attachSecureService" -> {
        val appId = call.argument<String>("appId") ?: ""
        attachSecureService(appId, result)
      }

      "getEjectedSimEntries" -> {
        val ejectedSimEntries = getEjectedSimsEntries()
        result.success(ejectedSimEntries)
      }

      "setSimEjectionListener" -> {
        val isAttach = call.argument<Boolean>("isAttach") ?: false
        setSimEjectionListener(isAttach)
        result.success(null)
      }

      "commitHeadlessResponse" -> {
        val response = call.argument<Map<String, Any>>("response") ?: emptyMap()
        val headlessResponse = convertMapToHeadlessResponse(response)
        if (::otplessView.isInitialized) {
          otplessView.commitHeadlessResponse(headlessResponse)
        }
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  private fun convertMapToHeadlessResponse(response: Map<String, Any>): HeadlessResponse? {
    if (response.isEmpty()) return null
    try {
      val responseType = response["responseType"].toString()
      val responseJson =  JSONObject(response["response"] as Map<String, Any>)
      val statusCode = response["statusCode"].toString().softParseStatusCode()

      return HeadlessResponse(
        responseType,
        responseJson,
       statusCode
      )
    } catch (_: Exception) {
      return null
    }
  }

  private fun openOtplessLoginPage(json:JSONObject) {
    val otplessRequest = OtplessRequest(json.getString("appId"))
    json.optJSONObject("params")?.let { params ->
      // checking and adding uxmode
      val uxMode = params.optString("uxmode")
      if (uxMode.isNotEmpty()) {
        otplessRequest.setUxmode(uxMode)
        params.remove("uxmode")
      }
      // checking and adding locale
      val locale = params.optString("locale")
      if (locale.isNotEmpty()) {
        otplessRequest.setLocale(locale)
        params.remove("locale")
      }
      // adding other extra params
      for (key in params.keys()) {
        val value = params.optString(key)
        if (value.isEmpty()) continue
        otplessRequest.addExtras(key, value)
      }
    }
    activity.runOnUiThread {
      otplessView.showOtplessLoginPage(otplessRequest) {
        Log.d(Tag, "callback openOtplessLoginPage with response $it")
        channel.invokeMethod("otpless_callback_event", it.toJsonString())
      }
    }
  }

  private fun onHeadlessResultCallback(headlessResponse: HeadlessResponse) {
    Log.d(Tag, "callback openOtplessLoginPage with response $headlessResponse")
    channel.invokeMethod("otpless_callback_event", convertHeadlessResponseToJson(headlessResponse).toString())
  }

  private fun startHeadless(json: JSONObject) {
    val headlessRequest = parseHeadlessRequest(json)
    val timeout = json.optInt("timeout", 0)
    activity.runOnUiThread {
      if (timeout == 0) otplessView.startHeadless(headlessRequest, this::onHeadlessResultCallback)
      else otplessView.startHeadless(headlessRequest, timeout.toLong(), this::onHeadlessResultCallback)
    }
  }

  private fun parseHeadlessRequest(json: JSONObject): HeadlessRequest {
    val headlessRequest = HeadlessRequest()
    // check for phone
    val phone = json.optString("phone")
    if (phone.isNotEmpty()) {
      val countryCode = json.getString("countryCode")
      headlessRequest.setPhoneNumber(countryCode, phone)
      val otp = json.optString("otp")
      if (otp.isNotEmpty()) {
        headlessRequest.setOtp(otp)
      }
    } else {
      // check for email
      val email = json.optString("email")
      // check for otp in case of phone and email
      if (email.isNotEmpty()) {
        headlessRequest.setEmail(email)
        val otp = json.optString("otp")
        if (otp.isNotEmpty()) {
          headlessRequest.setOtp(otp)
        }
      } else {
        // check for channel type
        val channelType = json.getString("channelType")
        headlessRequest.setChannelType(channelType)
      }
    }
    // adding otp length and expiry
    json.optString("otpLength").softParseInt {
      headlessRequest.setOtpLength(OtpLength.suggestOtpSize(it))
    }
    json.optString("expiry").softParseInt {
      headlessRequest.setExpiry(it)
    }
    // adding delivery channel
    val dChannelStr: String = json.optString("deliveryChannel")
    headlessRequest.setDeliveryChannel(
      OtpDeliveryChannel.from(dChannelStr.uppercase())
    )
    return headlessRequest
  }

  private inline  fun String.softParseInt(onSuccessParse: (Int) -> Unit) {
    if (this.isEmpty()) return
    try {
      onSuccessParse(this.toInt())
    } catch (ex: NumberFormatException) {
      Utility.debugLog(ex)
    }
  }

  private fun String.softParseStatusCode() : Int {
    if (this.isEmpty()) return -1000
    try {
      return this.toInt()
    } catch (e: NumberFormatException) {
      Utility.debugLog(e)
      return -1000
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
    otplessView.phoneHintManager.register(activity, false)
    binding.addActivityResultListener(this)
    binding.addOnNewIntentListener(this)
  }

  override fun onNewIntent(intent: Intent): Boolean {
    return otplessView.onNewIntent(intent)
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

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (!this::otplessView.isInitialized) return false
    return otplessView.onActivityResult(requestCode, resultCode, data)
  }

  private fun showPhoneHint(showFallback: Boolean, onPhoneHintResult: (Map<String, String>) -> Unit) {
    otplessView.phoneHintManager.showPhoneNumberHint(showFallback) { phoneHintResult ->
      val map = mutableMapOf(
        if (phoneHintResult.first != null)
          "phoneNumber" to phoneHintResult.first!!
        else
          "error" to phoneHintResult.second!!.message!!
      )
      onPhoneHintResult(map)
    }
  }

  private fun attachSecureService(appId: String, result: Result) {
    try {
        val managerClass = Class.forName("com.otpless.secure.OtplessSecureManager")
        val managerInstance = managerClass.getField("INSTANCE").get(null)
        val creatorMethod = managerClass.getDeclaredMethod(
          "getOtplessSecureService", Activity::class.java, String::class.java)
        val secureService = creatorMethod.invoke(managerInstance, activity, appId) as? OtplessSecureService
        otplessView.attachOtplessSecureService(secureService)
        result.success("")
      } catch (ex: ClassNotFoundException) {
        Utility.debugLog(ex)
        result.error("SERVICE_ERROR", "Failed to create otpless service.", ex.message);
      } catch (ex: NoSuchMethodException) {
        Utility.debugLog(ex)
        result.error("SERVICE_ERROR", "Failed to create otpless service.", ex.message);
      }
  }

  private fun getEjectedSimsEntries(): List<Map<String, Any>> {
    val result = mutableListOf<Map<String, Any>>()
    for (each in OtplessSimStateReceiverApi.savedEjectedSimEntries(activity)) {
        result.add(
          mapOf(
            "state" to each.state,
            "transactionTime" to each.transactionTime
          )
        )
    }
    return result
  }

  private fun setSimEjectionListener(isToAttach: Boolean) {
    if (isToAttach) OtplessSimStateReceiverApi.setSimStateChangeListener {
      val result = mutableListOf<Map<String, Any>>()
      for (each in OtplessSimStateReceiverApi.savedEjectedSimEntries(activity)) {
        result.add(
          mapOf(
            "state" to each.state,
            "transactionTime" to each.transactionTime
          )
        )
      }
      channel.invokeMethod("otpless_sim_status_change_event", result)
    } else OtplessSimStateReceiverApi.setSimStateChangeListener(null)
  }
}
