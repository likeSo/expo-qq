import { NativeModule, requireNativeModule } from 'expo';

import { ExpoQQModuleEvents } from './ExpoQQ.types';

declare class ExpoQQModule extends NativeModule<ExpoQQModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoQQModule>('ExpoQQ');
