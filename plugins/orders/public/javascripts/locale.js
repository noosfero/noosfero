if (typeof locale === 'undefined') {

locale = 'pt'; //FIXME: don't hardcode
standard_locale = 'en';
code_locale = 'code';
locale_data = {
  'code': {
    'currency': {
      'delimiter': '',
      'separator': '.',
      'decimals': null,
    }
  },
  'en': {
    'currency': {
      'delimiter': ',',
      'separator': '.',
      'decimals': 2,
    }
  },
  'pt': {
    'currency': {
      'delimiter': '.',
      'separator': ',',
      'decimals': 2,
    }
  },
}

function localize_currency(value, to, from) {
  if (!to)
    to = locale;
  if (!from)
    from = standard_locale;
  var lvalue = unlocalize_currency(value, from);
  from = standard_locale;
  lvalue = lvalue.toFixed(locale_data[to].currency.decimals);
  lvalue = lvalue.replace(locale_data[from].currency.delimiter, locale_data[to].currency.delimiter);
  lvalue = lvalue.replace(locale_data[from].currency.separator, locale_data[to].currency.separator);
  return lvalue;
}

function unlocalize_currency(value, from) {
  if (!value)
    return 0;
  if (!from)
    from = locale;
  var lvalue = value.toString();
  var number;
  // check if it already a float
  if (!isNaN(number = parseFloat(lvalue)))
    return number;

  var to = code_locale;
  lvalue = lvalue.replace(locale_data[from].currency.delimiter, locale_data[to].currency.delimiter);
  lvalue = lvalue.replace(locale_data[from].currency.separator, locale_data[to].currency.separator);
  number = parseFloat(lvalue);
  return number;
}

}
