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

packages="express dotenv-safest cors winston multer jsonwebtoken bcryptjs"

if "$manager" "$install" $packages ; then
  echo "$packages installed successfully"
else
  echo "Error: $packages installation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

devPackages="typescript ts-node @types/node @types/express @types/cors nodemon concurrently morgan @types/morgan @types/multer @types/jsonwebtoken @types/bcryptjs"

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

# Git Config
if touch .gitignore && echo "node_modules" >> .gitignore && echo ".env" >> .gitignore && echo "dist" >> .gitignore; then
  echo ".gitignore created successfully"
else
  echo "Error: .gitignore creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

# Env Config
if touch .env \
&& echo "NODE_ENV=development" > .env \
&& echo "PORT=3000" >> .env \
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

# Folder Structure
mkdir -p src/config src/common src/middlewares src/models src/routes src/utils uploads

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

# Main File
if touch main.ts && echo 'import express from "express";
    import cors from "cors";
    import { environment } from "./config/environment";
    import { requestInfo, responseInfo, logger } from "./config/logger";
    import { upload } from "./config/multer";

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


    app.listen(environment.port, () => {
      logger.info(`Server is running on port ${environment.port}`);
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