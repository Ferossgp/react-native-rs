package com.awesomerslibrary

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class AwesomeRsLibraryModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  fun multiply(a: Float, b: Float, promise: Promise) {
    promise.resolve(rustMultiply(a, b))
  }

  companion object {
    const val NAME = "AwesomeRsLibrary"
  }
}
