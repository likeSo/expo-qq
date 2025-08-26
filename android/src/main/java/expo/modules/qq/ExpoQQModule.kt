package expo.modules.qq

import androidx.core.os.bundleOf
import com.tencent.connect.UserInfo
import com.tencent.connect.share.QQShare
import com.tencent.open.utils.HttpUtils
import com.tencent.tauth.IRequestListener
import com.tencent.tauth.IUiListener
import com.tencent.tauth.Tencent
import com.tencent.tauth.UiError
import expo.modules.kotlin.Promise
import expo.modules.kotlin.exception.CodedException
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import org.json.JSONException
import org.json.JSONObject
import java.io.IOException
import java.lang.Exception
import java.net.MalformedURLException
import java.net.SocketTimeoutException
import java.net.URL

val notRegisteredException =
    CodedException("NOT_REGISTERED_ERR", "Please call init function first!", null)

class ExpoQQModule : Module() {

    companion object {
        var moduleInstance: ExpoQQModule? = null
    }

    var tencent: Tencent? = null

    override fun definition() = ModuleDefinition {
        // Sets the name of the module that JavaScript code will use to refer to the module. Takes a string as an argument.
        // Can be inferred from module's class name, but it's recommended to set it explicitly for clarity.
        // The module will be accessible from `requireNativeModule('ExpoQQ')` in JavaScript.
        Name("ExpoQQ")

        OnCreate {
            moduleInstance = this@ExpoQQModule
        }

        OnDestroy {
            moduleInstance = null
        }

        // Sets constant properties on the module. Can take a dictionary or a closure that returns a dictionary.
        Constants(
            "PI" to Math.PI
        )

        // Defines event names that the module can send to JavaScript.
        Events("onLoginFinished", "onGetUserInfo", "onShareFinished")

        AsyncFunction("init") { appId: String, universalLink: String ->
            tencent = Tencent.createInstance(appId, appContext.reactContext)
        }

        AsyncFunction("login") { permissions: Array<String>, promise: Promise ->
            if (tencent != null) {
                val scope = permissions.joinToString(",")
                val listener = LoginListenerProxy()
                return@AsyncFunction tencent?.login(appContext.currentActivity, scope, listener)
            } else {
                throw notRegisteredException
            }
        }

        AsyncFunction("loginByQRCode") { permissions: Array<String> ->
            if (tencent != null) {
                val scope = permissions.joinToString(",")
                val listener = LoginListenerProxy()
                return@AsyncFunction tencent?.login(
                    appContext.currentActivity,
                    scope,
                    listener,
                    true
                )
            } else {
                throw notRegisteredException
            }
        }

        AsyncFunction("getLoginTokenInfo") {
            if (tencent != null) {
                val expirationDate = tencent!!.expiresIn * 1000
                return@AsyncFunction mapOf(
                    "openId" to tencent!!.openId,
                    "accessToken" to tencent!!.accessToken,
                    "expirationDate" to expirationDate
                )
            } else {
                throw notRegisteredException
            }
        }

        AsyncFunction("sendGetUserInfoReq") {
            if (tencent != null) {
                if (tencent!!.isSessionValid) {
                    val userInfo = UserInfo(appContext.reactContext, tencent!!.qqToken)

                    userInfo.getUserInfo(object : IUiListener {
                        override fun onComplete(p0: Any?) {
                            if (p0 is JSONObject) {
                                val camelCasedMap = convertJsonKeysToCamelCase(p0)
                                sendEvent("onGetUserInfo", camelCasedMap)
                            }
                        }

                        override fun onError(p0: UiError?) {
                            // TODO: 错误处理，跟iOS保持统一
                        }

                        override fun onCancel() {

                        }

                        override fun onWarning(p0: Int) {

                        }
                    })
                    return@AsyncFunction true
                } else {
                    throw CodedException(
                        "ERR_NOT_LOGIN",
                        "Before you get user info, you should login first",
                        null
                    )
                }
            } else {
                throw notRegisteredException
            }
        }

        AsyncFunction("sharePlainText") { txt: String ->
            return@AsyncFunction false
        }

        AsyncFunction("shareImage") { options: ShareContentOptions ->
            if (tencent != null) {
                val isLocalUri = options.imageBase64OrImageUri.startsWith("file://")
                val imageUriKey =
                    if (isLocalUri) QQShare.SHARE_TO_QQ_IMAGE_LOCAL_URL else QQShare.SHARE_TO_QQ_IMAGE_LOCAL_URL
                val bundle =
                    bundleOf(
                        QQShare.SHARE_TO_QQ_KEY_TYPE to QQShare.SHARE_TO_QQ_TYPE_DEFAULT,
                        QQShare.SHARE_TO_QQ_TITLE to options.title,
                        QQShare.SHARE_TO_QQ_SUMMARY to options.description,
                        imageUriKey to options.imageBase64OrImageUri,
                        QQShare.SHARE_TO_QQ_APP_NAME to options.appName,
                        QQShare.SHARE_TO_QQ_TARGET_URL to options.targetUrl
                    )
                val listener = object : IUiListener {
                    override fun onComplete(p0: Any?) {
                        if (p0 is JSONObject) {
                            val camelCasedMap = convertJsonKeysToCamelCase(p0)
                            sendEvent("onShareFinished", camelCasedMap)
                        }
                    }

                    override fun onError(p0: UiError?) {
                    }

                    override fun onCancel() {
                    }

                    override fun onWarning(p0: Int) {
                    }
                }
                if (options.platform == "qzone") {
                    tencent?.shareToQzone(appContext.currentActivity, bundle, listener)
                } else {
                    tencent?.shareToQQ(appContext.currentActivity, bundle, listener)
                }
            } else {
                throw notRegisteredException
            }
        }
    }
}


class LoginListenerProxy : IUiListener {
    override fun onComplete(p0: Any?) {
        if (p0 is JSONObject) {
            val camelCaseMap = convertJsonKeysToCamelCase(p0).toMutableMap()
            camelCaseMap["success"] = true
            ExpoQQModule.moduleInstance?.sendEvent("onLoginFinished", camelCaseMap)
        }
    }

    override fun onError(p0: UiError?) {
        ExpoQQModule.moduleInstance?.sendEvent(
            "onLoginFinished",
            mapOf(
                "success" to false,
                "errorCode" to p0?.errorCode,
                "errorMessage" to p0?.errorMessage,
                "errorDetail" to p0?.errorDetail
            )
        )
    }

    override fun onCancel() {
        ExpoQQModule.moduleInstance?.sendEvent(
            "onLoginFinished",
            mapOf("userCancalled" to true, "success" to false)
        )
    }

    override fun onWarning(p0: Int) {

    }

}


private fun convertJsonKeysToCamelCase(json: JSONObject): Map<String, Any?> {
    return json.keys().asSequence().associate { key ->
        val camelKey = snakeToCamel(key) // 调用之前的 snake_case 转 camelCase 函数
        val value = json.get(key)
        // 递归处理嵌套的 JSONObject 或 JSONArray
        camelKey to when (value) {
            is JSONObject -> convertJsonKeysToCamelCase(value)
            else -> value
        }
    }
}

private fun snakeToCamel(str: String): String {
    return str.replace(Regex("_([a-z])")) {
        it.groupValues[1].uppercase()
    }
}