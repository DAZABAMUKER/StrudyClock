//
//  PauseAds.swift
//  Strudy Clock
//
//  Created by 안병욱 on 10/31/23.
//

import GoogleMobileAds
import Foundation
import UIKit
import SwiftUI

class AdCoordinator: NSObject, GADFullScreenContentDelegate {
    private var ad: GADInterstitialAd?
    
    func loadAd() {
        GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-7240659336832390/1390404061", request: GADRequest()
        ) { ad, error in
            if let error = error {
                return print("Failed to load ad with error: \(error.localizedDescription)")
            }
            
            self.ad = ad
            self.ad?.fullScreenContentDelegate = self
        }
    }
    
    // MARK: - GADFullScreenContentDelegate methods

      func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
      }

      func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
      }

      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("\(#function) called")
      }

      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
      }


      func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
      }

      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
      }

  func presentAd(from viewController: UIViewController) {
    guard let fullScreenAd = ad else {
      return print("Ad wasn't ready")
    }

    fullScreenAd.present(fromRootViewController: viewController)
  }
}

struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    // No implementation needed. Nothing to update.
  }
}
