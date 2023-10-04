import express from "express";
import cors from "cors";
import { environment } from "./config/environment";
import { upload } from "./config/multer";
import { logger } from "./config/logger";
import { requestInfo, responseInfo } from "./config/logger";
import "./config/database";
import AuthRouter from "./routes/auth";

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static("uploads"));
app.use(requestInfo);
app.use(responseInfo);

app.get("/", (req, res) => {
  res.send("Welcome to Drizzle-Postgres API");
});
app.use("/api/auth", AuthRouter);

app.listen(environment.port, () => {
  logger.info(`Server is running on port ${environment.port}`);
});
