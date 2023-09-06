import express, { NextFunction } from "express";
import cors from "cors";
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

app.listen(environment.port, () => {
  logger.info(`Server is running on port ${environment.port}`);
});
