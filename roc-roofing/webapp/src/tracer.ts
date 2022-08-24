import tracer from 'dd-trace';
import Environment from './Environment';

// initialized in a different file to avoid hoisting.
tracer.init({
  env : process.env.NODE_ENV ,
  service : 'rocroofing-webapp',
  version: Environment.APP_VERSION,
  logInjection: true
});
tracer.use('express');
export default tracer;
