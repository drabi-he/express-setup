#!/bin/sh

# Folder Name
read -p "Enter root folder name [backend]: " name
name=${name:-backend}
echo "$name"
if mkdir -p "$name"; then
  echo "$name created successfully"
  cd "$name"
else
  echo "Error: $name creation failed." >&2
  exit 1
fi

if ! [ -x "$(command -v node)" ]; then
  echo 'Error: node is not installed.' >&2
  rm -rf ../"$name"
  exit 1
fi

# Package Manager
read -p "Which package manager would you like to use (npm/yarn/pnpm) [npm]: " manager
manager=${manager:-npm}
echo "$manager"

if [ "$manager" != "npm" ] && [ "$manager" != "yarn" ] && [ "$manager" != "pnpm" ]; then
  echo 'Error: invalid package manager.' >&2
    rm -rf ../"$name"
  exit 1
fi

if ! [ -x "$(command -v $manager)" ]; then
  if npm install -g $manager; then
    echo "$manager installed successfully"
  else
    echo "Error: $manager installation failed." >&2
      rm -rf ../"$name"
    exit 1
  fi
fi

if [ "$manager" = "npm" ] || [ "$manager" = "yarn" ]; then
  if "$manager" init -y ; then
    echo "$manager initialized successfully"
  else
    echo "Error: $manager initialization failed." >&2
      rm -rf ../"$name"
    exit 1
  fi
else
  if "$manager" init; then
    echo "$manager initialized successfully"
  else
    echo "Error: $manager initialization failed." >&2
      rm -rf ../"$name"
    exit 1
  fi
fi

# Package Name
if sed -i 's/"main": "index.js"/"main": "dist\/main.js"/g' package.json; then
  echo "package.json main updated successfully"
else
  echo "Error: package.json update failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Package Scripts
if [ "$manager" = "yarn" ]; then 
  if sed -i 's/"license": "MIT"/"license": "MIT",\
  "scripts": {\
    "build": "npx tsc",\
    "start": "node dist\/main.js",\
    "dev": "npx tsc \&\& concurrently \\"tsc -w\\" \\"nodemon dist\/main.js\\""\
  }/g' package.json; then
    echo "package.json scripts updated successfully"
  else
    echo "Error: package.json update failed." >&2
      rm -rf ../"$name"
    exit 1
  fi
else
  if sed -i 's|"test": "echo \\"Error: no test specified\\" && exit 1"|"build": "tsc",\
    "start": "node dist/main.js",\
    "dev": "npx tsc \&\& concurrently \\"tsc -w\\" \\"nodemon dist/main.js\\""|g' package.json; then
    echo "package.json scripts updated successfully"
  else
    echo "Error: package.json update failed." >&2
      rm -rf ../"$name"
    exit 1
  fi
fi

# Package Dependencies
if [ "$manager" = "npm" ]; then
  install="install"
else
  install="add"
fi


packages="express dotenv-safest cors winston morgan multer mongoose jsonwebtoken bcryptjs"

if "$manager" "$install" $packages ; then
  echo "$packages installed successfully"
else
  echo "Error: $packages installation failed." >&2
    rm -rf ../"$name"
  exit 1
fi


devPackages="typescript ts-node @types/node @types/express @types/cors nodemon concurrently @types/morgan @types/multer @types/jsonwebtoken @types/bcryptjs"


# Package Dev Dependencies
if "$manager" "$install" -D $devPackages; then
  echo "$devPackages installed successfully"
else
  echo "Error: $devPackages installation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Typescript Config
if npx tsc --init --outDir dist; then
  echo "tsconfig.json created successfully"
else
  echo "Error: tsconfig.json creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

mkdir -p tools

# Env Config
if touch .env \
&& echo "NODE_ENV=development" > .env \
&& echo "PORT=3000" >> .env \
&& echo "MONGO_INITDB_ROOT_USERNAME=admin" >> .env \
&& echo "MONGO_INITDB_ROOT_PASSWORD=secret" >> .env \
&& echo "MONGO_URL=mongodb://admin:secret@localhost:27017/mydb?authSource=admin"  >> .env\
&& echo "ACCESS_TOKEN_EXPIRES_IN=15" >> .env \
&& echo "REFRESH_TOKEN_EXPIRES_IN=10080" >> .env \
&& echo -n "ACCESS_TOKEN_PRIVATE_KEY=" >> .env
   openssl genrsa -out tools/access_token.pem 2048 && cat tools/access_token.pem | base64 | tr -d '\n' >> .env \
   && echo >> .env\
   && echo -n "ACCESS_TOKEN_PUBLIC_KEY=" >> .env
   openssl rsa -in tools/access_token.pem -pubout -out tools/public_access.pem && cat tools/public_access.pem | base64 | tr -d '\n' >> .env\
   && echo >> .env\
   && echo -n "REFRESH_TOKEN_PRIVATE_KEY=" >> .env
   openssl genrsa -out tools/refresh_token.pem 2048 && cat tools/refresh_token.pem | base64 | tr -d '\n' >> .env \
   && echo >> .env\
   && echo -n "REFRESH_TOKEN_PUBLIC_KEY=" >> .env
   openssl rsa -in tools/refresh_token.pem -pubout -out tools/public_refresh.pem && cat tools/public_refresh.pem | base64 |tr -d '\n' >> .env \
   && echo >> .env ; then
  echo ".env created successfully"
else
  echo "Error: .env creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Env Example Config
if touch .env.example \
&& echo "NODE_ENV=" > .env.example \
&& echo "PORT=" >> .env.example \
&& echo "MONGO_INITDB_ROOT_USERNAME=" >> .env.example \
&& echo "MONGO_INITDB_ROOT_PASSWORD=" >> .env.example \
&& echo "MONGO_URL=" >> .env.example\
&& echo "ACCESS_TOKEN_PRIVATE_KEY=" >> .env.example\
&& echo "ACCESS_TOKEN_PUBLIC_KEY=" >> .env.example\
&& echo "REFRESH_TOKEN_PRIVATE_KEY=" >> .env.example\
&& echo "REFRESH_TOKEN_PUBLIC_KEY=" >> .env.example ; then
  echo ".env.example created successfully"
else
  echo "Error: .env.example creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Docker Compose Config

if touch docker-compose.yml && echo 'version: "3.8"
services:
  mongo:
    image: mongo
    restart: always
    ports:
      - 27017:27017
    volumes:
      - ./data:/data/db
    environment:
      - MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_INITDB_ROOT_PASSWORD}

  mongo-express:
    image: mongo-express
    restart: always
    ports:
      - 8081:8081
    environment:
      - ME_CONFIG_MONGODB_SERVER=mongo
      - ME_CONFIG_MONGODB_ADMINUSERNAME=${MONGO_INITDB_ROOT_USERNAME}
      - ME_CONFIG_MONGODB_ADMINPASSWORD=${MONGO_INITDB_ROOT_PASSWORD}
' > docker-compose.yml; then
  echo "docker-compose.yml created successfully"
else
  echo "Error: docker-compose.yml creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Run Docker Compose
if docker compose up --build -d; then
  echo "docker-compose up successfully"
else
  echo "Error: docker-compose up failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Git Config
if touch .gitignore && echo "node_modules" >> .gitignore && echo ".env" >> .gitignore && echo "dist" >> .gitignore && echo "data" >> .gitignore ; then
  echo ".gitignore created successfully"
else
  echo "Error: .gitignore creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi


# Folder Structure
mkdir -p src/config src/common src/middleware src/models src/routes src/utils uploads

cd src

# Environment Config
if touch config/environment.ts && echo 'import { config } from "dotenv-safest";

try {
  config();
} catch (e: any) {
  console.log({
    message: "Error loading environment variables",
    missing: e?.missing,
  });
  process.exit(1);
}

export const environment: {
  nodeEnv: string;
  port: number;
  mongoUrl: string;
  accessTokenExpiresIn: number;
  refreshTokenExpiresIn: number;
  accessTokenPrivateKey: string;
  refreshTokenPrivateKey: string;
  accessTokenPublicKey: string;
  refreshTokenPublicKey: string;
} = {
  nodeEnv: process.env.NODE_ENV || "development",
  port: parseInt(process.env.PORT || "3000"),
  mongoUrl: process.env.MONGO_URL || "",
  accessTokenExpiresIn: parseInt(process.env.ACCESS_TOKEN_EXPIRES_IN || "15"),
  refreshTokenExpiresIn: parseInt(process.env.REFRESH_TOKEN_EXPIRES_IN || "60"),
  accessTokenPrivateKey: process.env.ACCESS_TOKEN_PRIVATE_KEY || "",
  refreshTokenPrivateKey: process.env.REFRESH_TOKEN_PRIVATE_KEY || "",
  accessTokenPublicKey: process.env.ACCESS_TOKEN_PUBLIC_KEY || "",
  refreshTokenPublicKey: process.env.REFRESH_TOKEN_PUBLIC_KEY || "",
};' > config/environment.ts; then
  echo "config/environment.ts created successfully"
else
  echo "Error: config/environment.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Multer Config

if touch config/multer.ts && echo 'import multer from "multer";
  import { Request } from "express";

  const storage = multer.diskStorage({
    destination: (req: Request, file: Express.Multer.File, cb) => {
      cb(null, "uploads/");
    },
    filename: (req: Request, file: Express.Multer.File, cb) => {
      cb(null, `${Date.now()}-${file.originalname.replace(/\s/g, "")}`);
    },
  });

  export const upload = multer({ storage: storage });
  ' > config/multer.ts; then
  echo "config/multer.ts created successfully"
else
  echo "Error: config/multer.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Logger Config
if touch config/logger.ts && echo 'import morgan from "morgan";
    import { createLogger, format, transports } from "winston";

    export const logger = createLogger({
      level: "info",
      format: format.combine(
        format.timestamp({ format: "YYYY-MM-DD HH:mm:ss:ms" }),
        format.printf(
          (info) => `[${info.timestamp}] ${info.level}: ${info.message}`
        )
      ),
      transports: [
        new transports.Console(),
        new transports.File({ filename: "logs/error.log", level: "error", maxsize: 5242880, maxFiles: 5
         }),
        new transports.File({ filename: "logs/combined.log", maxsize: 5242880, maxFiles: 5 }),
      ],
    });



    const stream = {
      write: (message: string) => {
        const status = parseInt(message.split(" ")[4]);
        if (status >= 400) logger.error(message.trim());
        else logger.info(message.trim());
      }
    };

    export const requestInfo = morgan(
      "[:remote-addr] Started :method :url",
      { stream }
    )

    export const responseInfo = morgan(
      "[:remote-addr] Completed :method :url :status :method :url :res[content-length] in :response-time ms",
      { stream }
    )' > config/logger.ts; then
  echo "config/logger.ts created successfully"
else
  echo "Error: config/logger.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Database Config

if touch config/database.ts && echo 'import mongoose from "mongoose";

    export const dbConnect = mongoose.connect;' > config/database.ts; then
  echo "config/database.ts created successfully"
else
  echo "Error: config/database.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Authentication utils

if touch utils/auth.ts\
&& echo 'import jwt, { SignOptions } from "jsonwebtoken"
    import {environment} from "../config/environment"
    import { logger } from "../config/logger";

    export const signJWT = (
      payload: Object,
      key: "accessTokenPrivateKey" | "refreshTokenPrivateKey",
      options: SignOptions = {}
    ) => {
      try {
        const privateKey = Buffer.from(environment[key], "base64").   toString(
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
    }

    export const signToken = (id: any) => {
      const accessToken = signJWT({ sub: id }, "accessTokenPrivateKey", {
        expiresIn: `${environment.accessTokenExpiresIn}m`
      });

      const refreshToken = signJWT({ sub: id }, "refreshTokenPrivateKey", {
        expiresIn: `${environment.refreshTokenExpiresIn}m`
      });

      return { accessToken, refreshToken };
    }' > utils/auth.ts; then
  echo "utils/auth.ts created successfully"
else
  echo "Error: utils/auth.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# User Model

if touch models/user.ts\
&& echo 'import { Schema, model } from "mongoose";

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

    export default UserModel;' > models/user.ts; then
  echo "models/user.ts created successfully"
else
  echo "Error: models/user.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Middlewares

if touch middleware/check-existence.ts\
&& echo 'import { Request, Response, NextFunction } from "express";
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
    }' > middleware/check-existence.ts; then
  echo "middleware/check-existence.ts created successfully"
else
  echo "Error: middleware/check-existence.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

if touch middleware/access.ts\
&& echo 'import { Response, NextFunction } from "express";
    import User from "../models/user";
    import { verifyJWT } from "../utils/auth";


    export const verifyToken = async (req: any, res: Response, next: NextFunction) => {
      let accessToken;

      if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
        accessToken = req.headers.authorization.split(" ")[1];
      } else if (req.cookies && req.cookies.accessToken) {
        accessToken = req.cookies.accessToken;
      } else if (req.headers["x-access-token"]) {
        accessToken = req.headers["x-access-token"];
      }

      if (!accessToken) {
        return res.status(401).json({ status: "Error", message: "Access Token is required" });
      }

      const payload = verifyJWT<{ sub: string }>(accessToken, "accessTokenPublicKey");

      if (!payload) {
        return res.status(401).json({ status: "Error", message: "Invalid Access Token" });
      }

      const { sub: id } = payload;

      const user = await User.findById(id);

      if (!user) {
        return res.status(401).json({ status: "Error", message: "Invalid Access Token" });
      }

      req.user = user;

      next();
    }

    export const isAdmin = async (req: any, res: Response, next: NextFunction) => {
      if (req.user.role !== "admin") {
        return res.status(403).json({ status: "Error", message: "Access Denied, Insufficient Privileges" });
      }

      next();
    }' > middleware/access.ts; then
  echo "middleware/access.ts created successfully"
else
  echo "Error: middleware/access.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Routes

if touch routes/auth.ts\
&& echo 'import { Router } from "express";
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

    export default router;' > routes/auth.ts; then
  echo "routes/auth.ts created successfully"
else
  echo "Error: routes/auth.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Refresh Utils

if touch utils/refresh.ts\
&& echo 'import { Request, Response } from "express";
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
    }' > utils/refresh.ts; then
  echo "utils/refresh.ts created successfully"
else
  echo "Error: utils/refresh.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Main File
if touch main.ts && echo 'import express from "express";
    import cors from "cors";
    import { dbConnect } from "./config/database";
    import { environment } from "./config/environment";
    import { requestInfo, responseInfo, logger } from "./config/logger";
    import { upload } from "./config/multer";
    import AuthRouter from "./routes/auth";

    const app = express();

    app.use(cors());
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));
    app.use(requestInfo);
    app.use(responseInfo);
    app.use(express.static("uploads"));

    app.get("/", (req, res) => {
      res.send("Hello World");
    });

    app.post("/uploads", upload.single("file"), (req, res) => {
      res.send(`http://localhost:${environment.port}/${req.file?.filename}`);
    });

    app.use("/api/auth", AuthRouter);


    dbConnect(environment.mongoUrl)
      .then(() => {
        logger.info("Connected to database");
        app.listen(environment.port, () => {
          logger.info(`Server is running on port ${environment.port}`);
        });
      })
      .catch((err) => {
        logger.error(err);
        process.exit(1);
      });' > main.ts; then
  echo "main.ts created successfully"
else
  echo "Error: main.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Setup Complete
echo ""
echo ""
echo "Project setup successfully"
echo ""
echo "To start the server, run the following commands:"
echo "    cd $name"
echo "    $manager dev"