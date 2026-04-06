// Hapus semua kode lama dan ganti dengan ini
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Cara baru mengatur build directory di Gradle Kotlin DSL
rootProject.layout.buildDirectory.set(file("${project.projectDir}/../build"))

subprojects {
    val newSubprojectBuildDir = rootProject.layout.buildDirectory.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}