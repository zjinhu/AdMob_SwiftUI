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
    public func adReward(adUnitID: String, perform action: @escaping (Int) -> ()) -> some View {
        if !UserDefaults.standard.bool(forKey: "isPro.InPurchase"){
            modifier(AdRewardModifier(adUnitID: adUnitID, action: action))
        }else{
            self
        }
    }
}

public struct AdRewardModifier: ViewModifier {
 
    private let adInstanse: RewardInstance?
    private let action: (Int) -> ()
    public init(adUnitID: String, action: @escaping (Int) -> ()) {
        self.action = action
        adInstanse = RewardInstance(adUnitID: adUnitID, action: action)
    }

    public func body(content: Content) -> some View {
        content
            .onFirstAppear {
                adInstanse?.loadAD()
            }
            .onTapGesture {
                adInstanse?.showAD()
            }
    }
}

public class RewardInstance: NSObject, GADFullScreenContentDelegate {
 
    private var rewardedAd: GADRewardedAd?
    private let adUnitID: String
    private let action: (Int) -> ()
    public init(adUnitID: String, action: @escaping (Int) -> ()) {
        self.adUnitID = adUnitID
        self.action = action
    }

    public func loadAD() {
        clean()
        GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
            if let error {
                logger.log("Failed to load RewardedAd: \(error)")
                return
            }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }
    
    @discardableResult
    public func loadAD() async throws -> GADRewardedAd {
        clean()
        return try await withCheckedThrowingContinuation { continuation in
            GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let ad = ad {
                    self.rewardedAd = ad
                    ad.fullScreenContentDelegate = self
                    continuation.resume(returning: ad)
                }
            }
        }
    }
    
    private func clean() {
        self.rewardedAd = nil
    }
    
    
    public func showAD() {
        guard let rewardedAd = rewardedAd else {
            return logger.log("Rewarded wasn't ready")
        }
        
        guard let vc = UIViewController.currentViewController else {
            return logger.log("Rewarded UIViewController is nil")
        }
        
        rewardedAd.present(fromRootViewController: vc) { [weak self] in
            let reward = rewardedAd.adReward
            logger.log("Reward amount: \(reward.amount)")
            self?.action(reward.amount.intValue)
        }
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        clean()
        logger.log("Rewarded Dismiss")
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        logger.log("Rewarded AdLoadFail:Error\(error)")
    }

}
