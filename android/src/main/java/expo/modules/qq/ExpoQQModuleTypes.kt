package expo.modules.qq

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record


class ShareContentOptions: Record {
    @Field
    var imageBase64OrImageUri: String = ""
    @Field
    var previewImageBase64OrImageUri: String? = null
    @Field
    var title: String? = null
    @Field
    var description: String?  = null
    @Field
    var extraImageList: Array<String>? = null
    @Field
    var platform: String? = null

    @Field
    var appName: String? = null

    @Field
    var targetUrl: String? = null
}