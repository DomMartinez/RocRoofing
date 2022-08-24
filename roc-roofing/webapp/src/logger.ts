import tracer from 'dd-trace';
import formats from 'dd-trace/ext/formats';

export enum LogLevel {
  DEBUG="DEBUG",
  INFO="INFO",
  WARN="WARN",
  ERROR="ERROR",
}
export class Logger {
    log() {
        const level: LogLevel | string = arguments[0];
        const span = tracer.scope().active();
        const time = new Date().toISOString();
        if (arguments.length > 1) {
          for (let i = 1; i < arguments.length; i++) {
            const record = { time, level, message: arguments[i] };
            if (span) {
                tracer.inject(span.context(), formats.LOG, record);
            }
            console.log(JSON.stringify(record));
          }
        }
    }
    debug(p1: any, p2?: any, p3?: any) {
      const args = [LogLevel.DEBUG];
      for (const arg of arguments) {
        args.push(arg);
      }
      this.log.apply(null, args);
    }
    info(p1: any, p2?: any, p3?: any) {
      const args = [LogLevel.INFO];
      for (const arg of arguments) {
        args.push(arg);
      }
      this.log.apply(null, args);
    }
    warn(p1: any, p2?: any, p3?: any) {
      const args = [LogLevel.WARN];
      for (const arg of arguments) {
        args.push(arg);
      }
      this.log.apply(null, args);
    }
    error(p1: any, p2?: any, p3?: any) {
      const args = [LogLevel.ERROR];
      for (const arg of arguments) {
        args.push(arg);
      }
      this.log.apply(null, args);
    }
}

const defaultLogger = new Logger();
export default defaultLogger;
