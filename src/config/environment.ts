import { config } from "dotenv-safest";
import { logger } from "./logger";
try {
  config();
} catch (e: any) {
  logger.error({
    message: "Error loading environment variables",
    missing: e?.missing,
  });
  process.exit(1);
}

export const environment: {
  nodeEnv: string;
  port: number;
  accessTokenExpiresIn: number;
  refreshTokenExpiresIn: number;
  accessTokenPrivateKey: string;
  refreshTokenPrivateKey: string;
  accessTokenPublicKey: string;
  refreshTokenPublicKey: string;
  postgresUri: string;
} = {
  nodeEnv: process.env.NODE_ENV || "development",
  port: parseInt(process.env.PORT || "3000"),
  accessTokenExpiresIn: parseInt(process.env.ACCESS_TOKEN_EXPIRES_IN || "15"),
  refreshTokenExpiresIn: parseInt(process.env.REFRESH_TOKEN_EXPIRES_IN || "60"),
  accessTokenPrivateKey: process.env.ACCESS_TOKEN_PRIVATE_KEY || "",
  refreshTokenPrivateKey: process.env.REFRESH_TOKEN_PRIVATE_KEY || "",
  accessTokenPublicKey: process.env.ACCESS_TOKEN_PUBLIC_KEY || "",
  refreshTokenPublicKey: process.env.REFRESH_TOKEN_PUBLIC_KEY || "",
  postgresUri: process.env.POSTGRES_URI || "",
};
