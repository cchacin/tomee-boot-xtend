Apache TomEE + Shrinkwrap == JavaEE Boot
============

Based on this [article](http://java.dzone.com/articles/apache-tomee-shrinkwrap-javaee) published in DZone by @lordofthejars

```xml
<dependencies>
  <dependency>
    <groupId>org.apache.openejb</groupId>
    <artifactId>tomee-embedded</artifactId>
    <version>1.7.1</version>
  </dependency>

  <dependency>
    <groupId>org.apache.openejb</groupId>
    <artifactId>openejb-cxf-rs</artifactId>
    <version>4.7.1</version>
  </dependency>
  
  <dependency>
    <groupId>org.apache.openejb</groupId>
    <artifactId>tomee-jaxrs</artifactId>
    <version>1.7.1</version>
  </dependency>
  
  <dependency>
    <groupId>org.jboss.shrinkwrap</groupId>
    <artifactId>shrinkwrap-depchain</artifactId>
    <version>1.2.2</version>
    <type>pom</type>
  </dependency>
</dependencies>
```

```xtend
@Stateless
@Path("/sample")
class SampleController {

    @GET
    @Produces("text/plain")
    def sample() {
        "Hello World"
    }

    def static main(String[] args) {
        TomEEApplication.run(typeof(SampleController));
    }
}

```

```xtend
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
```
