// Reexport the native module. On web, it will be resolved to ExpoQQModule.web.ts
// and on native platforms to ExpoQQModule.ts
export { default } from './ExpoQQModule';
export { default as ExpoQQView } from './ExpoQQView';
export * from  './ExpoQQ.types';
