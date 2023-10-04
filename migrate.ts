import "dotenv/config";
import { Client } from "pg";
import { drizzle, NodePgDatabase } from "drizzle-orm/node-postgres";
import { migrate } from "drizzle-orm/node-postgres/migrator";

const client = new Client({
  connectionString: process.env.POSTGRES_URI || "",
});

const db = drizzle(client);

const main = async () => {
  try {
    client.connect();
    console.log("Migrating database");
    await migrate(db, {
      migrationsFolder: "drizzle",
    });
    console.log("Database migrated");
    client.end();
  } catch (error) {
    console.log({
      message: "Failed to migrate database",
      error,
    });
  }
};

main();
