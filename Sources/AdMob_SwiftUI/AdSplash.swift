//
//  SwiftUIView.swift
//  
//
//  Created by 狄烨 on 2023/10/18.
//

import SwiftUI
import GoogleMobileAds
extension View {
    @ViewBuilder
    public func adSplash(adUnitID: String, perform action: @escaping () -> ()) -> some View {
        if !UserDefaults.standard.bool(forKey: "isPro.InPurchase"){
            modifier(AdSplashModifier(adUnitID: adUnitID, action: action))
        }else{
            self
        }
    }
}

public struct AdSplashModifier: ViewModifier {
    @State private var hasAppeared = false
    private var adInstanse: SplashInstance?
    private let action: () -> ()
    public init(adUnitID: String, action: @escaping () -> ()) {
        self.action = action
        adInstanse = SplashInstance(adUnitID: adUnitID, action: action)
    }

    public func body(content: Content) -> some View {
        content
            .task {
                if !hasAppeared {
                    hasAppeared = true
                    if let _ = try? await adInstanse?.loadAD(){
                        adInstanse?.showAD()
                    }
                }
            }
    }
}
 
public class SplashInstance: NSObject, GADFullScreenContentDelegate {
    private var appOpenAd: GADAppOpenAd?
    private let adUnitID: String
    private let action: () -> ()
    
    public init(adUnitID: String, action: @escaping () -> ()) {
        self.adUnitID = adUnitID
        self.action = action
    }
    
    public func showAD() {
        guard let appOpenAd = appOpenAd else {
            loadAD()
            return logger.log("Splash wasn't ready")
        }
        
        guard let vc = UIViewController.currentViewController else {
            return logger.log("Splash UIViewController is nil")
        }
        
        appOpenAd.present(fromRootViewController: vc)
    }
 
    private func clean() {
        appOpenAd = nil
    }
    
    public func loadAD() {
        clean()
        GADAppOpenAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
            if let error {
                logger.log("Failed to load AppOpenAd: \(error)")
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
        }
    }
     
    public func loadAD() async throws -> GADAppOpenAd {
        clean()
        return try await withCheckedThrowingContinuation { continuation in
            GADAppOpenAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
                if let error = error {
                    logger.log("Failed to load AppOpenAd: \(error)")
                    continuation.resume(throwing: error)
                } else if let ad = ad {
                    self.appOpenAd = ad
                    ad.fullScreenContentDelegate = self
                    continuation.resume(returning: ad)
                }
            }
        }
    }

    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        logger.log("Splash AdDismissed")
        action()
        clean()
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        logger.log("Splash AdLoadFail:Error\(error)")
    }

}
