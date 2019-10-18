import ballerina/crypto;
import ballerina/docker;
import ballerina/http;
// ?
import ballerina/io;
import ballerina/kubernetes;
//import ballerina/log;
//import wso2/mongodb;

map<Ledger> DataStore = {};
Ledger newLedgerForGossip = {
    notice: "",
    noticeHash: "",
    prevLedgerHash: ""
};

public type Ledger record {
    string noticeHash;
    string notice;
    string prevLedgerHash;
};

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

// TODO Service for push/pull from db

listener http:Listener l = new (9090);
@http:ServiceConfig {
    basePath: "/notes"
}
service testtube on l {
    resource function testresource(http:Caller c, http:Request r, json test) {

    }
}

// TODO Gossip service here
@http:ServiceConfig {
    basePath: "/notes"
}
service gossip on l {
    @http:ResourceConfig {
        methods: ["GET"]
    }
    resource function getLatest(http:Caller c, http:Request r) returns error? {
        http:Response resp = new;
        json ledger = {"note": newLedgerForGossip.notice, "noteHash": newLedgerForGossip.noticeHash, "previousNoteHash": newLedgerForGossip.prevLedgerHash};
        json newGossip = {"Ledger": ledger};
        resp.setJsonPayload(newGossip);
        resp.statusCode = 200;
        var x = c->respond(resp);
        if (x is error) {
            io:println(x);
        }
    }
    @http:ResourceConfig {
        methods: 
    }
    resource function giveLatest(http:Caller c, http:Request r) {

    }
}

public function genNewLedger(string note, Ledger prev) returns Ledger {
    Ledger toreturn = {
        notice: note,
        noticeHash: crypto:hashSha512(note.toBytes()).toString(),
        prevLedgerHash: prev.prevLedgerHash
    };

    return toreturn;
}

// Prints `Hello World`.

public function main() {
    io:println("Hello World!");
}
