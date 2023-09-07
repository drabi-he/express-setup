# Overview

This Repository is for the step-by-step guide to create a simple ExpressJS Server with TypeScript.
Its intended to be used as a template for future projects. as well as have many branches for different types of projects and use cases.

# Getting Started

## Prerequisites

- `NodeJS`
- NPM or Yarn or `PNPM` (I use PNPM)
- Docker & Docker Compose 

## Project Structure


    -- [folder name]\ (i usually choose backend or server)
      -- tools\ (contain your scripts certificates ... )
      -- uploads\ (if you have any kind of upload service it would be best to direct all of them to this folder and make it static)
      -- .env (contain your sensitive information such as API Keys, Secrets ...)
      -- .env.example (contain the keys to your `.env` file variables)
      -- .gitignore (contain files and folder that shouldn't be pushed to your remote repository)
      -- src\ (contains all your logic)
        -- main.ts (this is where you start your server)
        -- common\
        -- config\
        -- middleware\
        -- routes\
        -- models\
          -- index.ts (this is optional but it will make it easier to import all your models)
          -- [...]
        -- utils\
        -- [...]
      -- [...]


> :warning: **Your `tools` Folder And `.env` file may contain very sensitive information so you should always add them to your `.gitignore` file**

## Useful commands

- `pnpm init`: initialize a new project (you can use `npm init` or `yarn init` if you don't use `pnpm`)
- `pnpm add [package name]`: add a package to your project  (you can use `npm install [package name]` or `yarn add [package name]` if you don't use `pnpm`)
- `pnpm add -D [package name]`: add a dev dependency to your project  (you can use `npm install -D [package name]` or `yarn add -D [package name]` if you don't use `pnpm`)
- `pnpm run [script name]`: run a script from your `package.json` file (you can use `npm run [script name]` or `yarn run [script name]` if you don't use `pnpm`)


## Table Of Contents

- [Simple Express Server With Typescript](https://github.com/drabi-he/express-setup#simple-express-server-with-typescript)
- [Adding Useful Services/Middleware](https://github.com/drabi-he/express-setup#adding-useful-servicesmiddleware)
- [Access Token And Refresh Token](https://github.com/drabi-he/express-setup#access-token-and-refresh-token)
- [Using Mongodb With Mongoose](https://github.com/drabi-he/express-setup/tree/mongodb#using-mongodb-with-mongoose)
- [Authentication With JWT And Role Based Access Control](https://github.com/drabi-he/express-setup/tree/mongodb#authentication-with-jwt-and-role-based-access-control)

- [Script](https://github.com/drabi-he/express-setup#script)


## Simple Express Server With Typescript

**1. initialize a  new project**
    
    mkdir backend && cd backend

    pnpm init

**2. go to your `package.json` file and add the following to your `scripts` object**

    "build": "npx tsc",
    "start": "node dist/main.js",
    "dev": "npx tsc && concurrently \"tsc -w\" \"nodemon dist/main.js\""

**3. change the `main` property to `dist/main.js`**

**4. add dependencies/packages**

    pnpm add express dotenv-safest cors**

- `express`: is a web framework for nodejs that makes it easier to create a server and handle requests and responses
- `dotenv-safest`: is a package that helps you load your environment variables from a `.env` file
- `cors`: is a package that helps you handle cors errors

**5. add dev dependency this include type definitions to avoid any errors**

    pnpm add -D typescript ts-node nodemon concurrently @types/express @types/cors @types/node

> :bulb: **Some Packages Includes their type definitions by default so you won't need to add any as dev dependency**

> :bulb: **check [npmjs.com](www.npmjs.com) to find if a package include a type Definition or not**

> :bulb: **if you see `DT` beside it's name then it needs a type definition, if you see `TS` beside it's name then it's already included

**6. setup typescript**

    npx tsc --init

**7. `tsconfig.json` file configuration**

    line 58 `"outDir": "./dist",`

**8. create a `.gitignore` file**

    touch .gitignore

**9. add the following to your `.gitignore` file**

    node_modules/
    dist
    .env

**10. create a `.env` file**

    touch .env

**11. add the following to your `.env` file**

    NODE_ENV=development
    PORT=3000

**12. create a `.env.example` file**

    touch .env.example

**13. add the following to your `.env.example` file**

    NODE_ENV=
    PORT=

**14. create you project structure as you see fit or follow the one in this repository**

    mkdir -p src/{common,config,middleware,routes,models,utils} tools uploads && touch src/main.ts

**15. create an `environment.ts` file in your `config` folder**

    touch src/config/environment.ts

**16. add the following to your `environment.ts` file**

    import { config } from "dotenv-safest";
  
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
    } = {
      nodeEnv: process.env.NODE_ENV || "development",
      port: parseInt(process.env.PORT || "3000"),
    };

**17. go to your `main.ts` file and add the following**

    import express from "express";
    import cors from "cors";
    import { environment } from "./config/environment";


    const app = express();

    app.use(cors());
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));

    app.get("/", (req, res) => {
      res.send("Hello World");
    });

    app.listen(environment.port, () => {
      console.log(`Server is running on port ${environment.port}`);
    });

**18. run your server**
  
    pnpm run dev

congratulations you have created your first express server with typescript

## Adding Useful Services/Middleware

### Multer

**1. add the following packages**

    pnpm add multer @types/multer

**2. create a `multer.ts` file in your `config` folder**

    touch src/config/multer.ts

**3. add the following to your `multer.ts` file**

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

> :bulb: **you can change the `destination` and `filename` to your liking, you can also choose file size and accepted format**

**4. go to your `main.ts` file and add the following**

    import { upload } from "./config/multer";

**5. create a `uploads.ts` file in your `routes` folder**

    touch src/routes/uploads.ts

**6. add the following to your `uploads.ts` file**

    import { Router } from "express";
    import { upload } from "../config/multer";

    const router = Router();

    router.post("/", upload.single("file"), (req, res) => {
      res.send(req.file);
    });

    export default router;

**7. go to your `main.ts` file and add the following**

    import uploadRouter from "./routes/uploads";

**8. go to your `main.ts` file and add the following**

    app.use("/uploads", uploadRouter);

**Notice:**

you can use the middleware directly in your routes like this

    router.post("/user", upload.single("file"), (req, res) => {
      res.send(req.file);
    });

this way you can directly add image to your user without having to create a new route

**9. go to your `main.ts` file and add the following**

    app.use("/uploads", express.static("uploads"));

> :bulb: **you can use [Postman](https://www.postman.com/) to test your server**

### Winston

**1. add the following packages**

    pnpm add winston

**2. create a `logger.ts` file in your `config` folder**

    touch src/config/logger.ts # if it doesn't exist

**3. add the following to your `logger.ts` file**

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

**4. go to your `main.ts` file and add the following**

    import { logger } from "./config/logger";

**5. now you can use `logger` anywhere in your project**

    logger.info("Hello World");
    logger.warn("Hello World");
    logger.error("Hello World");

### Morgan

**1. add the following packages**

    pnpm add morgan @types/morgan

**2. create a `logger.ts` file in your `config` folder**

    touch src/config/logger.ts

**3. add the following to your `logger.ts` file**

    import morgan from "morgan";

    export const requestInfo = morgan(
      "[:date[iso] :remote-addr] Started :method :url"
    )

    export const responseInfo = morgan(
      "[:date[iso] :remote-addr] Completed :status :res[content-length] in :response-time ms"
    )

**Notice:**

we can have a better logger if we combine them

    const stream = {
      write: (message: string) => {
        const status = parseInt(message.split(" ")[2]);
        if (status >= 400) logger.error(message.trim());
        else logger.info(message.trim());
      }
    };

    export const requestInfo = morgan(
      "[:remote-addr] Started :method :url",
      { stream }
    )

    export const responseInfo = morgan(
      "[:remote-addr] Completed :status :res[content-length] in :response-time ms",
      { stream }
    )

**4. go to your `main.ts` file and add the following**

    import { requestInfo, responseInfo } from "./config/logger";

**5. go to your `main.ts` file and add the following**

    app.use(requestInfo);
    app.use(responseInfo);


## Access Token And Refresh Token

**1. add the following packages**

    pnpm add jsonwebtoken bcryptjs @types/jsonwebtoken @types/bcryptjs

**2. generate our secrets and update our `.env`**

    echo "ACCESS_TOKEN_EXPIRES_IN=15" >> .env # access token expiration in minutes
    echo "REFRESH_TOKEN_EXPIRES_IN=10080" >> .env # refresh token expiration in minutes
    echo -n "ACCESS_TOKEN_PRIVATE_KEY=" >> .env
    openssl genrsa -out tools/access_token.pem 2048 && cat tools/access_token.pem | base64 | tr -d '\n' >> .env # generate access token private key
    echo >> .env
    echo -n "ACCESS_TOKEN_PUBLIC_KEY=" >> .env
    openssl rsa -in tools/access_token.pem -pubout -out tools/public_access.pem && cat tools/public_access.pem | base64 | tr -d '\n' >> .env # generate access token public key
    echo >> .env
    echo -n "REFRESH_TOKEN_PRIVATE_KEY=" >> .env
    openssl genrsa -out tools/refresh_token.pem 2048 && cat tools/refresh_token.pem | base64 | tr -d '\n' >> .env # generate refresh token private key
    echo >> .env
    echo -n "REFRESH_TOKEN_PUBLIC_KEY=" >> .env
    openssl rsa -in tools/refresh_token.pem -pubout -out tools/public_refresh.pem && cat tools/public_refresh.pem | base64 | tr -d '\n' >> .env # generate refresh token public key
    echo >> .env

**3. update our `environment.ts` file**

    import { config } from "dotenv-safest";
  
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
      accessTokenExpiresIn: number;
      refreshTokenExpiresIn: number;
      accessTokenPrivateKey: string;
      refreshTokenPrivateKey: string;
      accessTokenPublicKey: string;
      refreshTokenPublicKey: string;
    } = {
      nodeEnv: process.env.NODE_ENV || "development",
      port: parseInt(process.env.PORT || "3000"),
      accessTokenExpiresIn: parseInt(process.env.ACCESS_TOKEN_EXPIRES_IN || "15"),
      refreshTokenExpiresIn: parseInt(process.env.REFRESH_TOKEN_EXPIRES_IN || "60"),
      accessTokenPrivateKey: process.env.ACCESS_TOKEN_PRIVATE_KEY || "",
      refreshTokenPrivateKey: process.env.REFRESH_TOKEN_PRIVATE_KEY || "",
      accessTokenPublicKey: process.env.ACCESS_TOKEN_PUBLIC_KEY || "",
      refreshTokenPublicKey: process.env.REFRESH_TOKEN_PUBLIC_KEY || "",
    };

**4. create an `auth.ts` file in your `utils` folder**

    touch src/utils/auth.ts

**5. add the following to your `auth.ts` file**

    import jwt, { SignOptions } from "jsonwebtoken"
    import { Request } from "express";
    import {environment} from "../config/environment"

    export const signJWT = (
      payload: Object,
      key: "accessTokenPrivateKey" | "refreshTokenPrivateKey",
      options: SignOptions = {}
    ) => {
      const privateKey = Buffer.from(environment[key], "base64").toString("ascii");
      return jwt.sign(payload, privateKey, {
        ...(options && options),
        algorithm: "RS256"
      });
    }

    export const verifyJWT = <T>(
      token: string,
      key: "accessTokenPublicKey" | "refreshTokenPublicKey"
    ) => {
      try {
        const publicKey = Buffer.from(environment[key], "base64").toString("ascii");
        return jwt.verify(token, publicKey) as T;
      } catch (err) {
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
    }

## Using MongoDB With Mongoose

**1. prepare your docker compose file**

    touch docker-compose.yml

**2. update your `.env` file to include mongodb variables**

    echo "MONGO_INITDB_ROOT_USERNAME=admin" >> .env
    echo "MONGO_INITDB_ROOT_PASSWORD=secret" >> .env
    echo "MONGO_URL=mongodb://admin:secret@localhost:27017/mydb?authSource=admin" >> .env

**3. update your `.env.example` file to include mongodb variables**

    echo "MONGO_INITDB_ROOT_USERNAME=" >> .env.example
    echo "MONGO_INITDB_ROOT_PASSWORD=" >> .env.example
    echo "MONGO_URL=" >> .env.example

**4. add the following to your `docker-compose.yml` file**

    version: "3.8"
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

**5. run your docker compose file**

    docker compose up --build
    #OR
    docker-compose up --build

**6. add the following to your `.gitignore` file**

    echo "data" >> .gitignore

**7. install mongoose**

    pnpm add mongoose

**8. update your `config/environment.ts` file**

    import { config } from "dotenv-safest";
  
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
    } = {
      nodeEnv: process.env.NODE_ENV || "development",
      port: parseInt(process.env.PORT || "3000"),
      mongoUrl: process.env.MONGO_URL || "",
    };

**8. create a `database.ts` file in your `config` folder**

    touch src/config/database.ts

**9. add the following to your `database.ts` file**

    import mongoose from "mongoose";

    export const dbConnect = mongoose.connect;

**10. update your `main.ts` file**

    import express from "express";
    import cors from "cors";
    import { dbConnect } from "./config/database";
    import { environment } from "./config/environment";
    import { requestInfo, responseInfo, logger } from "./config/logger";

    const app = express();

    app.use(cors());
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));
    app.use(requestInfo);
    app.use(responseInfo);

    app.use((req, res, next) => {
      logger.info(`${req.method} ${req.url}`);
      next();
    });

    app.get("/", (req, res) => {
      res.send("Hello World");
    });

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
      });

## Authentication With JWT And Role Based Access Control 

**1. create a `user.ts` file in your `models` folder**

    touch src/models/user.ts

**2. add the following to your `user.ts` file**

    import { Schema, model } from "mongoose";

    export interface IUser {
      username: string;
      email: string;
      password: string;
      role: "user" | "admin";
      refreshToken: string | null;
      [...]
    }

    const userSchema = new Schema<IUser>({
      username: { type: String, required: true, unique: true },
      email: { type: String, required: true, unique: true },
      password: { type: String, required: true },
      role: { type: String, enum: ["user", "admin"], default: "user" },
      refreshToken: { type: String, default: null },
      [...]
    });

    export const User = model<IUser>("User", userSchema);

**3. create a `check-existence.ts` file in your `middleware` folder**

    touch src/middleware/check-existence.ts

**4. add the following to your `check-existence.ts` file**

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

**5. create a `access.ts` file in your `middleware` folder**

    touch src/middleware/access.ts

**6. add the following to your `access.ts` file**

    import { Request, Response, NextFunction } from "express";
    import { environment } from '../config/environment';
    import User from "../models/user";

    export const verifyToken = async (req: Request, res: Response, next: NextFunction) => {
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

      const { password, ...rest } = user;
      req.user = rest;

      next();
    }

    export const isAdmin = async (req: Request, res: Response, next: NextFunction) => {
      if (req.user.role !== "admin") {
        return res.status(403).json({ status: "Error", message: "Access Denied, Insufficient Privileges" });
      }

      next();
    }

**4. create a `auth.ts` file in your `routes` folder**

    touch src/routes/auth.ts

**5. add the following to your `auth.ts` file**

    import { Router } from "express";
    import User from "../models/user";
    import { checkExistence } from "../middleware/check-existence";
    import * as bcrypt from "bcryptjs";

    const router = Router();

    router.post("/sign-up",checkExistence, (req, res) => {
      const { password, ...rest } = req.body;

      const passwordHash = await bcrypt.hash(password, 10);

      user = await User.create({
        ...rest,
        password: passwordHash,
      });

      const { accessToken, refreshToken } = signToken(user._id);

      user.refreshToken = await bcrypt.hash(refreshToken, 10);
      await user.save();

      const { password, ...rest } = user;

      res.status(201).json({
        status: "Success",
        message: "User Created Successfully",
        data: {
          user: rest,
          accessToken,
          refreshToken,
        },
      });
    });

    router.post("/sign-in", async (req, res) => {
      const { email, password } = req.body;

      const user = await User.findOne({ $or: [{ email }, { username: email }] });

      if (!user || !(await bcrypt.compare(password, user.password))) {
        return res.status(401).json({ status: "Error", message: "Invalid Credentials" });
      }

      const { accessToken, refreshToken } = signToken(user._id);

      const { password, ...rest } = user;

      res.status(200).json({
        status: "Success",
        message: "User Logged In Successfully",
        data: {
          user: rest,
          accessToken,
          refreshToken,
        },
      });
    })

    router.get("/sign-out", verifyToken, async (req, res) => {
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
    });

    router.get("/current-user", verifyToken, (req, res) => {
      res.status(200).json({
        status: "Success",
        message: "User Found",
        data: {
          user: req.user,
        },
      });
    });

    router.get("/admin-route", verifyToken, isAdmin, (req, res) => {
      res.status(200).json({
        status: "Success",
        message: "Admin Route",
        data: {
          user: req.user,
        },
      });
    });

    export default router;


**6. create a `refresh.ts` file in you `utils` folder**

    touch src/utils/refresh.ts

**7. add the following to your `refresh.ts` file**

      import { Request, Response } from "express";
      import { verifyJWT, signToken } from "./auth";
      import User from "../models/user";

      export const refreshAccessToken = async (req: Request) {
      let refreshToken;

      if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
        refreshToken = req.headers.authorization.split(" ")[1];
      } else if (req.cookies && req.cookies.refreshToken) {
        refreshToken = req.cookies.refreshToken;
      } else if (req.headers["x-refresh-token"]) {
        refreshToken = req.headers["x-refresh-token"];
      }

      if (!refreshToken) {
        return null;
      }

      const decode = verifyJWT<{ sub: string }>(refreshToken, "refreshTokenPublicKey");

      if (!decode) {
        return null;
      }

      const { sub } = decode;

      const user = await User.findById(sub);

      if (!user || !(await bcrypt.compare(refreshToken, user.refreshToken))) {
        return null;
      }

      const { accessToken, refreshToken: newRefreshToken } = signToken(user._id);

      user.refreshToken = await bcrypt.hash(newRefreshToken, 10);

      await user.save();

      return { accessToken, refreshToken: newRefreshToken };
    }

**8. update your `auth.ts` file in your `router` folder**

    router.get("/refresh-token", (req, res) => {
      const { accessToken, refreshToken } = refreshAccessToken(req);

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

**9. update your `main.ts` file**

    [...]
    import AuthRouter from "./routes/auth";
    [...]

    app.use("/api/auth", AuthRouter);
      
      [...]

**10. test your routes using [Postman](https://www.postman.com/)**
      
      # sign up
      POST http://localhost:3000/api/auth/sign-up
      Content-Type: application/json
  
      {
        "username": "username",
        "email": "user@user.com",
        "password": "password"
      }

      # sign in
      POST http://localhost:3000/api/auth/sign-in
      Content-Type: application/json
  
      {
        "email": "user@user.com",
        "password": "password"
      }

      # sign out
      GET http://localhost:3000/api/auth/sign-out
      Content-Type: application/json
      Authorization: Bearer [access token]

      # current user
      GET http://localhost:3000/api/auth/current-user
      Content-Type: application/json
      Authorization: Bearer [access token]

      # admin route
      GET http://localhost:3000/api/auth/admin-route
      Content-Type: application/json
      Authorization: Bearer [access token]

      # refresh token
      GET http://localhost:3000/api/auth/refresh-token
      Content-Type: application/json
      Authorization: Bearer [refresh token]

congratulations you have created your first express server with typescript and mongodb with mongoose and authentication with jwt and role based access control. you can now use this as a template for future projects.


## Script

> :bulb: **You Can Use This Command to help you setup the project**
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/drabi-he/express-setup/mongodb/setup.sh)"
```