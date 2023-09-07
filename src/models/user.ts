import { Schema, model } from "mongoose";

    export interface IUser {
      username: string;
      email: string;
      password: string;
      role: "user" | "admin";
      refreshToken: string | null;
    }

    const userSchema = new Schema<IUser>({
      username: { type: String, required: true, unique: true },
      email: { type: String, required: true, unique: true },
      password: { type: String, required: true },
      role: { type: String, enum: ["user", "admin"], default: "user" },
      refreshToken: { type: String, default: null },
    });

    const UserModel = model<IUser>("User", userSchema);

    export default UserModel;
