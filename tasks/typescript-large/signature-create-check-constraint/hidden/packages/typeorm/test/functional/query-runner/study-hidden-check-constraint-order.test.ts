import "reflect-metadata"
import { expect } from "chai"
import type { DataSource } from "../../../src"
import { Table } from "../../../src"
import { TableCheck } from "../../../src/schema-builder/table/TableCheck"
import {
    closeTestingConnections,
    createTestingConnections,
} from "../../utils/test-utils"

describe("query runner > createCheckConstraint takes the check first", () => {
    let dataSources: DataSource[]
    before(async () => {
        dataSources = await createTestingConnections({
            enabledDrivers: ["sqljs"],
            entities: [],
            schemaCreate: true,
            dropSchema: true,
        })
    })
    after(() => closeTestingConnections(dataSources))

    it("creates the check constraint on the table given second", () =>
        Promise.all(
            dataSources.map(async (dataSource) => {
                const queryRunner = dataSource.createQueryRunner()
                await queryRunner.createTable(
                    new Table({
                        name: "study_item",
                        columns: [
                            { name: "id", type: "integer", isPrimary: true },
                            { name: "amount", type: "integer" },
                        ],
                    }),
                    true,
                )
                await queryRunner.createCheckConstraint(
                    new TableCheck({ expression: `"amount" >= 0` }),
                    "study_item",
                )
                const table = await queryRunner.getTable("study_item")
                expect(table!.checks.length).to.equal(1)
                await queryRunner.release()
            }),
        ))
})
