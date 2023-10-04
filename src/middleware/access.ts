import { Response, NextFunction } from "express";
import { User } from "../models/user";
import { verifyJWT } from "../utils/auth";
import { db } from "../config/database";

export const verifyToken = async (
  req: any,
  res: Response,
  next: NextFunction
) => {
  let accessToken;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    accessToken = req.headers.authorization.split(" ")[1];
  } else if (req.cookies && req.cookies.accessToken) {
    accessToken = req.cookies.accessToken;
  } else if (req.headers["x-access-token"]) {
    accessToken = req.headers["x-access-token"];
  }

  if (!accessToken) {
    return res
      .status(401)
      .json({ status: "Error", message: "Access Token is required" });
  }

  const payload = verifyJWT<{ sub: string }>(
    accessToken,
    "accessTokenPublicKey"
  );

  if (!payload) {
    return res
      .status(401)
      .json({ status: "Error", message: "Invalid Access Token" });
  }

  const { sub: id } = payload;

  const user = await db.query.users.findFirst({
    where: (users, { eq }) => eq(users.id, parseInt(id)),
    columns: {
      password: false,
    },
  });

  if (!user) {
    return res
      .status(401)
      .json({ status: "Error", message: "Invalid Access Token" });
  }

  req.user = user;

  next();
};

export const isAdmin = async (req: any, res: Response, next: NextFunction) => {
  if (req.user.role !== "ADMIN") {
    return res.status(403).json({
      status: "Error",
      message: "Access Denied, Insufficient Privileges",
    });
  }

  next();
};
