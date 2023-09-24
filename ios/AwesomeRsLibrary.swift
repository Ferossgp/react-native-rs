@objc(AwesomeRsLibrary)
class AwesomeRsLibrary: NSObject {

  @objc(multiply:withB:withResolver:withRejecter:)
  func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
      resolve(rustMultiply(a: a, b: b))
  }
}
