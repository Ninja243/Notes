import ballerina/crypto;
import ballerina/docker;
import ballerina/http;
// ?
import ballerina/io;
import ballerina/kubernetes;
//import ballerina/lang.'error;
import ballerina/time;
import ballerina/math;
import ballerina/lang.'int as ints;
//import ballerina/mime;
//import ballerina/log;
//import wso2/mongodb;

// The number assigned to this instance by the gateway.
// 0   <- not set
// 1-5 <- legal
// 5<  <- illegal
int myInstanceNumber = 0;
// The listener port number is 9090 plus the instance number (simplifies service discovery later)
int inport = 9090+myInstanceNumber;

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


@kubernetes:Ingress {
    hostname: "localhost",
    name: "Notes",
    path: "/"
}
@kubernetes:Service {
    serviceType: "NodePort",
    name: "Notes"
}
@kubernetes:Deployment {
    image: "localhost/Noter:v0.1",
    name: "Notes"
}

listener http:Listener test = new (9091, config = {

    secureSocket: {
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        },
        trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    }
});

//listener http:Listener test = new (9090, config = {
//
//    secureSocket: {
//        keyStore: {
//            path: "/usr/lib/ballerina/ballerina-1.0.1/distributions/jballerina-1.0.1/bre/security/ballerinaKeystore.p12",
//            password: "ballerina"
  //      },
    //    trustStore: {
      //      path: "/usr/lib/ballerina/ballerina-1.0.1/distributions/jballerina-1.0.1/bre/security/ballerinaTruststore.p12",
        //    password: "ballerina"
        //}
    //}
//});

@docker:Config {
    name: "Noter",
    tag: "v0.1"
}

// This port should be exposed but it looks like ballerina doesn't like having variables as port numbers?

//@docker:Expose {}
listener http:Listener l = new http:Listener(inport);
//listener http:Listener l = new http:Listener(inport);
// @http:ServiceConfig {
//     basePath: "/notes"
// }
// service testtube on l {
//     resource function testresource(http:Caller c, http:Request r, json test) {

//     }
// }

@http:ServiceConfig {
    basePath: "/notes"
}
service gossip on l {

    @http:ResourceConfig {
        methods: ["POST"]
    }
    resource function setInstanceNumber(http:Caller c, http:Request r) returns error? {
    // Get int given
    // set TODO instance number to int
//-----trying some stuff that likely makes no sense
    //getting int, set instence to the one the int that was given
    //json response = {
        //"instanceNo": instanceNo
    //};
    //instanceNo = instenaceNo.r;
    // json[] instanceJson;
    //http:Client instan = new("http://localhost:8080");
    // json[instanceJson.length()] = MyInstanceNumber;
    // var r = c->respond(MyInstanceNumber);
    // var newInstance = r.getJsonPayload();
    //         if (newInstance is json) {

    //         } else {
    //             http:Response resp = new;
    //             resp.setPayload("Error");
    //             var x = c -> respond();
    //         }

    http:Client cl = new ("http://localhost:4004");
    var x = cl ->get("/getInstanceNumber");
    if (x is error) {

    } else {
        var rw = x.getTextPayload();
            if (rw is string){
                var j = ints:fromString(rw);
                if (j is int) {
                myInstanceNumber = <@untainted>j;
                }
            }
        }
    }
    
    // TODO gossip init
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
        var t = shareGossip();
    }

@http:ResourceConfig {
        methods: ["POST"],
        path:"/postLedger"
    }
    resource function postLedger(http:Caller c, http:Request r) returns error?{
        var js = r.getJsonPayload();
        if (js is json) {
            Ledger n = {
                notice: "",
                prevLedgerHash: "",
                noticeHash: ""
            };
           Ledger ledger = genNewLedger(js.toString(), n);
            var mvc = addLedgerToDataStore(ledger);
        }
        http:Response resp = new;
        resp.setPayload("Ledger generated!");
        var x = c -> respond(resp);
        
    }

    @http:ResourceConfig {
        methods: ["GET"]
    }
    resource function giveAllLedgers(http:Caller c, http:Request r) returns error? {
        http:Response resp = new;
        json allNotes = {"DataStore": DataStore.toString()};
        // string[] keys = DataStore.keys();
        // int j = 0;
        // while (j<keys.length()) {
        //     int i = 0;
        //     while (i<DataStore[keys[j]].length()){

        //     }
        //     j = j+1;
        //}
        resp.setJsonPayload(allNotes);
        var x = c->respond(resp);
    }
    @http:ResourceConfig {
        methods: ["GET"]
    }
    resource function getSpecificLedger(http:Caller c, http:Request r) returns error? {

    }
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/notes/{yearToGet}"
    }
    resource function getSpecificYear(http:Caller c, http:Request r, string yearToGet) returns error? {
        http:Response resp = new;
        resp.setPayload(DataStore[yearToGet].toString());
        var x = c -> respond(resp);
    }
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/notes/{yearToGet}/{monthToGet}"
    }
    resource function getSpecificMonth(http:Caller c, http:Request r, string yearToGet, string monthToGet) returns error? {
        http:Response resp = new;
        var s = ints:fromString(monthToGet);
        if (s is int){
        var Y = DataStore[yearToGet];
        if (Y is year) {
            resp.setPayload(Y.Month[s].toString());
            var x = c -> respond(resp);}
        }
        
    }
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/notes/{yearToGet}/{monthToGet}/{weekToGet}"
    }
    // TODO
    resource function getSpecificWeek(http:Caller c, http:Request r, string yearToGet, string monthToGet, string weekToGet) returns error? {
         http:Response resp = new;
         resp.setPayload("");
        var x = c -> respond(resp);
        // var s = ints:fromString(monthToGet);
        // if (s is int){
        // var Y = DataStore[yearToGet];
        // if (Y is year) {
        //     var M = Y.Month[s];
        //     var w = ints:fromString(weekToGet);
        //     if (w is int) {
        //     var W = M.week[w];
        //     if (W is week) {
        //         resp.setPayload(W.toString());
        //         var x = c -> respond(resp);}
        //     }
        // }
        
        
    }
    @http:ResourceConfig {
        methods: ["GET"]
    }
    resource function getSpecificDay(http:Caller c, http:Request r) returns error? {
        
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

            // TODO
            if (content == "") {
                //
                var newGossip = r.getJsonPayload();
                if (newGossip is json) {

                } else {
                    http:Response resp = new;
                    resp.setPayload("Error");
                    var x = c -> respond();
                }
            }
        }
        var t = shareGossip();
    }

}

function genNewLedger(string note, Ledger prev) returns Ledger {
    Ledger toreturn = {
        notice: note,
        noticeHash: crypto:hashSha512(note.toBytes()).toString(),
        prevLedgerHash: prev.prevLedgerHash
    };

    return toreturn;
}

function shareGossip() returns error? {
    if (myInstanceNumber == 0) {
        // Instance not assigned so probably not part of a group
    } else if (myInstanceNumber>0 && myInstanceNumber<6) {
        var instanceToGossipWith = math:randomInRange(1,6);
        // Make sure we don't gossip with ourself
        while (instanceToGossipWith == myInstanceNumber){
            instanceToGossipWith = math:randomInRange(1,6);
        }
        // TODO
        if (instanceToGossipWith is int) {
        string url = "http://localhost:";
        int port = 9090+instanceToGossipWith;
        url = url+port.toString();
        http:Client ep = new http:Client(url);
        } else {
            io:println("Error getting a random number");
        }
    } else {
        // Instance number not legal
    }
}


// Get the date and add the right time record to the data store if it does not exist
function addLedgerToDataStore(Ledger l) returns error? {
    time:Time currentTime = time:currentTime();
    string thisYear = time:getYear(currentTime).toString();
    string thisMonth = time:getMonth(currentTime).toString();
    string thisDay = time:getDay(currentTime).toString();
    int iThisDay = time:getMonth(currentTime);
    // Work out the number of weeks that have passed since the day in this month
    int t = 0;
    while (t * 7 < iThisDay) {
        t = t + 1;
    }
    // Make sure we don't overshoot
    t = t - 1;
    string thisWeek = t.toString();
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
                    break;
                }
                j = j + 1;
            }
            if (monthFound) {
                // Get Month
                month Month = Year.Month[j];
                // Search for the right week in the month
                boolean weekFound = false;
                j = 0;
                while (j < Month.length()) {
                    if (Month.Week[j].toString() == thisWeek) {
                        weekFound = true;
                        break;
                    }
                    j = j + 1;
                }
                if (weekFound) {
                    week Week = Month.Week[j];
                    // Search for the right day
                    j = 0;
                    boolean dayFound = false;
                    while (j < Week.length()) {
                        if (Week.Day[j].toString() == thisDay) {
                            dayFound = true;
                            break;
                        }
                        j = j + 1;
                    }
                    if (dayFound) {
                        day Day = Week.Day[j];
                        // Add the ledger to the array in the right day
                        Day.ledger[Day.ledger.length()] = l;
                    } else {
                        // Add day to week and ledger to day
                        Ledger[] ledgers = [];
                        ledgers[ledgers.length()] = l;
                        day Day = {
                            ledger: ledgers
                        };
                        Week.Day[iThisDay] = Day;
                    }
                } else {
                    // Add week to month, day to week, ledger to day
                    Ledger[] ledgers = [];
                    ledgers[ledgers.length()] = l;
                    day Day = {
                        ledger: ledgers
                    };
                    day[] Days = [];
                    Days[iThisDay] = Day;
                    week Week = {
                        Day: Days
                    };
                    Month.Week[t] = Week;
                }
            } else {
            // Add Month to year, week to month, day to week, ledger to day
            Ledger[] ledgers = [];
                    ledgers[ledgers.length()] = l;
                    day Day = {
                        ledger: ledgers
                    };
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
                    Month.Week[t] = Week;
            }
        } else {
            // Year isn't a year?
            io:println("Panic");
        }
    } else {
        int iThisYear = time:getYear(currentTime);
        int iThisMonth = time:getMonth(currentTime);
        //int iThisDay = time:getMonth(currentTime);
        // Work out the number of weeks that have passed since the day in this month
        //int t = 0;
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
    var Year = DataStore[thisYear];
    if (Year is year) {
        // Look through the months stored to make sure there are the right amount of them
        if (Year.Month.length() > 12) {
        // Panic
        io:println("Invalid option, oopsie");
        } else if (Year.Month.length() < 0) {
        // Panic
        io:println("Invalid option, oopsie");
        } else {
            // Year is ok
            j = 0;
            while (j<Year.Month.length()) {
                // Look through the weeks stored to make sure there are the right amount of them
                if (Year.Month[j].Week.length() > 52) {
                    // Panic
                    io:println("Invalid option, oopsie");
                } else if (Year.Month[j].Week.length() < 0) {
                    // Panic
                    io:println("Invalid option, oopsie");
                } else {
                    // Month ok
                    int i = 0;
                    // Look through the days stored to make sure there are the right amount of them
                    while (i<Year.Month[j].Week.length()) {
                        if (Year.Month[j].Week[i].length() > 7) {
                            // Panic
                            io:println("Invalid option, oopsie");
                        } else if (Year.Month[j].Week[i].length() < 0) {
                            // Panic
                            io:println("Invalid option, oopsie");
                        } else {
                            // Week ok, everything seems fine
                        }
                        i = i+1;
                    }
                }
                j = j+1;
            }
        }

    } else {
    // Panic
    io:println("Invalid option, oopsie");
    }
}

public function yearMapToJson(map<year> m) returns error? {
   
}

public function monthMapToJson(map<month> m) returns error? {

}

public function weekMapToJson(map<week> m) returns error? {

}

public function dayMapToJson(map<day> m) returns error? {
    json toreturn = {};
    string[] keys = m.keys();
    int j = 0;
    while (j<keys.length()) {
        toreturn = {j:m.get(keys[j]).toString()};
        j = j+1;
    }
}

public function main() {
    var t = shareGossip();
}