FactoryBot.define do
  factory :category do
    name { Faker::Lorem.word }
    meli_id { "MEC#{Faker::Number.number(6)}" }
    template do
      [{
        "name": 'Marca',
        "tags": {
          "catalog_required": true
        },
        "hierarchy": 'PARENT_PK',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "value_type": 'string',
        "relevance": 1,
        "id": 'BRAND'
      }, {
        "name": 'Modelo',
        "tags": {
          "catalog_required": true
        },
        "hierarchy": 'PARENT_PK',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "value_type": 'string',
        "relevance": 1,
        "id": 'MODEL'
      }, {
        "name": 'Color',
        "tags": {
          "allow_variations": true,
          "defines_picture": true
        },
        "hierarchy": 'CHILD_PK',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '52019',
            "name": 'Verde oscuro'
          },
          {
            "id": '283160',
            "name": 'Turquesa'
          },
          {
            "id": '52022',
            "name": 'Agua'
          },
          {
            "id": '283162',
            "name": "\xC3\x8Dndigo"
          },
          {
            "id": '52036',
            "name": 'Lavanda'
          },
          {
            "id": '283163',
            "name": 'Rosa chicle'
          },
          {
            "id": '51998',
            "name": "Bord\xC3\xB3"
          },
          {
            "id": '52003',
            "name": 'Piel'
          },
          {
            "id": '52055',
            "name": 'Blanco'
          },
          {
            "id": '283161',
            "name": 'Azul marino'
          },
          {
            "id": '52008',
            "name": 'Crema'
          },
          {
            "id": '52045',
            "name": "Rosa p\xC3\xA1lido"
          },
          {
            "id": '283153',
            "name": 'Suela'
          },
          {
            "id": '283150',
            "name": 'Naranja claro'
          },
          {
            "id": '52028',
            "name": 'Azul'
          },
          {
            "id": '52043',
            "name": 'Rosa claro'
          },
          {
            "id": '283148',
            "name": 'Coral claro'
          },
          {
            "id": '283149',
            "name": 'Coral'
          },
          {
            "id": '52021',
            "name": 'Celeste'
          },
          {
            "id": '52031',
            "name": 'Azul acero'
          },
          {
            "id": '283156',
            "name": 'Caqui'
          },
          {
            "id": '52001',
            "name": 'Beige'
          },
          {
            "id": '51993',
            "name": 'Rojo'
          },
          {
            "id": '51996',
            "name": 'Terracota'
          },
          {
            "id": '283165',
            "name": 'Gris'
          },
          {
            "id": '52035',
            "name": 'Violeta'
          },
          {
            "id": '283154',
            "name": "Marr\xC3\xB3n claro"
          },
          {
            "id": '52049',
            "name": 'Negro'
          },
          {
            "id": '283155',
            "name": "Marr\xC3\xB3n oscuro"
          },
          {
            "id": '52053',
            "name": 'Plateado'
          },
          {
            "id": '52047',
            "name": 'Violeta oscuro'
          },
          {
            "id": '51994',
            "name": 'Rosa'
          },
          {
            "id": '52007',
            "name": 'Amarillo'
          },
          {
            "id": '283157',
            "name": 'Verde lima'
          },
          {
            "id": '52012',
            "name": 'Dorado oscuro'
          },
          {
            "id": '52015',
            "name": 'Verde claro'
          },
          {
            "id": '283151',
            "name": 'Naranja oscuro'
          },
          {
            "id": '52024',
            "name": "Azul petr\xC3\xB3leo"
          },
          {
            "id": '52051',
            "name": 'Gris oscuro'
          },
          {
            "id": '283152',
            "name": 'Chocolate'
          },
          {
            "id": '52014',
            "name": 'Verde'
          },
          {
            "id": '283164',
            "name": 'Dorado'
          },
          {
            "id": '52000',
            "name": 'Naranja'
          },
          {
            "id": '52033',
            "name": 'Azul oscuro'
          },
          {
            "id": '52010',
            "name": 'Ocre'
          },
          {
            "id": '283158',
            "name": 'Verde musgo'
          },
          {
            "id": '52005',
            "name": "Marr\xC3\xB3n"
          },
          {
            "id": '52038',
            "name": 'Lila'
          },
          {
            "id": '52042',
            "name": 'Fucsia'
          },
          {
            "id": '338779',
            "name": 'Cian'
          },
          {
            "id": '52029',
            "name": 'Azul claro'
          }
        ],
        "relevance": 1,
        "value_type": 'string',
        "id": 'COLOR'
      }, {
        "name": 'Voltaje',
        "tags": {},
        "hierarchy": 'CHILD_PK',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '198813',
            "name": '220V'
          },
          {
            "id": '198812',
            "name": '110V/220V (Bivolt)'
          },
          {
            "id": '198814',
            "name": '110V'
          },
          {
            "id": '106543',
            "name": '380V'
          }
        ],
        "relevance": 1,
        "value_type": 'string',
        "id": 'VOLTAGE'
      }, {
        "name": 'Tipo de instrumento',
        "tags": {},
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '6172525',
            "name": 'Piano'
          },
          {
            "id": '6172526',
            "name": 'Teclado'
          }
        ],
        "relevance": 1,
        "value_type": 'list',
        "id": 'INSTRUMENT_TYPE'
      }, {
        "name": 'Personaje',
        "tags": {},
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '930463',
            "name": 'Mickey Mouse'
          },
          {
            "id": '482752',
            "name": 'Barbie'
          }
        ],
        "relevance": 1,
        "value_type": 'string',
        "id": 'CHARACTER'
      }, {
        "name": "Tipo de alimentaci\xC3\xB3n",
        "tags": {},
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '4491927',
            "name": "Bater\xC3\xADa"
          },
          {
            "id": '4636341',
            "name": 'Corriente directa'
          },
          {
            "id": '1176674',
            "name": 'Pilas'
          }
        ],
        "relevance": 1,
        "value_type": 'string',
        "id": 'POWER_SUPPLY_TYPE'
      }, {
        "name": 'Cantidad de teclas',
        "tags": {},
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "value_max_length": 18,
        "attribute_group_id": 'OTHERS',
        "value_type": 'number',
        "relevance": 1,
        "id": 'MUSICAL_KEYS_NUMBER'
      }, {
        "name": "Edad m\xC3\xADnima recomendada",
        "tags": {},
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "default_unit": "a\xC3\xB1os",
        "attribute_group_id": 'OTHERS',
        "allowed_units": [
          {
            "id": "a\xC3\xB1os",
            "name": "a\xC3\xB1os"
          },
          {
            "id": 'meses',
            "name": 'meses'
          }
        ],
        "value_type": 'number_unit',
        "relevance": 1,
        "id": 'MIN_RECOMMENDED_AGE'
      }, {
        "name": "Edad m\xC3\xA1xima recomendada",
        "tags": {},
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "default_unit": "a\xC3\xB1os",
        "attribute_group_id": 'OTHERS',
        "allowed_units": [
          {
            "id": "a\xC3\xB1os",
            "name": "a\xC3\xB1os"
          },
          {
            "id": 'meses',
            "name": 'meses'
          }
        ],
        "value_type": 'number_unit',
        "relevance": 1,
        "id": 'MAX_RECOMMENDED_AGE'
      }, {
        "value_max_length": 255,
        "name": "C\xC3\xB3digo universal de producto",
        "tags": {
          "used_hidden": true,
          "validate": true,
          "multivalued": true,
          "variation_attribute": true
        },
        "hierarchy": 'PRODUCT_IDENTIFIER',
        "attribute_group_name": 'Otros',
        "hint": 'Suele ser un EAN, UPC u otro GTIN.',
        "tooltip": "¿Cómo lo reconozco?\n\nEs un número de 8 a 14 dígitos que se encuentra junto al código de barras,
        en la caja del producto, o en su etiqueta.\n\n
        ![Código universal de producto](https://http2.mlstatic.com/static/org-img/sd-landings/assets/pi-tooltip.png)",
        "value_type": 'string',
        "attribute_group_id": 'OTHERS',
        "relevance": 1,
        "type": 'product_identifier',
        "id": 'GTIN'
      }, {
        "name": 'Altura',
        "tags": {
          "hidden": true
        },
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "default_unit": 'cm',
        "attribute_group_id": 'OTHERS',
        "allowed_units": [
          {
            "id": 'cm',
            "name": 'cm'
          },
          {
            "id": '"',
            "name": '"'
          }
        ],
        "value_type": 'number_unit',
        "relevance": 2,
        "id": 'HEIGHT'
      }, {
        "name": 'Largo',
        "tags": {
          "hidden": true
        },
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "default_unit": 'cm',
        "attribute_group_id": 'OTHERS',
        "allowed_units": [
          {
            "id": 'cm',
            "name": 'cm'
          },
          {
            "id": '"',
            "name": '"'
          }
        ],
        "value_type": 'number_unit',
        "relevance": 2,
        "id": 'LENGTH'
      }, {
        "name": 'Ancho',
        "tags": {
          "hidden": true
        },
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "default_unit": 'cm',
        "attribute_group_id": 'OTHERS',
        "allowed_units": [
          {
            "id": 'cm',
            "name": 'cm'
          },
          {
            "id": '"',
            "name": '"'
          }
        ],
        "value_type": 'number_unit',
        "relevance": 2,
        "id": 'WIDTH'
      }, {
        "name": 'Material',
        "tags": {
          "hidden": true
        },
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '2431881',
            "name": 'Madera'
          },
          {
            "id": '2748302',
            "name": "Pl\xC3\xA1stico"
          }
        ],
        "relevance": 2,
        "value_type": 'string',
        "id": 'MATERIAL'
      }, {
        "name": 'Incluye asiento',
        "tags": {
          "hidden": true
        },
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "metadata": {
              "value": false
            },
            "id": '242084',
            "name": 'No'
          },
          {
            "metadata": {
              "value": true
            },
            "id": '242085',
            "name": "S\xC3\xAD"
          }
        ],
        "relevance": 2,
        "value_type": 'boolean',
        "id": 'INCLUDES_SEAT'
      }, {
        "name": "Condici\xC3\xB3n del \xC3\xADtem",
        "tags": {
          "hidden": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '2230581',
            "name": 'Usado'
          },
          {
            "id": '2230284',
            "name": 'Nuevo'
          }
        ],
        "relevance": 2,
        "value_type": 'list',
        "id": 'ITEM_CONDITION'
      }, {
        "name": 'UPC',
        "tags": {
          "hidden": true,
          "validate": true,
          "variation_attribute": true,
          "multivalued": true
        },
        "hierarchy": 'PRODUCT_IDENTIFIER',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "tooltip": "Este es el n\xC3\xBAmero de 12 d\xC3\xADgitos que est\xC3\xA1 en el c\xC3\xB3digo de barras de
        tu producto.",
        "value_type": 'string',
        "attribute_group_id": 'OTHERS',
        "relevance": 2,
        "type": 'product_identifier',
        "id": 'UPC'
      }, {
        "name": 'MPN',
        "tags": {
          "hidden": true,
          "multivalued": true,
          "variation_attribute": true
        },
        "hierarchy": 'PRODUCT_IDENTIFIER',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "value_type": 'string',
        "relevance": 2,
        "type": 'product_identifier',
        "id": 'MPN'
      }, {
        "name": 'EAN',
        "tags": {
          "hidden": true,
          "validate": true,
          "variation_attribute": true,
          "multivalued": true
        },
        "hierarchy": 'PRODUCT_IDENTIFIER',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "tooltip": "Este es el n\xC3\xBAmero de 8, 13 o 14 d\xC3\xADgitos que est\xC3\xA1 en el c\xC3\xB3digo de
        barras de tu producto.",
        "value_type": 'string',
        "attribute_group_id": 'OTHERS',
        "relevance": 2,
        "type": 'product_identifier',
        "id": 'EAN'
      }, {
        "name": 'SKU',
        "tags": {
          "hidden": true,
          "variation_attribute": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "value_type": 'string',
        "relevance": 1,
        "id": 'SELLER_SKU'
      }, {
        "name": 'Es inflamable',
        "tags": {
          "read_only": true,
          "hidden": true
        },
        "hierarchy": 'FAMILY',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "metadata": {
              "value": false
            },
            "id": '242084',
            "name": 'No'
          },
          {
            "metadata": {
              "value": true
            },
            "id": '242085',
            "name": "S\xC3\xAD"
          }
        ],
        "relevance": 2,
        "value_type": 'boolean',
        "id": 'IS_FLAMMABLE'
      }, {
        "name": 'Es kit',
        "tags": {
          "hidden": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "metadata": {
              "value": false
            },
            "id": '242084',
            "name": 'No'
          },
          {
            "metadata": {
              "value": true
            },
            "id": '242085',
            "name": "S\xC3\xAD"
          }
        ],
        "relevance": 2,
        "value_type": 'boolean',
        "id": 'IS_KIT'
      }, {
        "name": 'Tags descriptivos',
        "tags": {
          "read_only": true,
          "hidden": true,
          "multivalued": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "value_type": 'string',
        "relevance": 2,
        "id": 'DESCRIPTIVE_TAGS'
      }, {
        "name": 'Largo del paquete',
        "tags": {
          "read_only": true,
          "hidden": true,
          "variation_attribute": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "default_unit": 'cm',
        "attribute_group_id": 'OTHERS',
        "allowed_units": [
          {
            "id": 'cm',
            "name": 'cm'
          },
          {
            "id": 'yd',
            "name": 'yd'
          },
          {
            "id": 'pulgadas',
            "name": 'pulgadas'
          },
          {
            "id": 'U',
            "name": 'U'
          },
          {
            "id": '"',
            "name": '"'
          },
          {
            "id": 'nm',
            "name": 'nm'
          },
          {
            "id": 'km',
            "name": 'km'
          },
          {
            "id": 'ft',
            "name": 'ft'
          },
          {
            "id": 'in',
            "name": 'in'
          },
          {
            "id": 'mm',
            "name": 'mm'
          },
          {
            "id": 'm',
            "name": 'm'
          },
          {
            "id": 'manos',
            "name": 'manos'
          },
          {
            "id": 'micras',
            "name": 'micras'
          }
        ],
        "value_type": 'number_unit',
        "relevance": 2,
        "id": 'PACKAGE_LENGTH'
      }, {
        "name": 'Peso del paquete',
        "tags": {
          "read_only": true,
          "hidden": true,
          "variation_attribute": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "default_unit": 'g',
        "attribute_group_id": 'OTHERS',
        "allowed_units": [
          {
            "id": 'lb',
            "name": 'lb'
          },
          {
            "id": 'oz',
            "name": 'oz'
          },
          {
            "id": 'mg',
            "name": 'mg'
          },
          {
            "id": 'kg',
            "name": 'kg'
          },
          {
            "id": 't',
            "name": 't'
          },
          {
            "id": 'g',
            "name": 'g'
          },
          {
            "id": 'mcg',
            "name": 'mcg'
          }
        ],
        "value_type": 'number_unit',
        "relevance": 2,
        "id": 'PACKAGE_WEIGHT'
      }, {
        "name": 'Ancho del paquete',
        "tags": {
          "read_only": true,
          "hidden": true,
          "variation_attribute": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "default_unit": 'cm',
        "attribute_group_id": 'OTHERS',
        "allowed_units": [
          {
            "id": 'cm',
            "name": 'cm'
          },
          {
            "id": 'yd',
            "name": 'yd'
          },
          {
            "id": 'pulgadas',
            "name": 'pulgadas'
          },
          {
            "id": 'U',
            "name": 'U'
          },
          {
            "id": '"',
            "name": '"'
          },
          {
            "id": 'nm',
            "name": 'nm'
          },
          {
            "id": 'km',
            "name": 'km'
          },
          {
            "id": 'ft',
            "name": 'ft'
          },
          {
            "id": 'in',
            "name": 'in'
          },
          {
            "id": 'mm',
            "name": 'mm'
          },
          {
            "id": 'm',
            "name": 'm'
          },
          {
            "id": 'manos',
            "name": 'manos'
          },
          {
            "id": 'micras',
            "name": 'micras'
          }
        ],
        "value_type": 'number_unit',
        "relevance": 2,
        "id": 'PACKAGE_WIDTH'
      }, {
        "name": 'Altura del paquete',
        "tags": {
          "read_only": true,
          "hidden": true,
          "variation_attribute": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "default_unit": 'cm',
        "attribute_group_id": 'OTHERS',
        "allowed_units": [
          {
            "id": 'cm',
            "name": 'cm'
          },
          {
            "id": 'yd',
            "name": 'yd'
          },
          {
            "id": 'pulgadas',
            "name": 'pulgadas'
          },
          {
            "id": 'U',
            "name": 'U'
          },
          {
            "id": '"',
            "name": '"'
          },
          {
            "id": 'nm',
            "name": 'nm'
          },
          {
            "id": 'km',
            "name": 'km'
          },
          {
            "id": 'ft',
            "name": 'ft'
          },
          {
            "id": 'in',
            "name": 'in'
          },
          {
            "id": 'mm',
            "name": 'mm'
          },
          {
            "id": 'm',
            "name": 'm'
          },
          {
            "id": 'manos',
            "name": 'manos'
          },
          {
            "id": 'micras',
            "name": 'micras'
          }
        ],
        "value_type": 'number_unit',
        "relevance": 2,
        "id": 'PACKAGE_HEIGHT'
      }, {
        "name": "Caracter\xC3\xADsticas del producto",
        "tags": {
          "read_only": true,
          "hidden": true,
          "multivalued": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '7435882',
            "name": 'Inflamable'
          },
          {
            "id": '7435883',
            "name": "Fr\xC3\xA1gil"
          },
          {
            "id": '7435885',
            "name": "Contiene l\xC3\xADquido"
          },
          {
            "id": '7435888',
            "name": 'Con vencimiento'
          },
          {
            "id": '7575917',
            "name": 'Desinfectante y sanitizante'
          },
          {
            "id": '7575918',
            "name": 'Aerosol'
          },
          {
            "id": '7575919',
            "name": 'Oxidante'
          },
          {
            "id": '7575920',
            "name": 'Corrosivo'
          },
          {
            "id": '7575921',
            "name": 'Explosivo'
          },
          {
            "id": '7575922',
            "name": "T\xC3\xB3xico o infeccioso"
          }
        ],
        "relevance": 2,
        "value_type": 'list',
        "id": 'PRODUCT_FEATURES'
      }, {
        "name": 'Alimentos y bebidas',
        "tags": {
          "read_only": true,
          "hidden": true,
          "multivalued": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '7575926',
            "name": 'Para humanos'
          },
          {
            "id": '7575927',
            "name": 'Para animales'
          }
        ],
        "relevance": 2,
        "value_type": 'list',
        "id": 'FOODS_AND_DRINKS'
      }, {
        "name": 'Medicamentos',
        "tags": {
          "read_only": true,
          "hidden": true,
          "multivalued": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '7575930',
            "name": "Para humanos con receta m\xC3\xA9dica"
          },
          {
            "id": '7575931',
            "name": "Para humanos sin receta m\xC3\xA9dica"
          },
          {
            "id": '7575932',
            "name": "Para animales con receta m\xC3\xA9dica"
          },
          {
            "id": '7575933',
            "name": "Para animales sin receta m\xC3\xA9dica"
          }
        ],
        "relevance": 2,
        "value_type": 'list',
        "id": 'MEDICINES'
      }, {
        "name": "Bater\xC3\xADas",
        "tags": {
          "read_only": true,
          "hidden": true,
          "multivalued": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '7575934',
            "name": 'De litio stand-alone (sueltas o aisladas)'
          },
          {
            "id": '7575935',
            "name": 'De litio instaladas'
          },
          {
            "id": '7575936',
            "name": "Para autos (\xC3\xA1cido-plomo)"
          }
        ],
        "relevance": 2,
        "value_type": 'list',
        "id": 'SHIPMENT_BATTERIES'
      }, {
        "name": "M\xC3\xA9todos de transporte del env\xC3\xADo",
        "tags": {
          "read_only": true,
          "hidden": true,
          "multivalued": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '7435890',
            "name": "Por avi\xC3\xB3n"
          }
        ],
        "relevance": 2,
        "value_type": 'list',
        "id": 'SHIPMENT_TRANSPORT_METHOD'
      }, {
        "name": "Embalaje del env\xC3\xADo",
        "tags": {
          "read_only": true,
          "hidden": true,
          "multivalued": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '7435891',
            "name": 'Bolsa'
          },
          {
            "id": '7435892',
            "name": 'Caja'
          },
          {
            "id": '7575937',
            "name": 'Sobre'
          },
          {
            "id": '7575938',
            "name": 'Voluminoso'
          },
          {
            "id": '7575939',
            "name": 'Auto-despachable'
          }
        ],
        "relevance": 2,
        "value_type": 'list',
        "id": 'SHIPMENT_PACKING'
      }, {
        "name": "Informaci\xC3\xB3n adicional requerida",
        "tags": {
          "read_only": true,
          "hidden": true,
          "multivalued": true
        },
        "hierarchy": 'ITEM',
        "attribute_group_name": 'Otros',
        "attribute_group_id": 'OTHERS',
        "values": [
          {
            "id": '7435893',
            "name": 'Tiene IMEI'
          },
          {
            "id": '7435894',
            "name": "Tiene n\xC3\xBAmero de serie"
          }
        ],
        "relevance": 2,
        "value_type": 'list',
        "id": 'ADDITIONAL_INFO_REQUIRED'
      }, {
        "name": 'JAN',
        "tags": {
          "used_hidden": true,
          "hidden": true,
          "validate": true,
          "variation_attribute": true,
          "multivalued": true
        },
        "hierarchy": 'PRODUCT_IDENTIFIER',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "value_type": 'string',
        "relevance": 2,
        "type": 'product_identifier',
        "id": 'JAN'
      }, {
        "name": 'GTIN-14',
        "tags": {
          "used_hidden": true,
          "hidden": true,
          "validate": true,
          "variation_attribute": true,
          "multivalued": true
        },
        "hierarchy": 'PRODUCT_IDENTIFIER',
        "attribute_group_name": 'Otros',
        "value_max_length": 255,
        "attribute_group_id": 'OTHERS',
        "value_type": 'string',
        "relevance": 2,
        "type": 'product_identifier',
        "id": 'GTIN14'
      }]
    end
  end
end
