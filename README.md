# expo-qq

这是QQ开放平台，Tencent Open API的React Native封装，支持所有QQ开放平台的功能。

> 项目发布初期，建议生产环境谨慎使用，如发现任何问题，可以随时进群交流。

# 安装

```sh
npx expo install expo-qq
```

# 配置

在 `app.json` 中配置你的app id，这将用于自动配置安卓清单文件：

```json
{
  "expo": {
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

# 使用

```ts
import { useEffect } from 'react';
import ExpoQQ from 'expo-qq';


export default function App() {
  /// 监听登录结果
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


# 联系我

本框架积极维护，如有任何问题，欢迎提交issue或者PR。 QQ 群：682911244。

# 线路图

- [ ] 添加日志功能
- [ ] 完善Example