// import React from 'react';
// import { createDrawerNavigator, DrawerContentScrollView, DrawerItemList, DrawerItem } from '@react-navigation/drawer';
// import MainTabs from '../MainTabs'; // 👈 BottomTabs の定義
// import { View, Text } from 'react-native';

// const Drawer = createDrawerNavigator();

// export default function DrawerNavigator({ onLogout }: { onLogout: () => void }) {
//   return (
//     <Drawer.Navigator
//       drawerContent={(props) => (
//         <DrawerContentScrollView {...props}>
//           <DrawerItemList {...props} />
//           <DrawerItem label="ログアウト" onPress={onLogout} />
//         </DrawerContentScrollView>
//       )}
//     >
//       <Drawer.Screen name="ホーム" component={MainTabs} />
//       {/* 他のDrawer項目を追加する場合はこちらに */}
//     </Drawer.Navigator>
//   );
// }