# AdMob_SwiftUI

添加广告权限，在首页添加检查广告追踪权限

```
            ContentView()
                .checkADTracking()

```

注册SDK

```
AdManager.initAD()
```
 
添加Banner广告

```
                AdBannerView()
                    .adUnitID("ca-app-pub-3278026778756846/2716365544")
                    .frame(maxWidth: .infinity)
                    .frame(height: 75)
```

添加激励广告，只需要在View上声明激励广告即可，点击后回掉返回奖励数据

```
                Text("点击打开激励广告")
                    .adReward(adUnitID: "ca-app-pub-3940256099942544/1712485313") { num in
                        print("Reward + :\(num)")
                    }
```

插屏广告，需要插屏的View上添加一下插屏广告的声明

```
            NavigationView {
                List(["1", "2", "3", "4", "5"], id: \.self) { row in
                    Text(row)
                }
            }
            .adInterRewarded(adUnitID: "ca-app-pub-3940256099942544/6978759866") { num in
                print("Reward + :\(num)")
            }
```

启动广告，在首页添加启动广告的声明

```
            ContentView() 
                .adSplash(adUnitID: "ca-app-pub-3278026778756846/4631954192") {
                    print("启动广告关闭,打开内购页面")
                }
```
