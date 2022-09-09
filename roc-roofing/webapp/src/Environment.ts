export interface EnvironmentVariables {
    APP_VERSION?: string;
    PORT?: string;
    TZ?: string;
    CONTACT_US_RECIPIENT?: string;
    AWS_SES_REGION?: string;
}
const Environment: EnvironmentVariables = process.env as EnvironmentVariables;
export default Environment;
