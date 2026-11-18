package au.com.dius.pact.consumer.dsl

import spock.lang.Specification

class StudyHiddenRenameSpec extends Specification {
  def 'the first DSL step carries its new name'() {
    expect:
    PactDslRequestNoPath.name == 'au.com.dius.pact.consumer.dsl.PactDslRequestNoPath'
  }
}
