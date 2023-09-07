import express from "express";
import cors from "cors";
import { dbConnect } from "./config/database";
import { environment } from "./config/environment";
import { requestInfo, responseInfo, logger } from "./config/logger";
import { upload } from "./config/multer";
import AuthRouter from "./routes/auth";

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

app.use("/api/auth", AuthRouter);

dbConnect(environment.mongoUrl)
  .then(() => {
    logger.info("Connected to database");
    app.listen(environment.port, () => {
      logger.info(`Server is running on port ${environment.port}`);
    });
  })
  .catch((err) => {
    logger.error(err);
    process.exit(1);
  });
