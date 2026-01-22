# expo-qq

这是QQ开放平台，Tencent Open API的React Native封装，支持所有QQ开放平台的功能。基于TypeScript和最新的Expo Module Api实现，全类型提示支持。


### 安装📦

```sh
npx expo install expo-qq
```

### 配置🔧

在 `app.json` 中配置你的app id，这将用于自动配置安卓清单文件。同时要配置通用链接和URL Scheme等信息：
> 请注意，通用链接并不是在这里写了就生效的，你需要在腾讯后台注册，还需要在你的服务器的.well-known目录下添加`apple-app-site-association`文件，具体可以搜iOS Deep Link看看相关文档。

```json
{
  "expo": {
    "scheme": [
      "tencent+你的腾讯QQ App ID，如tencent12345"
    ],
    "ios": {
      "associatedDomains": ["请在这里配置你的通用链接"]
    },
    "plugins": [
      [
        "expo-qq",
        {
          "appId": "你的腾讯QQ App ID"
        }
      ]
    ]
  }
}
```

添加了这些配置后，执行`npx expo prebuild`，它会自动帮你配置安卓和iOS项目。

### 使用📱

```ts
import { useEffect } from 'react';
import ExpoQQ from 'expo-qq';


export default function App() {
  /// 监听登录结果，你也可以使用ExpoQQ.addListener('onLoginFinished', callback)来实现，但请不要忘记移除监听
  const onLoginFinished = useEvent(ExpoQQ, 'onLoginFinished');

  /// 国内应用需要在用户接受隐私协议后再初始化
  useEffect(() => {
    const init = async () => {
      await ExpoQQ.init('appId', 'universal link')
    }

    init()
  }, [])

  /// 调用qq登陆
  const loginByQQ = async () => {
    await ExpoQQ.login(['get_user_info'])
  }
}

```

### API

#### init

```ts
init(appId: string, universalLink: string | null): Promise<void>
```

初始化QQ SDK。

- **appId**: QQ 应用 ID
- **universalLink**: 应用的 Universal Link

#### login

```ts
login(permissions: LoginPermissions[]): Promise<number>
```

登录QQ。

- **permissions**: 所需权限，尽量只传入所需要的权限
- **返回值**: 接口调用结果。0正常，-1异常。安卓：1使用activity登陆，2使用网页登陆，或者显示下载页面。

#### loginByQRCode

```ts
loginByQRCode(permissions: LoginPermissions[]): Promise<number>
```

二维码登录，该方法会唤起网页端的登录流程。

- **permissions**: 所需权限，尽量只传入所需要的权限
- **返回值**: 接口调用结果。0正常，-1异常。安卓：1使用activity登陆，2使用网页登陆，或者显示下载页面。

#### getLoginTokenInfo

```ts
getLoginTokenInfo(): Promise<LoginAccessTokenInfo>
```

获取登录凭证（Token）信息，此方法需要在登录成功后调用。

- **返回值**: 登录凭证（Token）信息

#### sendGetUserInfoReq

```ts
sendGetUserInfoReq(): Promise<boolean>
```

发送获取用户信息请求，此方法需要在登录成功后调用。

- **返回值**: 接口调用是否成功，如需用户信息回调，请通过事件监听。

#### shareImage

```ts
shareImage(options: ShareContentOptions): Promise<number>
```

分享图文消息到QQ。主图片大小限制5MB，预览图限制1MB，如果超过，会进行压缩。

- **options**: 分享图片的选项
- **返回值**: 分享结果，0 表示成功，其他值表示失败

### 常见问题❓

#### 我使用Exou Router，我的QQ跳回App后，跳到了一个404页面？
这是因为QQ会通过一个类似`tencent1234567://qzapp/xxx`的URL来跳到你的app，而expo router会尝试解析并跳转到`/qzapp`这个路由，但是很显然这个路由并不存在，所以就会显示404，

解决方案，使用Expo Router的[Native Intent](https://docs.expo.dev/router/advanced/native-intent/#rewrite-incoming-native-deep-links)方案，新建`app/+native-intent.tsx`文件，并按照文档，拦截`tencent1234567`这种URL，重定向到你的登录页面即可。


### 联系我📞

本框架积极维护，如有任何问题，欢迎提交issue或者PR。 QQ 群：682911244。

### 线路图🚀

- [ ] 添加日志功能
- [ ] 完善Example


### 鸣谢👏

感谢[pianduan-M](https://github.com/pianduan-M)同学为对本项目的测试和反馈作出的巨大贡献👏。