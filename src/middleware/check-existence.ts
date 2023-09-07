import { Request, Response, NextFunction } from "express";
    import User from "../models/user";


    export const checkExistence = async (req: Request, res: Response, next: NextFunction) => {
      let user = await User.findOne({ email: req.body.email });

      if (user) {
        return res.status(400).json({status: "Error", message: "email already taken" });
      }

      user = await User.findOne({ username: req.body.username });

      if (user) {
        return res.status(400).json({status: "Error", message: "username already taken" });
      }

      next();
    }
