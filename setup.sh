#!/bin/sh

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

if sed -i 's/"main": "index.js"/"main": "dist\/main.js"/g' package.json; then
  echo "package.json main updated successfully"
else
  echo "Error: package.json update failed." >&2
    rm -rf ../"$name"
  exit 1
fi

if [ "$manager" = "yarn" ]; then 
  if sed -i 's/"license": "MIT"/"license": "MIT",\
  "scripts": {\
    "build": "tsc",\
    "start": "node dist\/main.js",\
    "dev": "tsc -w \&\& concurrently \\"tsc -w\\" \\"nodemon dist\/main.js\\""\
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

if [ "$manager" = "npm" ]; then
  install="install"
else
  install="add"
fi

if "$manager" "$install" express dotenv-safest cors ; then
  echo "express, dotenv-safest, cors installed successfully"
else
  echo "Error: express, dotenv-safest, cors installation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

if "$manager" "$install" -D typescript ts-node @types/node @types/express @types/cors nodemon concurrently morgan @types/morgan; then
  echo "typescript, @types/node, @types/express, @types/dotenv, @types/cors, nodemon, concurrently installed successfully"
else
  echo "Error: typescript, @types/node, @types/express, @types/dotenv, @types/cors, nodemon, concurrently installation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

if npx tsc --init --outDir dist; then
  echo "tsconfig.json created successfully"
else
  echo "Error: tsconfig.json creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

if touch .gitignore && echo "node_modules" >> .gitignore && echo ".env" >> .gitignore && echo "dist" >> .gitignore; then
  echo ".gitignore created successfully"
else
  echo "Error: .gitignore creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

if touch .env && echo "NODE_ENV=development" > .env && echo "PORT=3000" >> .env; then
  echo ".env created successfully"
else
  echo "Error: .env creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

if touch .env.example && echo "NODE_ENV=" > .env.example && echo "PORT=" >> .env.example; then
  echo ".env.example created successfully"
else
  echo "Error: .env.example creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

mkdir -p src/config src/common src/middlewares src/models src/routes src/utils 

cd src

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
} = {
  nodeEnv: process.env.NODE_ENV || "development",
  port: parseInt(process.env.PORT || "3000"),
};' > config/environment.ts; then
  echo "config/environment.ts created successfully"
else
  echo "Error: config/environment.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi

if touch main.ts && echo 'import express from "express";
    import cors from "cors";
    import { environment } from "./config/environment";
    import morgan from "morgan"; // optional

    const app = express();

    app.use(cors());
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));
    app.use(morgan("dev")); // optional

    app.get("/", (req, res) => {
      res.send("Hello World");
    });

    app.listen(environment.port, () => {
      console.log(`Server is running on port ${environment.port}`);
    });' > main.ts; then
  echo "main.ts created successfully"
else
  echo "Error: main.ts creation failed." >&2
    rm -rf ../"$name"
  exit 1
fi
echo ""
echo ""
echo "Project setup successfully"
echo ""
echo ""
echo ""
echo "Run 'cd $name && $manager dev' to start the server"