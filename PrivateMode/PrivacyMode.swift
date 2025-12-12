//
//  PrivacyMode.swift
//  PrivateMode
//
//  Created by 장영완 on 12/12/25.
//

import Foundation

enum PrivacyMode: String, CaseIterable {
    case none
    case dark
    case stripes
    case noise
    case spotlight
    
    var title: String {
        switch self {
        case .none: return "None"
        case .dark: return "Dark"
        case .stripes: return "Stripes"
        case .noise: return "Noise"
        case .spotlight: return "Spotlight"
        }
    }
}
