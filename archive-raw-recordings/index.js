export async function handler(event) {
  console.log('Event: ', event);
  // let responseMessage = 'Hello, World!';

  // if (event.queryStringParameters && event.queryStringParameters['Name']) {
  //   responseMessage = 'Hello, ' + event.queryStringParameters['Name'] + '!';
  // }
  let body = JSON.parse(event.body)

  // TODO: Change to env variable
  if (body.headers.authorization == process.env.zoomKey) {
    let content = JSON.parse(body.body)
    let payload = content.payload.object
    let topic = payload.topic
    let email = topic.substring(
      topic.indexOf("(") + 1,
      topic.lastIndexOf(")")
    )
    let download_urls = []

    payload.recording_files.forEach((file) => {
      download_urls.push(file.download_url)
    })

    console.log(email)
    console.log(JSON.stringify(download_urls))
  }

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: responseMessage,
    }),
  }
}
