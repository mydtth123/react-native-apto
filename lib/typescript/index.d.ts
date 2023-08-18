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
declare const AptoSDK: NativeNativeSdkType;
export { AptoSDK };
//# sourceMappingURL=index.d.ts.map