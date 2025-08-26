//
//  ExpoQQModuleUtils.swift
//  ExpoQQ
//
//  Created by Aron on 2025/8/12.
//

import Foundation

struct ExpoQQModuleUtils {
    static func getImageDataFromBase64OrUri(_ base64OrImageUri: String?) -> Data? {
        if let string = base64OrImageUri, !string.isEmpty {
            if string.hasPrefix("file://") {
                if let fileURL = URL(string: string), let data = try? Data(contentsOf: fileURL, options: .mappedIfSafe) {
                    return data
                }
            } else {
                return Data(base64Encoded: string, options: .ignoreUnknownCharacters)
            }
        }
        return nil
    }
    
    static func getTargetContentType(_ contentType: String?) -> QQApiURLTargetType {
        switch contentType {
        case "notSpecified":
            return QQApiURLTargetType.notSpecified
        case "audio":
            return QQApiURLTargetType.audio
        case "video":
            return QQApiURLTargetType.video
        case "news":
            return QQApiURLTargetType.news
        default: return QQApiURLTargetType.notSpecified
        }
    }
}
