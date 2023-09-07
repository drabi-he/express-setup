import { config } from "dotenv-safest";

try {
  config();
} catch (e: any) {
  console.log({
    message: "Error loading environment variables",
    missing: e?.missing,
  });
  process.exit(1);
}

export const environment: {
  nodeEnv: string;
  port: number;
  mongoUrl: string;
  accessTokenExpiresIn: number;
  refreshTokenExpiresIn: number;
  accessTokenPrivateKey: string;
  refreshTokenPrivateKey: string;
  accessTokenPublicKey: string;
  refreshTokenPublicKey: string;
} = {
  nodeEnv: process.env.NODE_ENV || "development",
  port: parseInt(process.env.PORT || "3000"),
  mongoUrl: process.env.MONGO_URL || "",
  accessTokenExpiresIn: parseInt(process.env.ACCESS_TOKEN_EXPIRES_IN || "15"),
  refreshTokenExpiresIn: parseInt(process.env.REFRESH_TOKEN_EXPIRES_IN || "60"),
  accessTokenPrivateKey: process.env.ACCESS_TOKEN_PRIVATE_KEY || "",
  refreshTokenPrivateKey: process.env.REFRESH_TOKEN_PRIVATE_KEY || "",
  accessTokenPublicKey: process.env.ACCESS_TOKEN_PUBLIC_KEY || "",
  refreshTokenPublicKey: process.env.REFRESH_TOKEN_PUBLIC_KEY || "",
};
