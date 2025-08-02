import * as React from 'react';

import { ExpoQQViewProps } from './ExpoQQ.types';

export default function ExpoQQView(props: ExpoQQViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
