const fs = require('fs');
const path = require('path');

// Read environment variables
const apiHostname = process.env.API_HOSTNAME || "localhost";
const apiPort = process.env.API_PORT || "9998";

// Path to your config.json file
const configPath = path.join(__dirname, 'public-flutter', 'config.json');

// Update the contents of the configuration file
const config = {
API_HOSTNAME: apiHostname,
API_PORT: apiPort,
};

fs.writeFileSync(configPath, JSON.stringify(config, null, 2), 'utf8');
console.log(`Updated config.json with API_HOSTNAME=${apiHostname} and API_PORT=${apiPort}`);
