import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var imageGalleryChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register for remote notifications (APNS)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // Request APNS registration immediately
    print("📱 APNS: About to request remote notification registration")
    print("📱 APNS: Current bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
    UIApplication.shared.registerForRemoteNotifications()
    print("📱 APNS: Remote notification registration requested")

    // Register native method channel for image gallery saver
    // Setup method channel in a way compatible with UISceneDelegate
    setupMethodChannels()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupMethodChannels() {
    // Get FlutterViewController safely
    guard let controller = window?.rootViewController as? FlutterViewController else {
      // If window is not available yet (UISceneDelegate), setup will happen later
      print("⚠️ Window not available yet, will setup method channels later")
      return
    }

    imageGalleryChannel = FlutterMethodChannel(
      name: "image_gallery_saver",
      binaryMessenger: controller.binaryMessenger
    )

    imageGalleryChannel?.setMethodCallHandler { [weak self] (call, result) in
      self?.handleMethodCall(call: call, result: result)
    }

    print("✅ Method channels setup complete")
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)

    // Try to setup method channels again if they weren't set up during launch
    if imageGalleryChannel == nil {
      setupMethodChannels()
    }
  }

  // Register for remote notifications
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("📱 APNS: Device token registered successfully")
    print("📱 APNS: Token length: \(token.count) characters")
    print("📱 APNS: Token preview: \(String(token.prefix(20)))...")

    // Pass the device token to Flutter's firebase_messaging plugin
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Handle registration failure
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ APNS: Failed to register - \(error.localizedDescription)")
    #if targetEnvironment(simulator)
      print("⚠️ APNS: Running on simulator - APNS is not supported")
      print("⚠️ APNS: Please test on a real iOS device")
    #endif
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
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
