console.log("AWS Configurations Loaded", import.meta.env.VITE_USER_POOL_ID);
const awsConfig = {
  Auth: {
    Cognito: {// region: process.env.REACT_APP_AWS_REGION,
      userPoolId: import.meta.env.VITE_USER_POOL_ID,
      userPoolClientId: import.meta.env.VITE_USER_POOL_CLIENT_ID,
      loginWith:{
        oauth: {
          domain: import.meta.env.VITE_COGNITO_DOMAIN,
          scopes: ['openid'],
          redirectSignIn: import.meta.env.VITE_REDIRECT_SIGN_IN,
          redirectSignOut: import.meta.env.VITE_REDIRECT_SIGN_OUT,
          responseType: "code",
        },
        username: true,
      },
    }
  },
};

export default awsConfig;
