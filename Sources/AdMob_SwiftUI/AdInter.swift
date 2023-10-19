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
    public func adInter(adUnitID: String) -> some View {
        if !UserDefaults.standard.bool(forKey: "isPro.InPurchase"){
            modifier(AdInterModifier(adUnitID: adUnitID))
        }else{
            self
        }
    }
}

public struct AdInterModifier: ViewModifier {
    @State private var hasAppeared = false
    private let adInstanse : InterInstance?

    public init(adUnitID: String) {
        adInstanse = InterInstance(adUnitID: adUnitID)
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
 
public class InterInstance: NSObject, GADFullScreenContentDelegate {

    private var interstitial: GADInterstitialAd?
    private let adUnitID: String
    
    public init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    public func showAD() {
        guard let interstitial = interstitial else {
            loadAD()
            return logger.log("InterAd wasn't ready")
        }
        
        guard let vc = UIViewController.currentViewController else {
            return logger.log("Inter UIViewController is nil")
        }
 
        interstitial.present(fromRootViewController: vc)
 
    }
    
    public func loadAD() {
        clean()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
            if let error {
                logger.log("Failed to load InterstitialAd: \(error)")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self 
        }
    }
     
    public func loadAD() async throws -> GADInterstitialAd {
        clean()
        
        return try await withCheckedThrowingContinuation { continuation in
            GADInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
                if let error = error {
                    logger.log("Failed to load InterstitialAd: \(error)")
                    continuation.resume(throwing: error)
                } else if let ad = ad {
                    self.interstitial = ad
                    ad.fullScreenContentDelegate = self
                    continuation.resume(returning: ad)
                }
            }
        }
    }
    
    private func clean() {
        interstitial = nil
    }

    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        logger.log("Inter AdLoadFail:Error\(error)")
    }

    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        clean()
        logger.log("Inter AdDismissed")
    }
    
}
