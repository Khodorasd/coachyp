import UIKit
import Flutter
import GoogleMaps  // Import Google Maps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyBsxe_cvisFPpMaddsoyjO0z99FuIzuE9A")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}