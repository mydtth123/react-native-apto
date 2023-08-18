package com.apto

import android.app.Application
import androidx.fragment.app.FragmentActivity
import com.aptopayments.mobile.data.PhoneNumber
import com.aptopayments.mobile.data.user.Verification
import com.aptopayments.mobile.data.user.VerificationStatus
import com.aptopayments.mobile.exception.Failure
import com.aptopayments.mobile.features.managecard.CardOptions
import com.aptopayments.mobile.functional.Either
import com.aptopayments.mobile.platform.AptoPlatform
import com.aptopayments.mobile.platform.AptoPlatformWebTokenProvider
import com.aptopayments.mobile.platform.AptoSdkEnvironment
import com.aptopayments.mobile.platform.WebTokenFailure
import com.aptopayments.sdk.core.platform.AptoUiSdk
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.WritableNativeMap
import com.google.gson.Gson

import okhttp3.Call
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import java.io.IOException


class AptoModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {


  private val tokenProvider = MyWebTokenProviderA()
  private var primaryCredential: Verification? = null
  private var secondCredential: Verification? = null
  override fun getName(): String {
    return NAME
  }


  @ReactMethod
  fun initial(apiKey: String, baseURL: String, isSanbox: Boolean) {
    val env = if (isSanbox) AptoSdkEnvironment.SBX else AptoSdkEnvironment.PRD;
    AptoPlatform.initializeWithApiKey(
      reactApplicationContext.applicationContext as Application,
      apiKey,
      env
    )
    tokenProvider.baseURL = baseURL
    AptoPlatform.webTokenProvider = tokenProvider
  }

  @ReactMethod
  fun startPhoneVerification(phoneNumber: String, promise: Promise) {
    val phone = PhoneNumber("+1", phoneNumber)
    phone.let {
      AptoPlatform.startPhoneVerification(it) { result ->
        result.either({
          promise.reject("ERROR_CODE", "Something went wrong", null)
        }) { verification ->
          this.primaryCredential = verification
          val data = WritableNativeMap()
          data.putString("verificationId", verification?.verificationId)
          promise.resolve(data)
        }
      }

    }
  }

  @ReactMethod
  fun completeVerificataion(secret: String, promise: Promise) {
    this.primaryCredential?.let { primaryCreden ->
      primaryCreden.secret = secret
      AptoPlatform.completeVerification(primaryCreden) { result ->
        result.either({
          promise.reject("ERROR_CODE", "Something went wrong", null)
        }) { verification ->
          if (verification.status == VerificationStatus.PASSED) {
            val data = WritableNativeMap()
            data.putString("verificationId", verification?.verificationId)
            verification.secondaryCredential?.let {
              data.putString("secondaryCredential", it.verificationId)
              this.secondCredential = it
            }
          } else {
            promise.reject("ERROR_CODE", "Code invalid", null)

          }
        }
      }
    }
  }

  @ReactMethod
  fun completeSercondaryVerificataion(secret: String, promise: Promise) {
    this.secondCredential?.let { credential ->
      credential.secret = secret
      AptoPlatform.completeVerification(credential) { result ->
        result.either({
          promise.reject("ERROR_CODE", "Something went wrong", null)
        }) { verification ->
          if (verification.status == VerificationStatus.PASSED) {
            this.secondCredential = verification
            this.loginWithExistingUser(promise)
          } else {
            promise.reject("ERROR_CODE", "Code invalid", null)
          }
        }
      }
    }
  }
  fun loginWithExistingUser(promise: Promise){
    safeLet(this.primaryCredential, this.secondCredential) { primary, second ->
      AptoPlatform.loginUserWith(listOf(primary, second) as List<Verification>){ result  ->
        result.either({
          promise.reject("ERROR","Something went wrong",null)
        }) {user ->
          val data = WritableNativeMap()
          data.putString("userId", user.userId)
          data.putString("accessToken", user.token)
          promise.resolve(data)
        }
      }
    }
  }


  @ReactMethod
  fun startCardFlow(promise: Promise) {
    val cardOptions = CardOptions(
      showNotificationPreferences = true,
      showStatsButton = true,
      showAccountSettingsButton = true,
      authenticateOnPCI = CardOptions.PCIAuthType.NONE,
      authenticateOnStartup = false,
      showDetailedCardActivityOption = true,
      hideFundingSourcesReconnectButton = true,
      openingMode = CardOptions.OpeningMode.EMBEDDED
    )
    reactApplicationContext.currentActivity?.let {
      AptoUiSdk.startCardFlow(it, cardOptions,
        onSuccess = { ->
          println("onSuccess")
          promise.resolve("onSuccess")
        },
        onError = { err ->
          promise.reject(Throwable(err.errorMessage()))
          println("onError ${err.errorMessage()}")
        }
      )
    }
  }


  companion object {
    const val NAME = "Apto"
  }

  /**
   * Safely get and cast the current activity as an AppCompatActivity. If that fails, the promise
   * provided will be resolved with an error message instructing the user to retry the method.
   */
  private fun getCurrentActivityOrResolveWithError(promise: Promise?): FragmentActivity? {
    (currentActivity as? FragmentActivity)?.let {
      return it
    }
    promise?.reject("ERROR_CODE", "currentActivity not fount", null)
    return null
  }


}

class MyWebTokenProviderA : AptoPlatformWebTokenProvider {
  private val client = OkHttpClient();
  var baseURL = ""
  override fun getToken(payload: String, callback: (Either<WebTokenFailure, String>) -> Unit) {
    val request = Request.Builder()
      .url(this.baseURL)
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
inline fun <T1: Any, T2: Any, R: Any> safeLet(p1: T1?, p2: T2?, block: (T1, T2)->R?): R? {
  return if (p1 != null && p2 != null) block(p1, p2) else null
}
