export interface EnvironmentVariables {
    APP_VERSION?: string;
    PORT?: string;
    TZ?: string;
}
const Environment: EnvironmentVariables = process.env as EnvironmentVariables;
export default Environment;
