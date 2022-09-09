import {Request, Response} from 'express';
import Logger from '../logger';
import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
import Environment from '../Environment';

const sesClient = new SESClient({
  region: Environment.AWS_SES_REGION
});

interface ContactFormRequest {
  name: string;
  email: string;
  subject: string;
  message: string;
}

const buildHtmlEmail = (name: string, email: string, subject: string, message: string) => {
  return `<html><body><h3>A contact form submission was received from RocRoofingFL.com</h3><br />`
    + `<b>Name</b>: ${name}<br />`
    + `<b>E-Mail</b>: ${email}<br />`
    + `<b>Subject</b>: ${subject}<br />`
    + `<b>Message</b>: ${message}<br />`
    + `</body></html>`;
}
const buildPlaintextEmail = (name: string, email: string, subject: string, message: string) => {
  return `A contact form submission was received from RocRoofingFL.com\n\n`
    + `Name: ${name}\n`
    + `E-Mail: ${email}\n`
    + `Subject: ${subject}\n`
    + `Message: ${message}\n`;
}

const HandleContactUsSubmission = (req: Request, res: Response) => {
  Logger.info(`Received contact form submission`);
  const body: ContactFormRequest = req.body as ContactFormRequest;
  if (!body.name) {
    res.status(400).send(JSON.stringify({
      status: 'ERROR',
      message: 'A valid name must be given'
    }))
  }
  if (!body.email) {
    res.status(400).send(JSON.stringify({
      status: 'ERROR',
      message: 'A valid email must be given'
    }))
  }
  if (!body.subject) {
    res.status(400).send(JSON.stringify({
      status: 'ERROR',
      message: 'A valid subject must be given'
    }))
  }
  if (!body.message) {
    res.status(400).send(JSON.stringify({
      status: 'ERROR',
      message: 'A valid message must be given'
    }))
  }

  sesClient.send(new SendEmailCommand({
    Destination: {
      CcAddresses: [],
      ToAddresses: [
        Environment.CONTACT_US_RECIPIENT
      ],
    },
    Message: {
      /* required */
      Body: {
        /* required */
        Html: {
          Charset: "UTF-8",
          Data: buildHtmlEmail(body.name, body.email, body.subject, body.message),
        },
        Text: {
          Charset: "UTF-8",
          Data: buildPlaintextEmail(body.name, body.email, body.subject, body.message),
        },
      },
      Subject: {
        Charset: "UTF-8",
        Data: `Contact Form Submission: RocRoofingFL.com`,
      },
    },
    Source: "no-reply@rocroofingfl.com",
    ReplyToAddresses: [],
  }))
    .then((result: any) => {
      res.status(200).send(JSON.stringify({
        status: 'SUCCESS',
        message: 'Your message has been sent successfully. We will respond as soon as possible!'
      }))
    })
    .catch((ex: any) => {
      Logger.error(`Unable to send contact us message -- ${ex && ex.message}, body: ${JSON.stringify(req.body)}`);
      res.status(500).send(JSON.stringify({
        status: 'ERROR',
        message: 'An internal server error occurred'
      }))
    })

}

export default HandleContactUsSubmission;
