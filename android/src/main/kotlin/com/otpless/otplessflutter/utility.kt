package com.otpless.otplessflutter

import com.otpless.dto.HeadlessResponse
import org.json.JSONObject

internal fun convertHeadlessResponseToJson(headlessResponse: HeadlessResponse): JSONObject {
    val jsonObject = JSONObject()
    jsonObject.put("responseType", headlessResponse.responseType)
    jsonObject.put("statusCode", headlessResponse.statusCode)
    jsonObject.put("response", headlessResponse.response)
    return jsonObject
}