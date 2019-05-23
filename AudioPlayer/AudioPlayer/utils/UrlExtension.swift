//
//  UrlExtension.swift
//  Sample
//
//  Created by Pedro Paulo de Amorim on 23/05/2019.
//  Copyright © 2019 Kevin Delannoy. All rights reserved.
//

import Foundation


internal extension URL {
  
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(
            in: self.absoluteString,
            options: [],
            range: NSRange(location: 0, length: self.absoluteString.utf16.count)) {
            return match.range.length == self.absoluteString.utf16.count
        }
        return false
    }

    func withScheme(_ scheme: String) -> URL? {
        var components: URLComponents? = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
  
}
