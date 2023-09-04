import express from "express";
import cors from "cors";
import { environment } from "./config/environment";
import morgan from "morgan";

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));

app.get("/", (req, res) => {
  res.send("Hello World");
});

app.listen(environment.port, () => {
  console.log(`Server is running on port ${environment.port}`);
});
