/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import org.gradle.api.Project

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

private fun Project.readCompileSdk(): Int? {
    val androidExt = extensions.findByName("android") ?: return null
    val getCompileSdk = androidExt.javaClass.methods.firstOrNull {
        it.name == "getCompileSdk" && it.parameterCount == 0
    } ?: return null
    return getCompileSdk.invoke(androidExt) as? Int
}

private fun Project.applyCompileSdk(compileSdk: Int) {
    val androidExt = extensions.findByName("android") ?: return
    val setCompileSdk = androidExt.javaClass.methods.firstOrNull {
        it.name == "setCompileSdk" && it.parameterCount == 1
    } ?: return
    setCompileSdk.invoke(androidExt, compileSdk)
}

/**
 * Some transient Android library modules (for example ones generated from pub dependencies)
 * can still default to compileSdk 33. Force all Android modules in this build to app's
 * AAR metadata checks pass when dependencies require API 34+.
 */
subprojects {
    val appProject = rootProject.project(":app")

    afterEvaluate {
        if (path == ":app" || extensions.findByName("android") == null) {
            return@afterEvaluate
        }

        val appCompileSdk = appProject.readCompileSdk() ?: return@afterEvaluate
        applyCompileSdk(appCompileSdk)
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}