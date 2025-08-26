export type ExpoQQModuleEvents = {
  onLoginFinished: (params: LoginAccessTokenInfo) => void;
  onGetUserInfo: (params: any) => void;
  onShareFinished: (params: any) => void;
};

export type LoginAccessTokenInfo = {
  openId?: string;
  accessToken?: string;
  expirationDate?: number;
  success: boolean;
  errorCode?: number;
  errorMessage?: string;
  errorDetail?: string;
  userCancalled?: boolean;
};

export type LoginFailedEventPayload = {
  userCancalled?: boolean;
};

export type KnownLoginPermissions =
  | "get_user_info"
  | "get_simple_userinfo"
  | "add_t"
  | "all";

export type LoginPermissions =
  | KnownLoginPermissions
  | Omit<string, keyof KnownLoginPermissions>;

/// 分享目标平台，分享到QQ或者QQ空间
export type SharePlatform = "qq" | "qzone";

/// 链接指向的远端资源的内容类型
export enum URLTargetContentType {
  notSpecified,
  audio,
  video,
  news,
}

export type ShareContentOptions = {
  imageBase64OrImageUri: string;
  previewImageBase64OrImageUri?: string;
  title?: string;
  description?: string;
  extraImageList?: string[];
  platform?: SharePlatform;
};

export type ShareVideoOptions = {
  url: string;
  title?: string;
  description?: string;
  previewImageURL: string;
  targetContentType?: keyof typeof URLTargetContentType;
  platform?: SharePlatform;
};
