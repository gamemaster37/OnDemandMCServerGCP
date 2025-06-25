const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const functions = require('@google-cloud/functions-framework');
const { InstancesClient } = require('@google-cloud/compute').v1;
const computeClient = new InstancesClient();

const CONFIG = {
    instance: 'sv',
    project: '294604',
    zone: 'us-east1-c',
    domain: 'mcserver',
    token: '431f-45cf',
    port: '32400'
};

functions.http('startvm', async (req, res) => {
    // Drop the request if the query param friend != secret value
    if (!req.query.friend || req.query.friend !== 'seckey') {
        return res.sendStatus(404);
    }

    try {
        // Start server
        const [startResponse] = await computeClient.start(CONFIG);
        const alreadyOn = startResponse?.latestResponse?.progress === 100;

        // Wait for external IP
        const externalIP = await getExternalIP();

        // Update dynamic DNS
        const dnsRes = await fetch(updateIPDuckDNS(externalIP));
        const dnsOk = dnsRes.ok;

        // Get latest PaperMC version/build
        const { version, build } = await getLatestPaperMC();

        // Build response
        const message = alreadyOn ? 'server running' : 'server starting, please wait ~5min';
        const serverDomain = dnsOk ? `${CONFIG.domain}.duckdns.org:${CONFIG.port}` : 'not working';
        const serverIP = `${externalIP}:${CONFIG.port}`;

        res.json({ message, serverDomain, serverIP, paperVersion: version, paperBuild: build });
    } catch (err) {
        res.sendStatus(500);
    }
});

function updateIPDuckDNS(newIP) {
    return `https://www.duckdns.org/update?domains=${CONFIG.domain}&token=${CONFIG.token}&ip=${newIP}`;
}

async function getExternalIP() {
    while (true) {
        const [instance] = await computeClient.get(CONFIG);
        const ip = instance?.networkInterfaces?.[0]?.accessConfigs?.[0]?.natIP;
        if (ip) return ip;
        await new Promise(r => setTimeout(r, 500));
    }
}

async function getLatestPaperMC() {
    const project = 'paper';
    // Get all versions
    const versionsRes = await fetch(`https://api.papermc.io/v2/projects/${project}`);
    const versionsData = await versionsRes.json();
    const versions = versionsData.versions.reverse(); // newest first

    for (const version of versions) {
        const buildsRes = await fetch(`https://api.papermc.io/v2/projects/${project}/versions/${version}/builds`);
        const buildsData = await buildsRes.json();
        // Find the latest build with channel "default"
        const stableBuild = buildsData.builds
            .filter(b => b.channel === "default")
            .sort((a, b) => b.build - a.build)[0];
        if (stableBuild) {
            return { version, build: stableBuild.build };
        }
    }
    return { version: null, build: null };
}