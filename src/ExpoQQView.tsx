import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoQQViewProps } from './ExpoQQ.types';

const NativeView: React.ComponentType<ExpoQQViewProps> =
  requireNativeView('ExpoQQ');

export default function ExpoQQView(props: ExpoQQViewProps) {
  return <NativeView {...props} />;
}
