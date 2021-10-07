import {
  DEFAULT_IMAGE_SIZE_TRANSFER,
  DEFAULT_FILE_SIZE_TRANSFER,
  MAX_IMAGE_SIZE_TRANSFER,
  MAX_FILE_SIZE_TRANSFER,
  MAX_IMAGE_SIZE_TRANSFER_WS,
  MAX_FILE_SIZE_TRANSFER_MSN_IG
} from '../constants/chatFileSizes';


const isDefaultImageSize = (file) => {
  return file.size <= DEFAULT_IMAGE_SIZE_TRANSFER
};

const isDefaultFileSize = (file) => {
  return file.size <= DEFAULT_FILE_SIZE_TRANSFER
};

const isMaxImageSize = (file) => {
  return file.size <= MAX_IMAGE_SIZE_TRANSFER
};

const isMaxFileSize = (file) => {
  return file.size <= MAX_FILE_SIZE_TRANSFER
};

const isValidImageSizeForWs = (file) => {
  return file.size <= MAX_IMAGE_SIZE_TRANSFER_WS
};

const isValidFileSizeForMsnOrIg = (file) => {
  return file.size <= MAX_FILE_SIZE_TRANSFER_MSN_IG
};

const sizeFileInMB = (size) => {
  return size / (1024 * 1024);
};

export default {
  isDefaultImageSize,
  isDefaultFileSize,
  isMaxImageSize,
  isMaxFileSize,
  isValidImageSizeForWs,
  isValidFileSizeForMsnOrIg,
  sizeFileInMB
};