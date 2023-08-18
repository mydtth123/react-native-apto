import { NativeModules, Platform } from 'react-native';
const LINKING_ERROR = `The package 'react-native-apto' doesn't seem to be linked. Make sure: \n\n` + Platform.select({
  ios: "- You have run 'pod install'\n",
  default: ''
}) + '- You rebuilt the app after installing the package\n' + '- You are not using Expo Go\n';
const AptoNativeSdk = NativeModules.Apto ? NativeModules.Apto : new Proxy({}, {
  get() {
    throw new Error(LINKING_ERROR);
  }
});
function initial(apiKey, baseURL, isDev) {
  return AptoNativeSdk.initial(apiKey, baseURL, isDev);
}
function startPhoneVerification(phoneNumber) {
  return AptoNativeSdk.startPhoneVerification(phoneNumber);
}
function completeVerificataion(secret) {
  return AptoNativeSdk.completeVerificataion(secret);
}
function createUser(data) {
  return AptoNativeSdk.createUser(data);
}
function completeSercondaryVerificataion(secret) {
  // this for login flow
  return AptoNativeSdk.completeSercondaryVerificataion(secret);
}
function closeUserSession() {
  return AptoNativeSdk.closeUserSession();
}
function startCardFlow() {
  return AptoNativeSdk.startCardFlow();
}
function manageCard() {
  return AptoNativeSdk.manageCard();
}
const AptoSDK = {
  initial,
  createUser,
  startPhoneVerification,
  completeVerificataion,
  completeSercondaryVerificataion,
  startCardFlow,
  closeUserSession,
  manageCard
};
export { AptoSDK };
//# sourceMappingURL=index.js.map