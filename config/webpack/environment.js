const { environment } = require("@rails/webpacker");

// Remove any optimization configuration
environment.config.delete("optimization");

// Update module rules to remove sideEffects
const babelLoader = environment.loaders.get("babel");
if (babelLoader) {
  babelLoader.use[0].options = {
    ...babelLoader.use[0].options,
    presets: ["env"],
    plugins: [
      "syntax-dynamic-import",
      "transform-class-properties",
      "transform-object-rest-spread",
    ],
  };
}

module.exports = environment;
