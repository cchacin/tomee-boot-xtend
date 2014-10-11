package org.superbiz.application;

import javax.ejb.Stateless;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;

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
