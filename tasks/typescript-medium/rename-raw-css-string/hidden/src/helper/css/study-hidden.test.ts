import { css, rawCss } from './index'
import { rawCss as rawCssFromDom } from '../../jsx/dom/css'

describe('rawCss', () => {
  it('is exported by the css helper and by hono/jsx/dom/css', () => {
    expect(rawCssFromDom).toBe(rawCss)
  })

  it('inserts its value unescaped', async () => {
    const className = css`
      content: '${rawCss('say "Hello!"')}';
    `
    expect(String(await className)).toMatch(/^css-\d+$/)
  })
})
