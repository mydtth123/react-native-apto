import * as React from 'react';

import { StyleSheet, View, Button, ActivityIndicator } from 'react-native';
import { AptoSDK } from 'react-native-apto';

export default function App() {
  const [loading, setLoading] = React.useState(false);

  React.useEffect(() => {}, []);

  const onTest = async () => {
    setLoading(true);
    const res = await AptoSDK.startPhoneVerification('3132214565');
    console.log('onTest', res);
    setLoading(false);
  };

  const onTestOTP = async () => {
    setLoading(true);
    const res = await AptoSDK.completeVerificataion('000000');
    console.log('onTestOTP ', res);
    setLoading(false);
  };

  const onTestCreate = async () => {
    setLoading(true);
    const data = {
      firstName: 'John',
    };
    const res = await AptoSDK.createUser(data);

    console.log('onTestCreate', res);

    setLoading(false);
  };

  const onVerifyBirthDate = async () => {
    setLoading(true);
    const date = '1992-06-07';
    const res = await AptoSDK.completeSercondaryVerificataion(date);
    console.log('onVerifyBirthDate', res);
    setLoading(false);
  };

  const onStartCardFlow = async () => {
    setLoading(true);
    await AptoSDK.startCardFlow();
    setLoading(false);
  };

  return (
    <View style={styles.container}>
      <Button title="Test start phone" onPress={onTest} />
      <Button title="Test start phone otp" onPress={onTestOTP} />
      <Button title="Test verify birthdate" onPress={onVerifyBirthDate} />
      <Button title="Test start create user" onPress={onTestCreate} />
      <Button title="Test start CardFlow" onPress={onStartCardFlow} />
      {loading ? <ActivityIndicator size={'large'} color={'blue'} /> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
