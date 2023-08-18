import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-apto' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const AptoNativeSdk = NativeModules.Apto
  ? NativeModules.Apto
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

function initial(
  apiKey: string,
  baseURL: string,
  isDev: boolean
): Promise<void> {
  return AptoNativeSdk.initial(apiKey, baseURL, isDev);
}

function startPhoneVerification(phoneNumber: string): Promise<any> {
  return AptoNativeSdk.startPhoneVerification(phoneNumber);
}

function completeVerificataion(secret: string): Promise<any> {
  return AptoNativeSdk.completeVerificataion(secret);
}

function createUser(data: any): Promise<any> {
  return AptoNativeSdk.createUser(data);
}

function completeSercondaryVerificataion(secret: string): Promise<any> {
  // this for login flow
  return AptoNativeSdk.completeSercondaryVerificataion(secret);
}
function closeUserSession(): Promise<any> {
  return AptoNativeSdk.closeUserSession();
}

function startCardFlow(): Promise<any> {
  return AptoNativeSdk.startCardFlow();
}
function manageCard(): Promise<any> {
  return AptoNativeSdk.manageCard();
}

type NativeNativeSdkType = {
  initial(apiKey: string, baseURL: string, isDev: boolean): Promise<any>;
  startPhoneVerification(phoneNumber: string): Promise<any>;
  completeVerificataion(secret: string): Promise<any>;
  createUser(data: any): Promise<any>;
  completeSercondaryVerificataion(secret: string): Promise<any>;
  startCardFlow(): Promise<any>;
  manageCard(): Promise<any>;
  closeUserSession(): Promise<any>;
};
const AptoSDK: NativeNativeSdkType = {
  initial,
  createUser,
  startPhoneVerification,
  completeVerificataion,
  completeSercondaryVerificataion,
  startCardFlow,
  closeUserSession,
  manageCard,
};

export { AptoSDK };
