// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import AdSupport
import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI
import UIKit
import os

extension View {
    @inlinable
    public func checkADTracking() -> some View {
        onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            AdManager.checkTrackingAuthorization()
        }
    }
}

extension View {
    public func adUnitID(_ adUnitID: String) -> some View {
        environment(\.adUnitID, adUnitID)
    }
}

extension EnvironmentValues {
    var adUnitID: String? {
        get { self[AdUnitIDEnvironmentKey.self] }
        set { self[AdUnitIDEnvironmentKey.self] = newValue }
    }
}

struct AdUnitIDEnvironmentKey: EnvironmentKey {
    static var defaultValue: String?
}

public class AdManager{
    public static func checkTrackingAuthorization() {
        if !UserDefaults.standard.bool(forKey: "isPro.InPurchase"){
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                logger.log("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied:
                logger.log("IDFA denied")
            case .restricted:
                logger.log("IDFA restricted")
            case .notDetermined:
                showRequestTrackingAuthorizationAlert()
            @unknown default:
                fatalError()
            }
        }
    }
    
    private static func showRequestTrackingAuthorizationAlert() {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            switch status {
            case .authorized:
                logger.log("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied, .restricted, .notDetermined:
                logger.log("IDFA been denied!!!")
            @unknown default:
                fatalError()
            }
        })
    }
}

extension AdManager{
    public static func initAD() {
        if !UserDefaults.standard.bool(forKey: "isPro.InPurchase"){
            GADMobileAds.sharedInstance().start { status in
                logger.log("GADMobileAds status:\(status)")
            }
        }
    }
}

extension UIWindow {
    static var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .sorted { $0.activationState.sortPriority < $1.activationState.sortPriority }
            .compactMap { $0 as? UIWindowScene }
            .compactMap { $0.windows.first { $0.isKeyWindow } }
            .first
    }
}

private extension UIScene.ActivationState {
    var sortPriority: Int {
        switch self {
        case .foregroundActive: return 1
        case .foregroundInactive: return 2
        case .background: return 3
        case .unattached: return 4
        @unknown default: return 5
        }
    }
}

extension UIViewController {
    static var currentViewController: UIViewController? {
 
        if var topController = UIWindow.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

let logger = ADLog()

struct ADLog {
    private let logger: Logger
     
    init(subsystem: String = "ADLog", category: String = "ADLog") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }
}
 
extension ADLog {
    func log(_ message: String){
        logger.log("📣\(message)")
    }
}
