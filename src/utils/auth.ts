import jwt, { SignOptions } from "jsonwebtoken";
import { environment } from "../config/environment";
import { logger } from "../config/logger";

export const signJWT = (
  payload: Object,
  key: "accessTokenPrivateKey" | "refreshTokenPrivateKey",
  options: SignOptions = {}
) => {
  try {
    const privateKey = Buffer.from(environment[key], "base64").toString(
      "ascii"
    );
    return jwt.sign(payload, privateKey, {
      ...(options && options),
      algorithm: "RS256",
    });
  } catch (err) {
    logger.error(err);
    return null as any;
  }
};

export const verifyJWT = <T>(
  token: string,
  key: "accessTokenPublicKey" | "refreshTokenPublicKey"
) => {
  try {
    const publicKey = Buffer.from(environment[key], "base64").toString("ascii");
    return jwt.verify(token, publicKey) as T;
  } catch (err) {
    logger.error(err);
    return null;
  }
};

export const signToken = (id: any) => {
  const accessToken = signJWT({ sub: id }, "accessTokenPrivateKey", {
    expiresIn: `${environment.accessTokenExpiresIn}m`,
  });

  const refreshToken = signJWT({ sub: id }, "refreshTokenPrivateKey", {
    expiresIn: `${environment.refreshTokenExpiresIn}m`,
  });

  return { accessToken, refreshToken };
};
