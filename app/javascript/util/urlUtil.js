const checkForUrls = (text) => {
  if (!text) return;
  const expression = /(https?:\/\/)?[\w\-~]+(\.[a-zA-Z\-~]+)+(\/[\w\-~@:%]*)*(\.[a-zA-Z\-~]+)*(#[\w-]*)?(\?[^\s]*)?/gi;
  const regex = new RegExp(expression);
  let match = '';
  const splitText = [];
  let startIndex = 0;

  while ((match = regex.exec(text)) !== null) {
    splitText.push({ text: text.substr(startIndex, (match.index - startIndex)), type: 'text' });

    const cleanedLink = text.substr(match.index, (match[0].length));
    splitText.push({ text: cleanedLink, type: 'link' });

    startIndex = match.index + (match[0].length);
  }

  if (startIndex < text.length) splitText.push({ text: text.substr(startIndex), type: 'text' });

  let message = '';
  splitText.forEach((elem) => {
    if (elem.type === 'text') {
      message += elem.text;
    } else if (elem.type === 'link') {
      const hasProtocol = /^https?:\/\//.test(elem.text);
      message += `<a href="${hasProtocol ? '' : '//'}${elem.text}" target="_blank">${elem.text}</a>`;
    }
  });

  return message;
};

export default checkForUrls;
