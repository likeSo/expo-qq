import { NativeModule, requireNativeModule } from "expo";

import { ExpoQQModuleEvents, LoginAccessTokenInfo, LoginPermissions, ShareContentOptions, ShareVideoOptions } from "./ExpoQQ.types";

declare class ExpoQQModule extends NativeModule<ExpoQQModuleEvents> {
  /**
   * 初始化
   * @param appId QQ 应用 ID
   * @param universalLink 应用的 Universal Link
   */
  init(appId: string, universalLink: string | null): Promise<void>;

  /**
   * 登录
   * @param permissions 所需权限，尽量只传入所需要的权限
   * @returns 接口调用结果。0正常，-1异常。安卓：1使用activity登陆，2使用网页登陆，或者显示下载页面。
   */
  login(permissions: LoginPermissions[]): Promise<number>;
  /**
   * 二维码登录，该方法会唤起网页端的登录流程
   * @param permissions 所需权限，尽量只传入所需要的权限
   * @returns 接口调用结果。0正常，-1异常。安卓：1使用activity登陆，2使用网页登陆，或者显示下载页面。
   */
  loginByQRCode(permissions: LoginPermissions[]): Promise<number>;

  /**
   * 获取登录凭证（Token）信息，此方法需要在登录成功后调用。
   * @returns 登录凭证（Token）信息
   */
  getLoginTokenInfo(): Promise<LoginAccessTokenInfo>;

  /**
   * 发送获取用户信息请求，此方法需要在登录成功后调用。
   * @returns 接口调用是否成功，如需用户信息回调，请通过事件监听。
   */
  sendGetUserInfoReq(): Promise<boolean>;

  /**
   * 分享图文消息到QQ。主图片大小限制5MB，预览图限制1MB，如果超过，会进行压缩。
   * @param options 分享图片的选项
   * @returns 分享结果，0 表示成功，其他值表示失败
   */
  shareContent(options: ShareContentOptions): Promise<number>;

}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoQQModule>("ExpoQQ");
