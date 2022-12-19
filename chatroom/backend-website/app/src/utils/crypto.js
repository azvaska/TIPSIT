function hexStringToArrayBuffer(hexString) {
  // remove the leading 0x
  hexString = hexString.replace(/^0x/, '');
  
  // ensure even number of characters
  if (hexString.length % 2 != 0) {
      console.log('WARNING: expecting an even number of characters in the hexString');
  }
  
  // check for some non-hex characters
  var bad = hexString.match(/[G-Z\s]/i);
  if (bad) {
      console.log('WARNING: found non-hex characters', bad);    
  }
  
  // split the string into pairs of octets
  var pairs = hexString.match(/[\dA-F]{2}/gi);
  
  // convert the octets to integers
  var integers = pairs.map(function(s) {
      return parseInt(s, 16);
  });
  
  var array = new Uint8Array(integers);
  
  return array.buffer;
}
export async function encrypt(iv, plaintext, pwHash) {
  pwHash=hexStringToArrayBuffer(pwHash);
    // const iv = new Uint8Array(Array.from(ivStr).map(ch => ch.charCodeAt(0)));
    // specify algorithm to use
    const alg = { name: 'AES-GCM', iv: iv };
    // generate key from pw
    const key = await crypto.subtle.importKey('raw', pwHash, alg, false, ['encrypt']);
    // encode plaintext as UTF-8
    const ptUint8 = new TextEncoder().encode(plaintext);
    // encrypt plaintext using key
    const ctBuffer = await crypto.subtle.encrypt(alg, key, ptUint8);
    // ciphertext as byte array
    const ctArray = Array.from(new Uint8Array(ctBuffer));
    // ciphertext as string
    const ctStr = ctArray.map(byte => String.fromCharCode(byte)).join('');
    // iv+ciphertext base64-encoded
    return btoa(ctStr);
  }
  
  /**
   * @param   {Window.Crypto} crypto
   * @param   {string} ciphertext
   * @param   {string} password
   * @returns {Promise<string>}
   */
  export async function decrypt(iv, ciphertext, pwHash) {
    pwHash=hexStringToArrayBuffer(pwHash);
    // specify algorithm to use
    const alg = { name: 'AES-GCM', iv: iv };
    // generate key from pw
    const key = await crypto.subtle.importKey('raw', pwHash, alg, false, ['decrypt']);
    // decode base64 ciphertext
    const ctStr = atob(ciphertext);
    // ciphertext as Uint8Array
    const ctUint8 = new Uint8Array(Array.from(ctStr).map(ch => ch.charCodeAt(0)));
    // note: why doesn't ctUint8 = new TextEncoder().encode(ctStr) work?
  
    try {
      // decrypt ciphertext using key
      const plainBuffer = await crypto.subtle.decrypt(alg, key, ctUint8);
      // return plaintext from ArrayBuffer
      return new TextDecoder().decode(plainBuffer);
    } catch (error) {
      console.log(error);
      throw new Error('decrypt failed');
      
    }
  }


  export function fromBinary(str) {
      // Going backwards: from bytestream, to percent-encoding, to original string.
      return new Uint8Array(
           atob(str)
              .split('')
              .map(function (c) {
                   return c.charCodeAt(0);
               })
        );
  }