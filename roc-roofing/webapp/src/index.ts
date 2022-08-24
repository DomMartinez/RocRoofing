import Express, {Request, Response} from 'express';
import promBundle from 'express-prom-bundle';
import path from 'path';
import tracer from './tracer';
import Environment from './Environment';
import Logger from './logger';

async function run(): Promise<void> {
    Logger.info(`Starting express server`);
    const app = Express();
    const metricsMiddleware = promBundle({
        includeMethod: true,
        includePath: true,
        includeStatusCode: true,
        includeUp: true,
        customLabels: {project: 'rocroofing'},
        promClient: {
            collectDefaultMetrics: {
            }
        }
    });
    app.use(metricsMiddleware);
    app.use(Express.text());
    app.use(Express.json());
    app.enable('trust proxy');
    const serverName = Environment.APP_VERSION || 'RocRoofing';
    app.use(async (req: any, res: any, next: any) => {
      const ip: string = req.ip || req.headers['x-forwarded-for'] || (req.socket && req.socket.remoteAddress) || 'unknown';
      Logger.info(`Received ${req.method || 'NOMETHOD'} request on path: ${req.url} from IP: ${ip}`);
      res.setHeader('X-Powered-By', serverName);
      res.setHeader('server', serverName);
      if (tracer) {
        const scope = tracer.scope();
        if (scope) {
          const span = scope.active();
          if (span !== null) {
            span.setTag('client.network.ip', ip);
          }
        }
      }
      next();
    });

    /*
    UI and Static Endpoints
    */
    app.post('/api/analytics', async (req: any, res: any) => {
     const metrics = req.body;
     Logger.info(`Received frontend analytics: ${metrics}`);
     res.status(200).send(null);
    });

    const staticResourcesPath: string = path.join(path.normalize(__dirname), 'public');
    Logger.info(`Serving static resources from path: ${staticResourcesPath}`);
    app.use(Express.static(staticResourcesPath));

    // handle every other route with 404
    app.get('*', (request: Request, response: Response) => {
     response.sendFile(path.resolve(__dirname, 'public/404.html'));
    });

    const port = parseInt(Environment.PORT || '8080', 10);
    app.listen(port, () => {
        Logger.info(`server started at http://0.0.0.0:${ port }`);
    });
}
run().catch(err => Logger.error(err));
