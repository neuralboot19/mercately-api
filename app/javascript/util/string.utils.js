const truncate = (str, length = 10) => {
  return str.length > length ? str.substring(0, length) + "..." : str;
}

export default {
  truncate
};