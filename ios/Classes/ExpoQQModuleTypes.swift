//
//  ExpoQQModuleTypes.swift
//  ExpoQQ
//
//  Created by Aron on 2025/8/12.
//

import Foundation
import ExpoModulesCore

struct ShareContentOptions: Record {
    @Field
    var imageBase64OrImageUri: String = ""
    @Field
    var previewImageBase64OrImageUri: String?
    @Field
    var title: String?
    @Field
    var description: String?
    @Field
    var extraImageList: [String]?
    @Field
    var platform: String?
}


struct ShareVideoOptions: Record {
    @Field
    var url: URL?
    @Field
    var title: String?
    @Field
    var description: String?
    @Field
    var previewImageURL: URL?
    @Field
    var targetContentType: String?
    @Field
    var platform: String?
}
