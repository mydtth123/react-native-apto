package com.apto

import com.aptopayments.mobile.functional.Either
import com.aptopayments.mobile.platform.AptoPlatformWebTokenProvider
import com.aptopayments.mobile.platform.WebTokenFailure

class MyWebTokenProvider(token: String) : AptoPlatformWebTokenProvider {
  private val token = token

  override fun getToken(payload: String, callback: (Either<WebTokenFailure, String>) -> Unit) {
    return callback(Either.Right(token))
  }
}
