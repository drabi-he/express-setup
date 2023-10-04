import { sql } from "drizzle-orm";
import { pgEnum, pgTable, serial, text } from "drizzle-orm/pg-core";

export const role = pgEnum("role", ["ADMIN", "MEMBER"]);

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  email: text("email").unique().notNull(),
  username: text("username").unique().notNull(),
  password: text("password").notNull(),
  role: role("role").notNull().default("MEMBER"),
  refreshToken: text("refresh_token"),

  createdAt: text("created_at")
    .notNull()
    .default(sql`now()`),
  updatedAt: text("updated_at")
    .notNull()
    .default(sql`now()`),
});

export type User = typeof users.$inferSelect;
export type UserInsert = typeof users.$inferInsert;
