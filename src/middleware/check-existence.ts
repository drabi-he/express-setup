import { Request, Response, NextFunction } from "express";
import { User, users } from "../models/user";
import { db } from "../config/database";
import { like } from "drizzle-orm";

export const checkExistence = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    let user = await db.query.users.findFirst({
      where: like(users.email, req.body.email),
    });

    if (user) {
      return res
        .status(400)
        .json({ status: "Error", message: "email already taken" });
    }

    user = await db.query.users.findFirst({
      where: like(users.username, req.body.username),
    });

    if (user) {
      return res
        .status(400)
        .json({ status: "Error", message: "username already taken" });
    }
    next();
  } catch (err: any) {
    res.status(500).json({ status: "Error", message: err.message });
  }
};
