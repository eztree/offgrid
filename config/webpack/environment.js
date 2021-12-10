const { environment } = require('@rails/webpacker')

const webpack = require('webpack');
// Preventing Babel from transpiling NodeModules packages
environment.loaders.delete('nodeModules');
// Bootstrap 4 has a dependency over jQuery & Popper.js:
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default']
  })
);

const dotenv = require("dotenv");
const dotenvFiles = [
	`.env.${process.env.NODE_ENV}.local`,
	".env.local",
	`.env.${process.env.NODE_ENV}`,
	".env",
];
dotenvFiles.forEach((dotenvFile) => {
	dotenv.config({ path: dotenvFile, silent: true });
});

environment.plugins.prepend(
	"Environment",
	new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(process.env)))
);

module.exports = environment
