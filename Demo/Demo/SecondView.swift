//
//  SecondView.swift
//  Example
//
//  Created by 狄烨 on 2023/9/5.
//

import SwiftUI
import AdMob_SwiftUI
struct SecondView: View {

    var body: some View {
        
        ZStack{
            Text("Hello, World!")
        }
        .adInter(adUnitID: "ca-app-pub-3278026778756846/4732138880")
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView()
    }
}
