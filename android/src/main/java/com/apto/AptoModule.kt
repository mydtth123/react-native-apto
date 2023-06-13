package com.apto

import android.app.Application
import com.aptopayments.mobile.features.managecard.CardOptions
import com.aptopayments.mobile.functional.Either
import com.aptopayments.mobile.platform.AptoPlatform
import com.aptopayments.mobile.platform.AptoPlatformWebTokenProvider
import com.aptopayments.mobile.platform.AptoSdkEnvironment
import com.aptopayments.mobile.platform.WebTokenFailure
import com.aptopayments.sdk.core.platform.AptoUiSdk
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

class AptoModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
//  init {
//    reactContext.currentActivity?.application?.let { AptoUiSdk.initialize(it) }
//  }

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
  fun inittal(key: String, isDev: Boolean) {
//    currentActivity?.application?.let { AptoUiSdk.initialize(it) }
    reactApplicationContext.currentActivity?.runOnUiThread {
      AptoUiSdk.initialize(reactApplicationContext.currentActivity!!.application)
      val env = if (isDev) AptoSdkEnvironment.SBX else AptoSdkEnvironment.PRD;
      AptoUiSdk.setApiKey(key, AptoSdkEnvironment.SBX)
    }
  }


  @ReactMethod
  fun onCardFlowStart(token: String, onFailureCallback: Callback, onSuccessCallback: Callback) {
    val a = MyWebTokenProvider(token)
    val cardOptions = CardOptions()

    AptoUiSdk.setWebTokenProvider(a);
    currentActivity?.let {
      AptoUiSdk.startCardFlow(it, cardOptions,
        onSuccess = {
          println("onSuccess")
          onSuccessCallback.invoke()
          // SDK successfully initialized
        },
        onError = { err ->
          println("onError ${err.errorMessage()}")
          // SDK initialized with errors
          onFailureCallback.invoke(err)
        }
      )
    }
  }

  companion object {
    const val NAME = "Apto"
  }
}
