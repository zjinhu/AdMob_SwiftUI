//
//  SwiftUIView.swift
//  
//
//  Created by 狄烨 on 2023/10/18.
//

import SwiftUI
import GoogleMobileAds

public struct AdBannerView: UIViewControllerRepresentable {
    @State private var viewSize: CGSize = .zero
    private let bannerView = GADBannerView()
    @Environment(\.adUnitID) private var adUnitID
    public init() { }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let bannerViewController = BannerViewController()
        if let adUnitID{
            bannerView.adUnitID = adUnitID
            bannerView.delegate = context.coordinator
            bannerView.rootViewController = bannerViewController
            bannerViewController.view.addSubview(bannerView)
            bannerViewController.delegate = context.coordinator
        }
        return bannerViewController
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        logger.log("size: \(viewSize)")
        guard viewSize != .zero else { return }
 
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewSize.width)
        bannerView.load(GADRequest())
    }
    
    public class Coordinator: NSObject, BannerViewControllerWidthDelegate, GADBannerViewDelegate {
        let parent: AdBannerView
        
        init(_ parent: AdBannerView) {
            self.parent = parent
        }
 
        func bannerViewController(_ bannerViewController: BannerViewController, didUpdate size: CGSize) {
            parent.viewSize = size
        }
        
        public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            logger.log("Banner AdLoaded")
        }
        
        public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            logger.log("Banner AdLoadFail:Error\(error)")
        }

    }
}


#Preview {
    GeometryReader { geometry in
        AdBannerView()
                .frame(width: geometry.size.width, height: 75)
            .background(Color.red)
    }
}

protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(_ bannerViewController: BannerViewController, didUpdate size: CGSize)
}

class BannerViewController: UIViewController {
    weak var delegate: BannerViewControllerWidthDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.bannerViewController(self, didUpdate: view.frame.inset(by: view.safeAreaInsets).size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate { _ in
            // do nothing
        } completion: { _ in
            self.delegate?.bannerViewController(self, didUpdate: self.view.frame.inset(by: self.view.safeAreaInsets).size)
        }
    }
}
