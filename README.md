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

[Simple Express Server With Typescript](https://github.com/drabi-he/express-setup#simple-express-server-with-typescript)
[using mongodb with mongoose](https://github.com/drabi-he/express-setup/tree/mongodb#using-mongodb-with-mongoose)

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

**6. extra packages that may be helpful**

    pnpm add -D morgan @types/morgan

- `morgan`: is a logger middleware for express 

**7. setup typescript**

    npx tsc --init

**8. `tsconfig.json` file configuration**

    line 58 `"outDir": "./dist",`

**9. create a `.gitignore` file**

    touch .gitignore

**10. add the following to your `.gitignore` file**

    node_modules/
    dist
    .env

**11. create a `.env` file**

    touch .env

**12. add the following to your `.env` file**

    NODE_ENV=development
    PORT=3000

**14. create a `.env.example` file**

    touch .env.example

**15. add the following to your `.env.example` file**

    NODE_ENV=
    PORT=

**16. create you project structure as you see fit or follow the one in this repository**

    mkdir -p src/{common,config,middleware,routes,models,utils} tools uploads && touch src/main.ts

**17. create an `environment.ts` file in your `config` folder**

    touch src/config/environment.ts

**18. add the following to your `environment.ts` file**

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

**19. create a `logger.ts` file in your config folder**

    touch src/config/logger.ts

**20. add the following to your `logger.ts` file**

    import morgan from "morgan";

    export const requestInfo = morgan(
      "[:date[iso] :remote-addr] Started :method :url"
    )

    export const responseInfo = morgan(
      "[:date[iso] :remote-addr] Completed :status :res[content-length] in :response-time ms"
    )

**19. go to your `main.ts` file and add the following**

    import express from "express";
    import cors from "cors";
    import { environment } from "./config/environment";
    import { requestInfo, responseInfo } from "./config/logger"; // optional


    const app = express();

    app.use(cors());
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));
    app.use(requestInfo); // optional
    app.use(responseInfo); // optional

    app.get("/", (req, res) => {
      res.send("Hello World");
    });

    app.listen(environment.port, () => {
      console.log(`Server is running on port ${environment.port}`);
    });

**20. run your server**
  
    pnpm run dev

congratulations you have created your first express server with typescript

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




> :bulb: **You Can Use This Command to help you setup the project
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/drabi-he/express-setup/mongodb/setup.sh)"
```