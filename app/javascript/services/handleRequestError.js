export const handleRequestErrors = async (response) => {
  const jsonResponse = await response.json();

  if (response.ok) {
    showtoast(jsonResponse.message);
  } else {
    showtoast(jsonResponse.message);
    throw Error(response.statusText);
  }

  return jsonResponse;
}
