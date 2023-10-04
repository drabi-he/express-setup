import { Request, Response } from "express";
import { verifyJWT, signToken } from "./auth";
import { users } from "../models/user";
import { db } from "../config/database";
import * as bcrypt from "bcryptjs";
import { eq } from "drizzle-orm";

export const refreshAccessToken = async (req: Request) => {
  let refreshToken;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    refreshToken = req.headers.authorization.split(" ")[1];
  } else if (req.cookies && req.cookies.refreshToken) {
    refreshToken = req.cookies.refreshToken;
  } else if (req.headers["x-refresh-token"]) {
    refreshToken = req.headers["x-refresh-token"];
  }

  if (!refreshToken) {
    return {
      accessToken: null,
      refreshToken: null,
    };
  }

  const decode = verifyJWT<{ sub: string }>(
    refreshToken,
    "refreshTokenPublicKey"
  );

  if (!decode) {
    return {
      accessToken: null,
      refreshToken: null,
    };
  }

  const { sub } = decode;

  const user = await db.query.users.findFirst({
    where: (users, { eq }) => eq(users.id, parseInt(sub)),
  });

  if (
    !user ||
    !(await bcrypt.compare(refreshToken, user.refreshToken as string))
  ) {
    return {
      accessToken: null,
      refreshToken: null,
    };
  }

  const { accessToken, refreshToken: newRefreshToken } = signToken(user.id);

  user.refreshToken = await bcrypt.hash(newRefreshToken, 10);

  await db
    .update(users)
    .set({
      refreshToken: user.refreshToken,
    })
    .where(eq(users.id, user.id));

  return { accessToken, refreshToken: newRefreshToken };
};
