package com.apto

import android.app.Application
import android.util.Log
import com.aptopayments.mobile.features.managecard.CardOptions
import com.aptopayments.mobile.functional.Either
import com.aptopayments.mobile.platform.AptoPlatform
import com.aptopayments.mobile.platform.AptoPlatformWebTokenProvider
import com.aptopayments.mobile.platform.AptoSdkEnvironment
import com.aptopayments.mobile.platform.WebTokenFailure
import com.aptopayments.sdk.core.platform.AptoUiSdk
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.UiThreadUtil
import com.google.gson.Gson
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.SignatureAlgorithm
import okhttp3.Call
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import org.bouncycastle.util.io.pem.PemObject
import org.bouncycastle.util.io.pem.PemReader
import java.io.IOException
import java.io.StringReader
import java.lang.Exception
import java.security.KeyFactory
import java.security.interfaces.RSAPrivateKey
import java.security.spec.PKCS8EncodedKeySpec
import javax.crypto.Cipher.SECRET_KEY


class AptoModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {


  val tokenProvider = MyWebTokenProviderA()
  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun multiply(a: Double, b: Double, promise: Promise) {
    promise.resolve(a * b)
  }

  @ReactMethod
  fun initial(apiKey: String, baseURL: String, isSanbox: Boolean) {

    val env = if (isSanbox) AptoSdkEnvironment.SBX else AptoSdkEnvironment.PRD;
    AptoUiSdk.setWebTokenProvider(tokenProvider)
  reactApplicationContext.currentActivity?.runOnUiThread(
    Runnable {
      AptoUiSdk.initializeWithApiKey(
        reactApplicationContext.applicationContext as Application,
        apiKey,
        AptoSdkEnvironment.SBX
      )

    }
  )

//    AptoUiSdk.setApiKey(apiKey, AptoSdkEnvironment.SBX)
  }

  @ReactMethod
  fun startCardFlow(promise: Promise) {
    val cardOptions = CardOptions(showNotificationPreferences = true, showStatsButton = true, showAccountSettingsButton = true,authenticateOnPCI = CardOptions.PCIAuthType.NONE,
    authenticateOnStartup = false, showDetailedCardActivityOption = true, hideFundingSourcesReconnectButton = true, openingMode = CardOptions.OpeningMode.EMBEDDED)

    reactApplicationContext.currentActivity?.let {
//      reactApplicationContext.runOnUiQueueThread(Runnable {
        AptoUiSdk.startCardFlow(it, cardOptions,
          onSuccess = {  ->
            println("onSuccess",)
            promise.resolve("onSuccess")
            // SDK successfully initialized
          },
          onError = { err ->
            promise.reject(Throwable(err.errorMessage()))
            println("onError ${err.errorMessage()}")
            // SDK initialized with errors
          }
        )
//      })

    }
  }


  companion object {
    const val NAME = "Apto"
  }


}
class MyWebTokenProviderA: AptoPlatformWebTokenProvider {
  private val client = OkHttpClient();
  override fun getToken(payload: String, callback: (Either<WebTokenFailure, String>) -> Unit) {
//       This is an example that uses okhttp to fetch the JWT from your server
    val request = Request.Builder()
      .url("https://api-dev.tappo.uk/v1/sign")
      .post(payload.toRequestBody("application/json".toMediaType()))
      .build()

    client.newCall(request).enqueue(object : okhttp3.Callback {
      override fun onFailure(call: Call, e: IOException) {
        // let SDK know an error happened
        callback(Either.Left(WebTokenFailure))
      }

      override fun onResponse(call: Call, response: Response) {
        response.use {
          if (!response.isSuccessful) {
            // let SDK know an error happened
            callback(Either.Left(WebTokenFailure))
          } else {
            // send the JWT back to the SDK
            val gson = Gson()
            val data = response.body?.string();
            val user = gson.fromJson(data, UserResponse::class.java);
            callback(Either.Right(user.token))
          }
        }
      }
    })

  }
}


class UserResponse(val token: String)
