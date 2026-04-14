//
//  FeatureOnboardingStore.swift
//  wellSync
//
//  Created by Codex on 10/04/26.
//

import Foundation

enum FeatureOnboardingStore {

    private static let prefix = "feature_onboarding_seen."

    static func shouldShow(for key: String) -> Bool {
        !UserDefaults.standard.bool(forKey: prefix + key)
    }

    static func markSeen(for key: String) {
        UserDefaults.standard.set(true, forKey: prefix + key)
    }
}
