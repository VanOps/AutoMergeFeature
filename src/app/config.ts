export const APP_CONFIG = {
  name: 'AutoMerge Feature Test',
  version: '1.0.0',
  environment: process.env.NODE_ENV || 'development',
  features: {
    autoMerge: true,
    ciValidation: true,
  },
  testTimestamp: Date.now(),
};

export default APP_CONFIG;
