import ExpoModulesCore

let apiNotRegisteredError = Exception(name: "NOT_REGISTERED_ERR", description: "Please call init function first!")

public class ExpoQQModule: Module {
    
    var tencentOAuth: TencentOAuth?
    var delegateProxy: ExpoQQModuleDelegateProxy?
    static var moduleInstance: ExpoQQModule?
    
    func send(shareRequest request: QQBaseReq!, toPlatform platform: String?) -> QQApiSendResultCode {
        if platform == "qzone" {
            return QQApiInterface.sendReq(toQZone: request)
        }
        return QQApiInterface.send(request)
    }
    
    
    public func definition() -> ModuleDefinition {
        Name("ExpoQQ")
        
        Constants([
            "isQQInstalled": TencentOAuth.iphoneQQInstalled(),
            "isTIMInstalled": TencentOAuth.iphoneTIMInstalled()
        ])
        
        Events("onLoginFinished", "onGetUserInfo", "onShareFinished")
        
        OnCreate {
            delegateProxy = ExpoQQModuleDelegateProxy()
            Self.moduleInstance = self
        }
        
        OnDestroy {
            Self.moduleInstance = nil
        }
        
        AsyncFunction("init") { (appId: String, universalLink: String?) in
            let enableUniveralLink = universalLink != nil && !universalLink!.isEmpty
            TencentOAuth.setIsUserAgreedAuthorization(true)
            tencentOAuth = TencentOAuth.sharedInstance()
            tencentOAuth?.setupAppId(appId,
                                     enableUniveralLink: enableUniveralLink,
                                     universalLink: universalLink,
                                     delegate: delegateProxy)
        }
        
        AsyncFunction("login") { (permissions: [String], promise: Promise) in
            if tencentOAuth == nil {
                promise.reject(apiNotRegisteredError)
            } else {
                Task { @MainActor in
                    let loginResult = self.tencentOAuth?.authorize(permissions)
                    promise.resolve(loginResult == true ? 0 : -1)
                }
            }
        }
        
        AsyncFunction("loginByQRCode") { (permissions: [String], promise: Promise) in
            if tencentOAuth == nil {
                promise.reject(apiNotRegisteredError)
            } else {
                Task { @MainActor in
                    let loginResult = self.tencentOAuth?.authorize(withQRlogin: permissions)
                    promise.resolve(loginResult == true ? 0 : -1)
                }
            }
        }
        
        AsyncFunction("getLoginTokenInfo") {
            if tencentOAuth == nil {
                throw apiNotRegisteredError
            }
            let expirationDate = tencentOAuth?.expirationDate.timeIntervalSince1970 ?? 0
            return ["openId": tencentOAuth?.openId,
                    "accessToken": tencentOAuth?.accessToken,
                    "expirationDate": expirationDate * 1000] as [String: Any?]
        }
        
        AsyncFunction("sendGetUserInfoReq") { (promise: Promise) in
            if tencentOAuth == nil {
                promise.reject(apiNotRegisteredError)
            } else {
                Task { @MainActor in
                    promise.resolve(self.tencentOAuth?.getUserInfo() ?? false)
                }
            }
        }
        
        AsyncFunction("sharePlainText") { (text: String, platform: String?) in
            if tencentOAuth == nil {
                throw apiNotRegisteredError
            }
            let textObject = QQApiTextObject(text: text)
            let req = SendMessageToQQReq(content: textObject)
            
            return send(shareRequest: req, toPlatform: platform).rawValue
        }
        
        AsyncFunction("shareImage") { (options: ShareContentOptions) in
            if tencentOAuth == nil {
                throw apiNotRegisteredError
            }
            if let mainImage = ExpoQQModuleUtils.getImageDataFromBase64OrUri(options.imageBase64OrImageUri),
               let compressedImage = ImageCompressUtils.compressImageData(mainImage, toTargetKB: 1024 * 5) {
                var previewImage = ExpoQQModuleUtils.getImageDataFromBase64OrUri(options.previewImageBase64OrImageUri)
                if previewImage != nil {
                    previewImage = ImageCompressUtils.compressImageData(previewImage!, toTargetKB: 1024)
                }
                var extraImages: [Data] = []
                if options.extraImageList != nil && !options.extraImageList!.isEmpty {
                    extraImages = options.extraImageList!.compactMap{ str in
                        let image = ExpoQQModuleUtils.getImageDataFromBase64OrUri(str)
                        if image != nil {
                            return ImageCompressUtils.compressImageData(image!, toTargetKB: 1024 * 5)
                        }
                        return nil
                    }
                }
                let imageObject = QQApiImageObject(data: compressedImage,
                                                   previewImageData: previewImage,
                                                   title: options.title,
                                                   description: options.description,
                                                   imageDataArray: extraImages)
                let req = SendMessageToQQReq(content: imageObject)
                return send(shareRequest: req, toPlatform: options.platform).rawValue
            }
            return QQApiSendResultCode.EQQAPIMESSAGECONTENTINVALID.rawValue
        }
        
        AsyncFunction("shareVideo") { (options: ShareVideoOptions) in
            if tencentOAuth == nil {
                throw apiNotRegisteredError
            }
            if let url = options.url {
                let videoObject = QQApiVideoObject(url: url,
                                                   title: options.title,
                                                   description: options.description,
                                                   previewImageURL: options.previewImageURL,
                                                   targetContentType: ExpoQQModuleUtils.getTargetContentType(options.targetContentType))
                let req = SendMessageToQQReq(content: videoObject)
                return send(shareRequest: req, toPlatform: options.platform).rawValue
            }
            return QQApiSendResultCode.EQQAPIMESSAGECONTENTINVALID.rawValue
        }
        
        
    }
}


public class ExpoQQModuleDelegateProxy: NSObject, TencentSessionDelegate {
    public func tencentDidLogin() {
        let tencentOAuth = ExpoQQModule.moduleInstance?.tencentOAuth
        let expirationDate = tencentOAuth?.expirationDate.timeIntervalSince1970 ?? 0
        ExpoQQModule.moduleInstance?.sendEvent("onLoginFinished",
                                               ["success": true,
                                                "openId": tencentOAuth?.openId,
                                                "accessToken": tencentOAuth?.accessToken,
                                                "expirationDate": expirationDate * 1000])
    }
    
    public func tencentDidNotLogin(_ cancelled: Bool) {
        ExpoQQModule.moduleInstance?.sendEvent("onLoginFinished", ["userCancalled": cancelled, "success": false])
    }
    
    public func tencentDidNotNetWork() {
        ExpoQQModule.moduleInstance?.sendEvent("onLoginFinished", ["success": false])
    }
    
    
    public func getUserInfoResponse(_ response: APIResponse!) {
        let payload = response.jsonResponse.toStringKeyDictionary()
        ExpoQQModule.moduleInstance?.sendEvent("onGetUserInfo", payload)
    }
    
    public func responseDidReceived(_ response: APIResponse!, forMessage message: String!) {
        let payload = response.jsonResponse.toStringKeyDictionary()
        ExpoQQModule.moduleInstance?.sendEvent("onShareFinished", payload)
    }
}


extension Dictionary where Key == AnyHashable {
    func toStringKeyDictionary() -> [String: Any] {
        var result = [String: Any]()
        for (key, value) in self {
            if let stringKey = key.base as? String {
                result[stringKey] = value
            }
        }
        return result
    }
}
