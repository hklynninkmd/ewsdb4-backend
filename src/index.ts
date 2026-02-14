import app from './app';
import config from '@/config';
import database from '@/shared/database/mysql';
import cache from '@/shared/cache/redis';
import logger from '@/shared/logger';
import {Try} from '@/shared/utils/Try';

const startServer = async () => {
  await Try.execute(async () => {
    await database.connect();
    await cache.connect();

    const server = app.listen(config.port, () => {
      logger.info(`Server running on port ${config.port} in ${config.env} mode`);
      logger.info(`API available at http://localhost:${config.port}${config.apiPrefix}`);
    });

    const gracefulShutdown = async (signal: string) => {
      logger.info(`${signal} received. Starting graceful shutdown...`);

      server.close(async () => {
        logger.info('HTTP server closed');

        await Try.execute(async () => {
          await database.disconnect();
          await cache.disconnect();
          logger.info('All connections closed. Exiting process.');
          process.exit(0);
        }).onFailure(() => {
          process.exit(1);
        }).orElseLogWarning('Error during shutdown');
      });

      setTimeout(() => {
        logger.error('Forced shutdown after timeout');
        process.exit(1);
      }, 10000);
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

    process.on('unhandledRejection', (reason: any) => {
      logger.error('Unhandled Rejection:', reason);
      throw reason;
    });

    process.on('uncaughtException', (error: Error) => {
      logger.error('Uncaught Exception:', error);
      process.exit(1);
    });
  }).onFailure(() => {
    process.exit(1);
  }).orElseLogWarning('Failed to start server');
};

startServer()
  .then((r) => console.log(r))
  .catch((e) => console.log(e));
