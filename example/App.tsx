import { useEvent } from "expo";
import ExpoQQ from "expo-qq";
import { useEffect } from "react";
import { Button, SafeAreaView, ScrollView, Text, View } from "react-native";

export default function App() {
  const onLoginFinished = useEvent(ExpoQQ, "onLoginFinished");

  useEffect(() => {
    if (onLoginFinished) {
      console.log("onLoginFinished", onLoginFinished);
    }
  }, [onLoginFinished]);

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.container}>
        <Text style={styles.header}>Expo QQ Example</Text>
        <Group name="Async functions">
          <Button
            title="初始化"
            onPress={async () => {
              await ExpoQQ.init(
                process.env.EXPO_PUBLIC_UNIVERSAL_LINK,
                process.env.EXPO_PUBLIC_UNIVERSAL_LINK
              );
            }}
          />
        </Group>
        <Group name="授权登录">
          <Button
            title="点击登陆"
            onPress={async () => {
              await ExpoQQ.login(["get_user_info"]);
            }}
          />
        </Group>
      </ScrollView>
    </SafeAreaView>
  );
}

function Group(props: { name: string; children: React.ReactNode }) {
  return (
    <View style={styles.group}>
      <Text style={styles.groupHeader}>{props.name}</Text>
      {props.children}
    </View>
  );
}

const styles = {
  header: {
    fontSize: 30,
    margin: 20,
  },
  groupHeader: {
    fontSize: 20,
    marginBottom: 20,
  },
  group: {
    margin: 20,
    backgroundColor: "#fff",
    borderRadius: 10,
    padding: 20,
  },
  container: {
    flex: 1,
    backgroundColor: "#eee",
  },
  view: {
    flex: 1,
    height: 200,
  },
};
