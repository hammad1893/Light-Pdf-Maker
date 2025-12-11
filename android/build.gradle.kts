buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubBuild = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubBuild)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
