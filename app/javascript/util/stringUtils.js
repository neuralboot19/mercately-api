const addStr = (str, index, stringToAdd) => {
  return str.substring(0, index) + stringToAdd + str.substring(index, str.length);
}

const formatSentUrl = (originalUrl) => {
  if (!originalUrl) return originalUrl;

  const formats = 'if_w_gt_1000/c_scale,w_1000/if_end/q_auto';
  return originalUrl.replace('/image/upload', `/image/upload/${formats}`);
}

const formatSelectedFastAnswerUrl = (originalUrl, fileType) => {
  if (fileType === 'file') return originalUrl;

  const formats = 'c_scale,w_50/q_auto';
  return originalUrl.replace('/image/upload', `/image/upload/${formats}`);
}

const formatSelectedProductUrl = (originalUrl) => {
  if (!originalUrl) return originalUrl;

  const formats = 'c_scale,w_50/q_auto';
  return originalUrl.replace('/image/upload', `/image/upload/${formats}`);
}

export default {
  addStr,
  formatSentUrl,
  formatSelectedFastAnswerUrl,
  formatSelectedProductUrl
};
