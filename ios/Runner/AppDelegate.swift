import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register native method channel for image gallery saver
    let controller = window?.rootViewController as! FlutterViewController
    let imageGalleryChannel = FlutterMethodChannel(
      name: "image_gallery_saver",
      binaryMessenger: controller.binaryMessenger
    )

    imageGalleryChannel.setMethodCallHandler { [weak self] (call, result) in
      self?.handleMethodCall(call: call, result: result)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "saveImageToGallery":
      guard let args = call.arguments as? [String: Any],
        let imageData = args["imageData"] as? FlutterStandardTypedData,
        let fileName = args["fileName"] as? String
      else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }

      let imageGallerySaver = ImageGallerySaver()
      imageGallerySaver.saveImageToGallery(
        imageData: imageData.data,
        fileName: fileName
      ) { success, message in
        if success {
          let response: [String: Any] = [
            "isSuccess": true,
            "filePath": "",
            "message": message ?? "Image saved successfully",
          ]
          result(response)
        } else {
          result(FlutterError(code: "SAVE_FAILED", message: message, details: nil))
        }
      }

    case "checkPermission":
      let imageGallerySaver = ImageGallerySaver()
      let permissionResult = imageGallerySaver.checkPermission()
      let response: [String: Any] = [
        "isGranted": permissionResult.isGranted,
        "status": permissionResult.status,
      ]
      result(response)

    case "requestPermission":
      let imageGallerySaver = ImageGallerySaver()
      imageGallerySaver.requestPermission { isGranted, status in
        let response: [String: Any] = [
          "isGranted": isGranted,
          "status": status,
        ]
        result(response)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
