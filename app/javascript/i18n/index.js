import i18next from 'i18next';
import Polyglot from 'i18next-polyglot';
import { initReactI18next } from 'react-i18next';

i18next
  .use(initReactI18next)
  .use(Polyglot)
  .use({
    type: 'backend',
    read: (language, namespace, callback) => {
      import(`./${language}/${namespace}.json`)
        .then((resources) => {
          callback(null, resources);
        })
        .catch((error) => {
          callback(error, null);
        });
    }
  })
  .init({
    fallbackLng: 'es',
    lng: ENV['CURRENT_AGENT_LANG'],
    debug: process.env.NODE_ENV !== 'production'
  });

export default i18next;
