import {
  AndroidConfig,
  ConfigPlugin,
  withAndroidManifest,
  withInfoPlist,
} from "expo/config-plugins";

const withExpoQQ: ConfigPlugin<{ appId: string | null | undefined }> = (
  config,
  { appId }
) => {
  if (appId != undefined && appId != null && appId.length > 0) {
    config = withAndroidManifest(config, (config) => {
      const mainApplication = AndroidConfig.Manifest.getMainApplicationOrThrow(
        config.modResults
      );

      let activities = mainApplication.activity ?? [];
      const authActivityExists = activities.some((activity) => {
        return activity.$["android:name"] === "com.tencent.tauth.AuthActivity";
      });
      if (!authActivityExists) {
        activities.push(
          {
            $: {
              "android:name": "com.tencent.tauth.AuthActivity",
              "android:exported": "true",
              "android:launchMode": "singleTask",
              "android:noHistory": "true",
            },
            "intent-filter": [
              {
                action: [
                  {
                    $: {
                      "android:name": "android.intent.action.VIEW",
                    },
                  },
                ],
                category: [
                  {
                    $: {
                      "android:name": "android.intent.category.DEFAULT",
                    },
                  },
                  {
                    $: {
                      "android:name": "android.intent.category.BROWSABLE",
                    },
                  },
                ],
                data: [
                  {
                    $: {
                      "android:scheme": appId,
                    },
                  },
                ],
              },
            ],
          },
          {
            $: {
              "android:name": "com.tencent.connect.common.AssistActivity",
              "android:configChanges": "orientation|keyboardHidden|screenSize",
              "android:screenOrientation": "behind",
              "android:theme": "@android:style/Theme.Translucent.NoTitleBar",
            },
          }
        );
      }

      return config;
    });
  }

  config = withInfoPlist(config, (config) => {
    let queriesSchemes = config.modResults.LSApplicationQueriesSchemes ?? [];
    queriesSchemes.unshift(
      "mqq",
      "mqqapi",
      "tim",
      "mqqopensdknopasteboard",
      "mqqopensdknopasteboardios16",
      "mqqopensdkapiV2",
      "mqqOpensdkSSoLogin",
      "mqzone",
      "mqqopensdklaunchminiapp"
    );
    queriesSchemes = [...new Set(queriesSchemes)];
    config.modResults.LSApplicationQueriesSchemes = queriesSchemes;

    return config;
  });

  return config;
};

export default withExpoQQ;
