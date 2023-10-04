import "dotenv-safest/config";

import { Config } from "drizzle-kit";

export default {
  schema: "./src/models/*.ts",
  out: "./drizzle",
  dbCredentials: {
    connectionString: process.env.POSTGRES_URI || "",
  },
  driver: "pg",
} satisfies Config;
