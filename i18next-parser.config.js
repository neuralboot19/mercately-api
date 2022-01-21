module.exports = {
  indentation: 2,
  locales: ['en', 'es'],
  defaultValue: (locale, namespace, key) => key,
  input: 'app/javascript/components/**/*.{js,jsx}',
  output: 'app/javascript/i18n/$LOCALE/$NAMESPACE.json'
};
