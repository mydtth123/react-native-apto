import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-apto' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const Apto = NativeModules.Apto
  ? NativeModules.Apto
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function multiply(a: number, b: number): Promise<number> {
  return Apto.multiply(a, b);
}

export function init(apiKey: string ,baseURL:string, isDev: boolean): Promise<void> {
  return Apto.initial(apiKey,baseURL,isDev);
}

export function startPhoneVerification(phoneNumber: string): Promise<any> {
  return Apto.startPhoneVerification(phoneNumber);
}

export function completeVerificataion(secret: string): Promise<any> {
  return Apto.completeVerificataion(secret);
}

export function createUser(data: any): Promise<any> {
  return Apto.createUser(data);
}

export function startCardFlow(): Promise<any> {
  return Apto.startCardFlow();
}

export function completeSercondaryVerificataion(secret: string): Promise<any> { // this for login flow
  return Apto.completeSercondaryVerificataion(secret);
}

