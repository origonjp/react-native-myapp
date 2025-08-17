import React from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';

type Props = {
  onLogout: () => void;
};

export default function SettingScreen({ onLogout }: Props) {
  return (
    <View style={styles.container}>
      <Text>👤 設定画面</Text>

      <Button title="ログアウト" onPress={onLogout} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});