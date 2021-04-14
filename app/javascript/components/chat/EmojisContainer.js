import React from 'react';
import { Picker } from "emoji-mart";

const pickerI18n = {
  search: 'Buscar emoji',
  clear: 'Limpiar',
  notfound: 'Emoji no encontrado',
  skintext: 'Selecciona el tono de piel por defecto',
  categories: {
    search: 'Resultados de la búsqueda',
    recent: 'Recientes',
    smileys: 'Smileys & Emotion',
    people: 'Emoticonos y personas',
    nature: 'Animales y naturaleza',
    foods: 'Alimentos y bebidas',
    activity: 'Actividades',
    places: 'Viajes y lugares',
    objects: 'Objetos',
    symbols: 'Símbolos',
    flags: 'Banderas',
    custom: 'Custom'
  },
  categorieslabel: 'Categorías de los emojis',
  skintones: {
    1: 'Tono de piel por defecto',
    2: 'Tono de piel claro',
    3: 'Tono de piel claro medio',
    4: 'Tono de piel medio',
    5: 'Tono de piel oscuro medio',
    6: 'Tono de piel oscuro'
  }
};

const EmojisContainer = ({ insertEmoji }) => (
  <div id="emojis-holder" className="emojis-container">
    <Picker
      set='apple'
      title='Seleccionar...'
      emoji='point_up'
      onSelect={(emoji) => insertEmoji(emoji)}
      color='#00B4FF'
      i18n={pickerI18n}
      skinEmoji='hand'
    />
  </div>
);

export default EmojisContainer;
