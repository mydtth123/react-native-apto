package com.apto

import android.app.Application
import com.aptopayments.mobile.platform.AptoSdkEnvironment
import com.aptopayments.sdk.core.platform.AptoUiSdk
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

class AptoModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  init {
    AptoUiSdk.initialize(reactContext as Application)
    AptoUiSdk.setApiKey("MOBILE_API_KEY", AptoSdkEnvironment.SBX)

  }
  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun multiply(a: Double, b: Double, promise: Promise) {
    promise.resolve(a * b)
  }

  companion object {
    const val NAME = "Apto"
  }
}
