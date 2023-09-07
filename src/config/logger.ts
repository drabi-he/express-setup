import morgan from "morgan";
import { createLogger, format, transports } from "winston";

export const logger = createLogger({
  level: "info",
  format: format.combine(
    format.timestamp({ format: "YYYY-MM-DD HH:mm:ss:ms" }),
    format.printf(
      (info) => `[${info.timestamp}] ${info.level}: ${info.message}`
    )
  ),
  transports: [
    new transports.Console(),
    new transports.File({
      filename: "logs/error.log",
      level: "error",
      maxsize: 5242880,
      maxFiles: 5,
    }),
    new transports.File({
      filename: "logs/combined.log",
      maxsize: 5242880,
      maxFiles: 5,
    }),
  ],
});

const stream = {
  write: (message: string) => {
    const status = parseInt(message.split(" ")[4]);
    if (status >= 400) logger.error(message.trim());
    else logger.info(message.trim());
  },
};

export const requestInfo = morgan("[:remote-addr] Started :method :url", {
  stream,
});

export const responseInfo = morgan(
  "[:remote-addr] Completed :method :url :status :method :url :res[content-length] in :response-time ms",
  { stream }
);
