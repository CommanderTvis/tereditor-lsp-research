import { decodeBase64, decodeBase64Url, encodeBase64, encodeBase64Url } from './base64'

describe('src/utils/base64', () => {
  it('round-trips bytes through base64 and base64url', () => {
    const bytes = new Uint8Array([0, 251, 255, 104, 105])
    expect(Array.from(decodeBase64(encodeBase64(bytes.buffer)))).toEqual(Array.from(bytes))
    expect(encodeBase64Url(bytes.buffer)).not.toMatch(/[+/]/)
    expect(Array.from(decodeBase64Url(encodeBase64Url(bytes.buffer)))).toEqual(Array.from(bytes))
  })
})
