import ballerina/docker;
import ballerina/http;
// ?
import ballerina/io;
import ballerina/kubernetes;
//import ballerina/log;

@docker:Config {
    name: "Noter",
    tag: "v0.1"
}
@kubernetes:Ingress {
    hostname: "localhost",
    name: "Notes",
    path: "/"
}
listener http:Listener test = new (9090, config = {

    secureSocket: {
        keyStore: {
            path: "/usr/lib/ballerina/ballerina-1.0.1/distributions/jballerina-1.0.1/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        },
        trustStore: {
            path: "/usr/lib/ballerina/ballerina-1.0.1/distributions/jballerina-1.0.1/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    }
});

@kubernetes:Service {
    serviceType: "NodePort",
    name: "Notes"
}
@kubernetes:Deployment {
    image: "localhost/Noter:v0.1",
    name: "Notes"
}
@http:ServiceConfig {
    basePath: "/notes"
}
service testtube on new http:Listener(9090) {
    resource function testresource(http:Caller c, http:Request r, json test) {

    }
}
// Prints `Hello World`.

public function main() {
    io:println("Hello World!");
}
