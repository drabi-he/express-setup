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

packages="express dotenv-safest cors mongoose"

if "$manager" "$install" $packages ; then
  echo "$packages installed successfully"
else
  echo "Error: $packages installation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

devPackages="typescript ts-node @types/node @types/express @types/cors nodemon concurrently morgan @types/morgan"

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

# Env Config
if touch .env && echo "NODE_ENV=development" > .env && echo "PORT=3000" >> .env && echo "MONGO_INITDB_ROOT_USERNAME=admin" >> .env && echo "MONGO_INITDB_ROOT_PASSWORD=secret" >> .env && echo "MONGO_URL=mongodb://admin:secret@localhost:27017/mydb?authSource=admin" >> .env ; then
  echo ".env created successfully"
else
  echo "Error: .env creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Env Example Config
if touch .env.example && echo "NODE_ENV=" > .env.example && echo "PORT=" >> .env.example && echo "MONGO_INITDB_ROOT_USERNAME=" >> .env.example && echo "MONGO_INITDB_ROOT_PASSWORD=" >> .env.example && echo "MONGO_URL=" >> .env.example; then
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
mkdir -p src/config src/common src/middlewares src/models src/routes src/utils 

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
} = {
  nodeEnv: process.env.NODE_ENV || "development",
  port: parseInt(process.env.PORT || "3000"),
  mongoUrl: process.env.MONGO_URL || "",
};' > config/environment.ts; then
  echo "config/environment.ts created successfully"
else
  echo "Error: config/environment.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Logger Config
if touch config/logger.ts && echo 'import morgan from "morgan";

    export const requestInfo = morgan(
      "[:date[iso] :remote-addr] Started :method :url"
    )

    export const responseInfo = morgan(
      "[:date[iso] :remote-addr] Completed :status :res[content-length] in :response-time ms"
    )' > config/logger.ts; then
  echo "config/logger.ts created successfully"
else
  echo "Error: config/logger.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Database Config

if touch config/database.ts && echo 'import mongoose from "mongoose";
    import { environment } from "./environment";

    export const dbConnect = mongoose.connect;' > config/database.ts; then
  echo "config/database.ts created successfully"
else
  echo "Error: config/database.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Main File
if touch main.ts && echo 'import express from "express";
    import cors from "cors";
    import { dbConnect } from "./config/database";
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

    dbConnect(environment.mongoUrl)
      .then(() => {
        console.log("Connected to database");
        app.listen(environment.port, () => {
          console.log(`Server is running on port ${environment.port}`);
        });
      })
      .catch((err) => {
        console.error(err);
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
echo ""
echo ""
echo "Run 'cd $name && $manager dev' to start the server"