import { registerWebModule, NativeModule } from 'expo';

import { ExpoQQModuleEvents } from './ExpoQQ.types';

class ExpoQQModule extends NativeModule<ExpoQQModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoQQModule, 'ExpoQQModule');
