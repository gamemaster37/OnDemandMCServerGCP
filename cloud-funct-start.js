const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const functions = require('@google-cloud/functions-framework');
const { InstancesClient } = require('@google-cloud/compute').v1;
const computeClient = new InstancesClient();

const request = {
  instance: 'sv',
  project: '294604',
  zone: 'us-east1-c',
};

const domain = 'mcserver';
const token = '431f-45cf';
const port = '32400' 

const updateIPDuckDNS = (newIP) =>
  `https://www.duckdns.org/update?domains=${domain}&token=${token}&ip=${newIP}`

functions.http('startvm', async (_req, res) => {
  // starts server
  const startServer = await computeClient.start(request);
  const alreadyOn = startServer[0]?.latestResponse?.progress === 100
  // waits for server ip
  const externalIP = await getExternalIP();
  // updates dinamic dns
  const dns = await fetch(updateIPDuckDNS(externalIP));
  // build response
  const message = alreadyOn ? 'server running' : 'server starting plase wait +-5min';
  const serverDomain = dns?.status === 200 ? `${domain}.duckdns.org:${port}` : 'not working';
  const serverIP = `${externalIP}:${port}`;
  // send response
  res.json({
    message,
    serverDomain,
    serverIP
  });
});

async function getExternalIP() {
  let externalIP = false
  while (!externalIP) {
    const instance = await computeClient.get(request);
    externalIP = instance[0]?.networkInterfaces[0]?.accessConfigs[0]?.natIP ?? false
  }
  return externalIP
}
