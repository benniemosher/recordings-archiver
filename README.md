# recordings-archiver
A simple repo to automate the backup of Zoom Recordings to AWS S3.

I would like all things to be:
- Written in Terraform or (CDK-TF, which would make all this in Node.js)
- Written in Node.js
- ran through Github Actions
  - linting
  - testing

## The Flow:

- Zoom meeting happens with cloud recording turned on
- Zoom meeting ends, and Zoom processes the recordings
- When recordings available, Zoom will fire a webhook to a Lambda, `archive_raw_recordings`. This Lambda will:
  - Query the recordings "title" for email address(es)
  - Lambda will check for or create a folder in `raw_recordings` S3 bucket based off the email address(es) in the recording "title"
    - If more than one email address, create one folder with all email addresses seperated by `_`
  - Lambda will then store video files, audio files, and any transcripts into that folder

- Our `process_raw_recordings` lambda will watch for new files to appear in the `raw_recordings` S3 bucket.
  - When new files are found, the lambda will process/compile the video files
  - The lambda will save those files in a S3 bucket, `available_recordings`
    - This will follow the same namespacing as the `raw_recordings` bucket (by email address(es) presented in the recording title
  - The recordings will be nested in an `<email_address>/<date>` folder structure in the S3 bucket
  - The lambda will move the "raw recording" from the `raw_recordings` S3 bucket, into a (Glacier?) archive bucket `raw_recordings_archive`
  - Items in `available_recordings` S3 bucket have a lifecycle of X (assuming 30) days
    - Then it is moved to a (Glacier?) archive bucket `processed_recordings_archive`

- Our `notify_recording_ready` lambda will watch for new files to appear in the `available_recordings` S3 bucket
  - When there is a video file *_AND_* an audio file present in the same folder, the lambda will notify clients
  - The lambda will traverse folders upwards until it finds the clients email address named folder
  - Then it will fire off to an SNS topic `notify_recordings_finished`
    - This SNS topic will email the client notifying them that their recording is ready to download
    - This will only fire once per client per day
    - This SNS topic will send a Slack message notifying the team that recordings were processsed and sent out

## Things Needed:
- S3 Bucket: `raw_recordings`
- Lambda: `archive_raw_recordings`
- Lambda: `process_raw_recordings`
- S3 Bucket: `available_recordings`
- S3 Bucket: `raw_recordings_archive`
- S3 Bucket: `processed_recordings_archive`
- Lambda: `notify_recording_ready`
- SNS Topic: `notify_recordings_finished`
- SES?
- Slack integration lambda?
