import React, { useState,useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import type { RootStackParamList } from './src/types'; // あなたの Stack 定義がある場所に合わせて

import SplashScreen from './src/SplashScreen';
import LoginScreen from './src/LoginScreen';
import SettingScreen from './src/SettingScreen';
import HomeScreen from './src/HomeScreen';
import MainTabs from './src/MainTabs';

import AppNavigator from './src/navigation/AppNavigator';


const Stack = createNativeStackNavigator<RootStackParamList>();

function App() {
  const [isSplashVisible, setIsSplashVisible] = useState(true);
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setIsSplashVisible(false), 2000);
    return () => clearTimeout(timer);
  }, []);

  return (
    <NavigationContainer>
      <Stack.Navigator>
        {isSplashVisible ? (
          <Stack.Screen
            name="Splash"
            component={SplashScreen}
            options={{ headerShown: false }}
          />
        ) : isLoggedIn ? (
          <>
            <Stack.Screen
              name="MainTabs"
              options={{ headerShown: false }}
              component={MainTabs}
            />
            <Stack.Screen name="Setting">
              {(props) => (
                <SettingScreen
                  {...props}
                  onLogout={() => setIsLoggedIn(false)}
                />
              )}
            </Stack.Screen>
          </>
        ) : (
          <Stack.Screen name="Login">
            {() => <LoginScreen onLogin={() => setIsLoggedIn(true)} />}
          </Stack.Screen>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default App;