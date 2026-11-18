package org.jetbrains.kotlinx.dataframe

import io.kotest.matchers.shouldBe
import org.jetbrains.kotlinx.dataframe.schema.TypedFrameSchema
import org.junit.Test
import kotlin.test.assertFailsWith

class StudyHiddenRenameFileTest {
    @Test
    fun newNameExistsAndOldNameIsGone() {
        TypedFrameSchema::class.qualifiedName shouldBe "org.jetbrains.kotlinx.dataframe.schema.TypedFrameSchema"
        assertFailsWith<ClassNotFoundException> { Class.forName("org.jetbrains.kotlinx.dataframe.schema." + "DataFrame" + "Schema") }
    }
}
