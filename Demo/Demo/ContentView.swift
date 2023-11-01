//
//  ContentView.swift
//  Demo
//
//  Created by 狄烨 on 2023/10/18.
//

import SwiftUI
import AdMob_SwiftUI
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                Text("点击打开激励广告")
                    .adReward(adUnitID: "ca-app-pub-3940256099942544/1712485313") { num in
                        print("Reward + :\(num)")
                    }
                
                NavigationLink {
                    SecondView()
                } label: {
                    Text("点击跳转插屏广告")
                }
                
                NavigationLink {
                    ThirdView()
                } label: {
                    Text("点击跳转插屏激励广告")
                }
                
                AdBannerView()
                    .adUnitID("ca-app-pub-3278026778756846/2716365544")
                    .frame(maxWidth: .infinity)
                    .frame(height: 75)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
