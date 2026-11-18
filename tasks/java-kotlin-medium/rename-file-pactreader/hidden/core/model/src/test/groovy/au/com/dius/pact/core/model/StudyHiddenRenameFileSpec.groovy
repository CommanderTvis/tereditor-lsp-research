package au.com.dius.pact.core.model

import spock.lang.Specification

class StudyHiddenRenameFileSpec extends Specification {
  def 'top-level functions are reached through the facade of the renamed file'() {
    expect:
    PactReaderUtilsKt.queryStringToMap('a=1&b=2', true) == [a: ['1'], b: ['2']]
  }
}
