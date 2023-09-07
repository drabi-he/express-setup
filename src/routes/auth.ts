import { Router } from "express";
    import User from "../models/user";
    import { checkExistence } from "../middleware/check-existence";
    import * as bcrypt from "bcryptjs";
    import { verifyToken, isAdmin } from "../middleware/access";
    import { signToken } from "../utils/auth";
    import { refreshAccessToken } from "../utils/refresh";

    const router = Router();

    router.post("/sign-up",checkExistence, async (req: any, res) => {
      try{

        const { password: hash, ...rest } = req.body;

        const passwordHash = await bcrypt.hash(hash, 10);

        const user = await User.create({
          ...rest,
          password: passwordHash,
        });

        const { accessToken, refreshToken } = signToken(user._id);

        user.refreshToken = await bcrypt.hash(refreshToken, 10);
        await user.save();

        res.status(201).json({
          status: "Success",
          message: "User Created Successfully",
          data: {
            user: user,
            accessToken,
            refreshToken,
          },
        });
      } catch (err: any) {
        res.status(500).json({ status: "Error", message: err?.message });
      }
    });

    router.post("/sign-in", async (req: any, res) => {
      try {

        const { email, password: hash } = req.body;

        const user = await User.findOne({ $or: [{ email }, { username: email }] });

        if (!user || !(await bcrypt.compare(hash, user.password))) {
          return res.status(401).json({ status: "Error", message: "Invalid Credentials" });
        }

        const { accessToken, refreshToken } = signToken(user._id);

        user.refreshToken = await bcrypt.hash(refreshToken, 10);
        await user.save();

        res.status(200).json({
          status: "Success",
          message: "User Logged In Successfully",
          data: {
            user: user,
            accessToken,
            refreshToken,
          },
        });
      } catch (err: any) {
        res.status(500).json({ status: "Error", message: err?.message });
      }
    })

    router.get("/sign-out", verifyToken, async (req: any, res) => {
      try {

      const user = await User.findById(req.user._id);

      if (!user) {
        return res.status(404).json({ status: "Error", message: "user not found" });
      }

      user.refreshToken = null;
      await user.save();

      res.status(200).json({
        status: "Success",
        message: "User Logged Out Successfully",
      });
      } catch (err: any) {
        res.status(500).json({ status: "Error", message: err?.message });
      }
    });

    router.get("/current-user", verifyToken, async (req: any, res) => {

      const {_id} = req.user;

      const user = await User.findById(_id);
      if (!user)
        return res.status(404).json({ status: "Error", message: "user not found" });
      res.status(200).json({
        status: "Success",
        message: "User Found",
        data: {
          user,
        },
      });
    });

    router.get("/refresh-token", async (req, res) => {
      const { accessToken, refreshToken } = await refreshAccessToken(req);

      if (!accessToken || !refreshToken) {
        return res.status(401).json({ status: "Error", message: "Invalid Refresh Token" });
      }

      res.status(200).json({
        status: "Success",
        message: "Token Refreshed Successfully",
        data: {
          accessToken,
          refreshToken,
        },
      });
    })

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
