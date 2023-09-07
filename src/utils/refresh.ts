import { Request, Response } from "express";
      import { verifyJWT, signToken } from "./auth";
      import User from "../models/user";
      import * as bcrypt from "bcryptjs";


      export const refreshAccessToken = async (req: Request) => {
      let refreshToken;

      if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
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

      const decode = verifyJWT<{ sub: string }>(refreshToken, "refreshTokenPublicKey");

      if (!decode) {
        return {
          accessToken: null,
          refreshToken: null,
        };
      }

      const { sub } = decode;

      const user = await User.findById(sub);

      if (!user || !(await bcrypt.compare(refreshToken, user.refreshToken as string))) {
        return {
          accessToken: null,
          refreshToken: null,
        };
      }

      const { accessToken, refreshToken: newRefreshToken } = signToken(user._id);

      user.refreshToken = await bcrypt.hash(newRefreshToken, 10);

      await user.save();

      return { accessToken, refreshToken: newRefreshToken };
    }
