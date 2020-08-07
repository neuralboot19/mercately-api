const { environment } = require('@rails/webpacker')

module.exports = environment

//Este codigo se incluye para evitar un error en el webpacker al momento de desplegar a
//staging o production. Sucede porque en webpacker 4 el node_modules se transpila con
//Babel-Loader, lo que a veces ocasiona que no se traduzcan algunos codigos correctamente.
const nodeModulesLoader = environment.loaders.get('nodeModules')

if (!Array.isArray(nodeModulesLoader.exclude)) {
  nodeModulesLoader.exclude = (nodeModulesLoader.exclude == null)
    ? []
    : [nodeModulesLoader.exclude]
}

nodeModulesLoader.exclude.push(/google-maps-react/)
