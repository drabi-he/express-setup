# Overview

This Repository is for the step-by-step guide to create a simple ExpressJS Server with TypeScript.
Its intended to be used as a template for future projects. as well as have many branches for different types of projects and use cases.

# Getting Started

## Prerequisites

- `NodeJS`
- NPM or Yarn or `PNPM` (I use PNPM)

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
- [using mongodb with mongoose](https://github.com/drabi-he/express-setup/tree/mongodb#using-mongodb-with-mongoose)
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

    pnpm add express dotenv-safest cors

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

    touch src/config/logger.ts

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

    pnpm add morgan
    pnpm add -D @types/morgan

**2. create a `logger.ts` file in your `config` folder**

    touch src/config/logger.ts # if it doesn't exist

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
      "[:remote-addr] Completed :method :url :status :res[content-length] in :response-time ms",
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

**3. update our `.env.example` file**

    NODE_ENV=
    PORT=
    ACCESS_TOKEN_PRIVATE_KEY=
    ACCESS_TOKEN_PUBLIC_KEY=
    REFRESH_TOKEN_PRIVATE_KEY=
    REFRESH_TOKEN_PUBLIC_KEY=

**4. update our `environment.ts` file**

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

**5. create an `auth.ts` file in your `utils` folder**

    touch src/utils/auth.ts

**6. add the following to your `auth.ts` file**

    import jwt, { SignOptions } from "jsonwebtoken"
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
    }

congratulations you have created finished all preparations for authentication, to see an example of how to use it check the [next section](https://github.com/drabi-he/express-setup/tree/mongodb#using-mongodb-with-mongoose)

## Script

> :bulb: **You Can Use This Command to help you setup the project**
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/drabi-he/express-setup/master/setup.sh)"
```