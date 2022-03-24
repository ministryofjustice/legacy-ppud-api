plugins {
  id("uk.gov.justice.hmpps.gradle-spring-boot") version "4.1.1"
  kotlin("plugin.spring") version "1.5.21"
}

configurations {
  testImplementation { exclude(group = "org.junit.vintage") }
}

dependencies {
  implementation("org.springframework.boot:spring-boot-starter-webflux")
  implementation("org.springframework.boot:spring-boot-starter-actuator")
  implementation("io.micrometer:micrometer-registry-prometheus")

  testImplementation("com.natpryce:hamkrest:1.8.0.1")
}

tasks {
  withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
      jvmTarget = JavaVersion.VERSION_17.toString()
    }
  }
}

java {
  toolchain {
    languageVersion.set(JavaLanguageVersion.of(17))
    vendor.set(JvmVendorSpec.matching("AdoptOpenJDK"))
  }
}
