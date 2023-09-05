import morgan from "morgan";
import { createLogger, format, transports } from "winston";

export const logger = createLogger({
  level: "info",
  format: format.combine(
    format.timestamp(),
    format.printf(
      (info) => `[${info.timestamp}] ${info.level}: ${info.message}`
    )
  ),
  transports: [
    new transports.Console(),
    new transports.File({
      filename: "logs/app.log",
      maxsize: 5242880,
      maxFiles: 5,
    }),
  ],
});

export const requestInfo = morgan(
  "[:date[iso] :remote-addr] Started :method :url"
);

export const responseInfo = morgan(
  "[:date[iso] :remote-addr] Completed :status :res[content-length] in :response-time ms"
);
