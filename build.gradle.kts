plugins {
  id("uk.gov.justice.hmpps.gradle-spring-boot") version "3.3.16"
  kotlin("plugin.spring") version "1.5.21"
}

configurations {
  testImplementation { exclude(group = "org.junit.vintage") }
}

// Force log4j2.version to 2.17 for CVE-2021-45105
project.extensions.extraProperties["log4j2.version"] = "2.17.0"

dependencies {
  implementation("org.springframework.boot:spring-boot-starter-webflux")
}

tasks {
  compileKotlin {
    kotlinOptions {
      jvmTarget = "16"
    }
  }
}
