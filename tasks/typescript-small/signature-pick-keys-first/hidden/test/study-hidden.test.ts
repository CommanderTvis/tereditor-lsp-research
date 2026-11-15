import { describe, expect, it } from 'vitest'
import { create, is, number, object, pick, string, type } from '../src'

describe('pick takes the keys first', () => {
  it('picks from an object struct', () => {
    const S = pick(['b'], object({ a: number(), b: string() }))
    const value: { b: string } = create({ b: 'x' }, S)
    expect(value).toStrictEqual({ b: 'x' })
    expect(is({ a: 1, b: 'x' }, S)).toBe(false)
    expect(S.type).toBe('object')
  })

  it('picks from a type struct', () => {
    const S = pick(['a', 'c'], type({ a: number(), b: string(), c: string() }))
    expect(is({ a: 1, c: 'c', extra: true }, S)).toBe(true)
    expect(is({ a: 1 }, S)).toBe(false)
    expect(S.type).toBe('type')
  })
})
