import { config } from "dotenv-safest";

config();

export const environment: {
  nodeEnv: string;
  port: number;
} = {
  nodeEnv: process.env.NODE_ENV || "development",
  port: parseInt(process.env.PORT || "3000"),
};
