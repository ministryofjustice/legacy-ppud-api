package uk.gov.justice.digital.hmpps.legacyppudapi

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication()
class LegacyPpudApi

fun main(args: Array<String>) {
  runApplication<LegacyPpudApi>(*args)
}
