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
    public func adInterRewarded(adUnitID: String, perform action: @escaping (Int) -> ()) -> some View {
        if !UserDefaults.standard.bool(forKey: "isPro.InPurchase"){
            modifier(AdInterRewardedModifier(adUnitID: adUnitID, action: action))
        }else{
            self
        }
    }
}

public struct AdInterRewardedModifier: ViewModifier {
    @State private var hasAppeared = false
    private let adInstanse : InterRewardedInstance?
    private let action: (Int) -> ()
    public init(adUnitID: String, action: @escaping (Int) -> ()) {
        self.action = action
        adInstanse = InterRewardedInstance(adUnitID: adUnitID, action: action)
        adInstanse?.loadAD()
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

public class InterRewardedInstance: NSObject, GADFullScreenContentDelegate {

    private var rewardedInterstitialAd: GADRewardedInterstitialAd?
    
    private let action: (Int) -> ()
    private let adUnitID: String
    public init(adUnitID: String, action: @escaping (Int) -> ()) {
        self.adUnitID = adUnitID
        self.action = action
    }
    
    public func showAD() {
        guard let rewardedInterstitialAd = rewardedInterstitialAd else {
            loadAD()
            return logger.log("InterRewarded wasn't ready")
        }
        
        guard let vc = UIViewController.currentViewController else {
            return logger.log("InterRewarded UIViewController is nil")
        }
 
        rewardedInterstitialAd.present(fromRootViewController: vc) {
            let reward = rewardedInterstitialAd.adReward
            logger.log("Reward amount: \(reward.amount)")
            self.action(reward.amount.intValue)
        }
 
    }
    
    public func loadAD() {
        clean()
        GADRewardedInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
            if let error {
                logger.log("Failed to load RewardedInterstitialAd: \(error)")
                return
            }
            self.rewardedInterstitialAd = ad
            self.rewardedInterstitialAd?.fullScreenContentDelegate = self
        }
    }
     
    public func loadAD() async throws -> GADRewardedInterstitialAd {
        clean()
        
        return try await withCheckedThrowingContinuation { continuation in
            GADRewardedInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
                if let error = error {
                    logger.log("Failed to load RewardedInterstitialAd: \(error)")
                    continuation.resume(throwing: error)
                } else if let ad = ad {
                    self.rewardedInterstitialAd = ad
                    ad.fullScreenContentDelegate = self
                    continuation.resume(returning: ad)
                }
            }
        }
    }
    
    private func clean() {
        rewardedInterstitialAd = nil
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        clean()
        logger.log("InterRewarded AdDismissed")
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        logger.log("InterRewarded AdLoadFail:Error\(error)")
    }

}
