package org.superbiz.application

import org.apache.tomee.embedded.Configuration
import org.apache.tomee.embedded.Container
import org.jboss.shrinkwrap.api.Archive
import org.jboss.shrinkwrap.api.exporter.ZipExporter
import org.jboss.shrinkwrap.api.spec.WebArchive
import java.nio.file.Files
import java.io.File
import org.jboss.shrinkwrap.api.ShrinkWrap

class TomEEApplication {

    def static startAndDeploy(Archive<?> archive) {
        try {
            val configuration = new Configuration()
            val String tomeeDir = Files.createTempDirectory("apache-tomee").toFile().getAbsolutePath()
            configuration.setDir(tomeeDir)
            configuration.setHttpPort(8080)

            val container = new Container()
            container.setup(configuration)

            val app = new File(Files.createTempDirectory("app").toFile().getAbsolutePath())
            app.deleteOnExit()

            val target = new File(app, "app.war")
            archive.^as(typeof(ZipExporter)).exportTo(target, true)
            container.start()

            container.deploy("app", target)
            container.await()

            registerShutdownHook(container)

        } catch (Exception e) {
            throw new IllegalArgumentException(e)
        }
    }

    def static registerShutdownHook(Container container) {
        Runtime.getRuntime().addShutdownHook(new Thread() {
        	override run() {
        		try {
                    if (container != null) {
                        container.stop()
                    }
                } catch (Exception e) {
                    throw new IllegalArgumentException(e)
                }
        	}
        });
    }

    def static run(Class<?>... clazzes) {
        run(ShrinkWrap.create(typeof(WebArchive)).addClasses(clazzes))
    }

    def static run(WebArchive archive) {
        startAndDeploy(archive)
    }
}
