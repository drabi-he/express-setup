import { users } from "./../models/user";
import { drizzle } from "drizzle-orm/node-postgres";
import { Client } from "pg";
import { environment } from "./environment";
import { logger } from "./logger";

const client = new Client({
  connectionString: environment.postgresUri,
});

client
  .connect()
  .then(() => {
    logger.info({
      message: "Connected to database",
    });
  })
  .catch((error) => {
    logger.error({
      message: "Failed to connect to database",
      error,
    });
    process.exit(1);
  });

export const db = drizzle(client, {
  schema: {
    users,
  },
});
