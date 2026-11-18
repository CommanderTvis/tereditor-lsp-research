package slack.lint.compose

import org.junit.Assert.assertEquals
import org.junit.Test

class StudyHiddenRenameTest {
  @Test
  fun checkClassCarriesTheNewName() {
    assertEquals("ComposeModifierReused", ModifierReusedCheck.ISSUE.id)
    assertEquals("slack.lint.compose.ModifierReusedCheck", ModifierReusedCheck::class.java.name)
  }
}
