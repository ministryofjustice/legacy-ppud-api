plugins {
  id("uk.gov.justice.hmpps.gradle-spring-boot") version "3.3.16"
  kotlin("plugin.spring") version "1.5.21"
}

configurations {
  testImplementation { exclude(group = "org.junit.vintage") }
}

// Force log4j2.version to 2.17 for CVE-2021-45105
project.extensions.extraProperties["log4j2.version"] = "2.17.0"
// Force logback.version to 1.2.9 (latest stable) for CVE-2021-42550
project.extensions.extraProperties["logback.version"] = "1.2.9"

dependencies {
  implementation("org.springframework.boot:spring-boot-starter-webflux")
}

tasks {
  withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
      jvmTarget = JavaVersion.VERSION_16.toString() // TODO Need Kotlin 1.6 to target JVM 17 - see PUD-1243
    }
  }
}

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(16)) // TODO Need Kotlin 1.6 to target JVM 17 - see PUD-1243
    vendor.set(JvmVendorSpec.matching("AdoptOpenJDK"))
  }
}
