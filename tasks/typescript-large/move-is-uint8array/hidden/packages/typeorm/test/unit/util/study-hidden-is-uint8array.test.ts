import { expect } from "chai"
import { runInNewContext } from "node:vm"
import { isUint8Array } from "../../../src/util/guards/isUint8Array"

describe("util/guards/isUint8Array", () => {
    it("recognises Uint8Array values, also from another realm", () => {
        expect(isUint8Array(new Uint8Array([1]))).to.equal(true)
        expect(isUint8Array(runInNewContext("new Uint8Array([1])"))).to.equal(true)
        expect(isUint8Array(new Uint16Array([1]))).to.equal(false)
        expect(isUint8Array([1])).to.equal(false)
    })
})
