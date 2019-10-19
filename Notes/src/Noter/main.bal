import ballerina/crypto;
import ballerina/docker;
import ballerina/http;
// ?
import ballerina/io;
import ballerina/kubernetes;
//import ballerina/lang.'error;
import ballerina/time;
//import ballerina/mime;
//import ballerina/log;
//import wso2/mongodb;

//

// Map of year records which contain up to 12 month records
// each which contain up to 4 week records each which contain
// up to 7 day records each. This structure was chosen to make
// sure that we can search notes by the date they were posted.
// The assigning of ledgers to days stored using the structure
// described above is done in the addLedgerToDataStore() function
// found around the bottom of this file.
map<year> DataStore = {};


// https://github.com/ballerina-platform/ballerina-lang/releases <- no more fixed length arrays unfortunately
public type day record {
    Ledger[] ledger;
};

public type week record {
    day[] Day;
};

public type month record {
    week[] Week;
};

public type year record {
    month[] Month;

};

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
        methods: ["POST"],
        path: "/giveLatest"
    }
    resource function giveLatest(http:Caller c, http:Request r) returns error? {
        if (r.hasHeader("content-type")) {
            string content = r.getContentType();
            //string baseType = mime:getMediaType(content);
            // If JSON, check for Ledger information, then add it to a the new ledger and to the data store
            if (content == "") {

            }
        }
    }
}

// Get the date and add the right time record to the data store if it does not exist
public function addLedgerToDataStore(Ledger l) returns error? {
    time:Time currentTime = time:currentTime();
    string thisYear = time:getYear(currentTime).toString();
    string thisMonth = time:getMonth(currentTime).toString();
    string thisDay = time:getDay(currentTime).toString();
    int j = 0;
    if DataStore.hasKey(thisYear) {
        var Year = DataStore[thisYear];
        if (Year is year) {
            // Look for Month in month array in Year record
            j = 0;
            boolean monthFound = false;
            while (j < Year.Month.length()) {
                if (Year.Month[j].toString() == thisMonth) {
                    monthFound = true;
                }
                j = j + 1;
            }
            if (monthFound) {
            // Get Month
            //var Month = DataStore
            } else {
            // Add Month

            }
        } else {
            io:println("Panic");
        }
    } else {
        int iThisYear = time:getYear(currentTime);
        int iThisMonth = time:getMonth(currentTime);
        int iThisDay = time:getMonth(currentTime);
        // Work out the number of weeks that have passed since the day in this month
        int t = 0;
        while (t * 7 < iThisDay) {
            t = t + 1;
        }
        // Minus one so we don't overshoot the day
        t = t - 1;
        // Get the day of the week from iThisDay
        iThisDay = iThisDay - (t * 7);
        Ledger[] LedgersForThisDay = [];
        LedgersForThisDay[LedgersForThisDay.length()] = l;
        // Add new year, month, week and day for ledger
        day Day = {
            ledger: LedgersForThisDay
        };
        // Make a new array to put in the Week record and put the day record in the right spot in the array
        day[] Days = [];
        Days[iThisDay] = Day;

        week Week = {
            Day: Days
        };
        week[] Weeks = [];
        Weeks[t] = Week;

        month Month = {
            Week: Weeks
        };
        month[] Months = [];
        Months[iThisMonth] = Month;

        year Year = {
            Month: Months
        };

        // Add the year to the Data Store
        DataStore[thisYear] = Year;

    }
// Make sure there are an appropriate amount of records nested (13 months would be illegal for example)
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

//public function main() {
//   io:println("Hello World!");
//}
