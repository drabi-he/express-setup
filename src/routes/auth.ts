import { Router } from "express";
import { User, users } from "../models/user";
import { db } from "../config/database";
import { checkExistence } from "../middleware/check-existence";
import * as bcrypt from "bcryptjs";
import { verifyToken, isAdmin } from "../middleware/access";
import { signToken } from "../utils/auth";
import { eq, or } from "drizzle-orm";
import { refreshAccessToken } from "../utils/refresh";

const router = Router();

router.post("/sign-up", checkExistence, async (req, res) => {
  try {
    const { password: hash, ...rest } = req.body;

    const passwordHash = await bcrypt.hash(hash, 10);

    const user = (
      await db
        .insert(users)
        .values({
          ...rest,
          password: passwordHash,
        })
        .returning()
    )[0];

    console.log({
      body: req.body,
      user,
    });

    const { accessToken, refreshToken } = signToken(user.id);

    user.refreshToken = await bcrypt.hash(refreshToken, 10);

    await db
      .update(users)
      .set({
        refreshToken: user.refreshToken,
      })
      .where(eq(users.id, user.id));

    res.status(201).json({
      status: "Success",
      message: "User Created Successfully",
      data: {
        user: Object.fromEntries(
          Object.entries(user).filter(
            ([k]) => k !== "password" && k !== "refreshToken"
          )
        ),
        accessToken,
        refreshToken,
      },
    });
  } catch (err: any) {
    res.status(500).json({ status: "Error", message: err.message });
  }
});

router.post("/sign-in", async (req, res) => {
  try {
    const { email, password: hash } = req.body;

    const user = await db.query.users.findFirst({
      where: or(eq(users.email, email), eq(users.username, email)),
    });

    if (!user || !(await bcrypt.compare(hash, user.password))) {
      return res
        .status(401)
        .json({ status: "Error", message: "Invalid Credentials" });
    }

    const { accessToken, refreshToken } = signToken(user.id);

    user.refreshToken = await bcrypt.hash(refreshToken, 10);
    await db
      .update(users)
      .set({
        refreshToken: user.refreshToken,
      })
      .where(eq(users.id, user.id));

    res.status(200).json({
      status: "Success",
      message: "User Logged In Successfully",
      data: {
        user: Object.fromEntries(
          Object.entries(user).filter(
            ([k]) => k !== "password" && k !== "refreshToken"
          )
        ),
        accessToken,
        refreshToken,
      },
    });
  } catch (err: any) {
    res.status(500).json({ status: "Error", message: err.message });
  }
});

router.get("/sign-out", verifyToken, async (req: any, res) => {
  try {
    const user = await db.query.users.findFirst({
      where: eq(users.id, req.user.id),
    });

    if (!user) {
      return res
        .status(404)
        .json({ status: "Error", message: "user not found" });
    }

    await db
      .update(users)
      .set({
        refreshToken: null,
      })
      .where(eq(users.id, user.id));

    res.status(200).json({
      status: "Success",
      message: "User Logged Out Successfully",
    });
  } catch (err: any) {
    res.status(500).json({ status: "Error", message: err.message });
  }
});

router.get("/current-user", verifyToken, async (req: any, res) => {
  const { id } = req.user;

  const user = await db.query.users.findFirst({
    where: eq(users.id, id),
    columns: {
      password: false,
      refreshToken: false,
    },
  });

  if (!user)
    return res.status(404).json({ status: "Error", message: "user not found" });

  res.status(200).json({
    status: "Success",
    message: "User Found",
    data: {
      user: req.user,
    },
  });
});

router.get("/refresh-token", async (req, res) => {
  const { accessToken, refreshToken } = await refreshAccessToken(req);

  if (!accessToken || !refreshToken) {
    return res
      .status(401)
      .json({ status: "Error", message: "Invalid Refresh Token" });
  }

  res.status(200).json({
    status: "Success",
    message: "Token Refreshed Successfully",
    data: {
      accessToken,
      refreshToken,
    },
  });
});

router.get("/admin-route", verifyToken, isAdmin, (req: any, res) => {
  res.status(200).json({
    status: "Success",
    message: "Admin Route",
    data: {
      user: req.user,
    },
  });
});

export default router;
