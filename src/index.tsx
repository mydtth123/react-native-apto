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

export function init(apiKey: string, isDev: boolean): Promise<void> {
  return Apto.initial(apiKey, isDev);
}

export function startPhoneVerification(phoneNumber: string): Promise<any> {
    const test_phone= "3132214363"
  return Apto.startPhoneVerification(test_phone);
}

export function completeVerificataion(secret: string): Promise<any> {
  const secret_test = "000000"
  return Apto.completeVerificataion(secret_test);
}
export function createUser(data: any): Promise<any> {
  // const secret_test = "000000"
  return Apto.createUser(data);
}

export function completeSercondaryVerificataion(secret: string): Promise<any> { // this for login flow
    const sec = "1992-06-07"
  return Apto.completeSercondaryVerificataion(secret);
}







// export function onCardFlowStart (token:string,  onFailureCallback:FailedCallback ,
//   onSuccessCallback: SuccessCallback)  {
//   return Apto.onCardFlowStart(token,onFailureCallback, onSuccessCallback);
// }
