import multer from "multer";
import { Request } from "express";

const storage = multer.diskStorage({
  destination: (req: Request, file, cb) => {
    cb(null, "uploads");
  },
  filename: (req: Request, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname.replace(/\s/g, "")}`);
  },
});

export const upload = multer({ storage });
