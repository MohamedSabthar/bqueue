import ballerina/lang.runtime;
import ballerina/test;

@test:Config
function testPutAndTake() returns error? {
    BlockingQueue bq = new;
    Data data = new (10, false);
    check bq.put(data);
    Data polledData = check bq.take();
    test:assertEquals(data.getIsPresent(), polledData.getIsPresent());
    test:assertEquals(data.getValue(), polledData.getValue());
}

@test:Config
isolated function testBlockingQueue() returns error? {
    final BlockingQueue bq = new;

    worker A returns error? {
        record {} data = check bq.take();
        test:assertEquals(data, {value: 1, isPresent: true});
    }

    worker B returns error? {
        runtime:sleep(2);
        map<anydata> data = {value: 1, isPresent: true};
        check bq.put(data);
    }

    check wait A;
    check wait B;
}

@test:Config
isolated function testTakeTimeout() returns error? {
    final BlockingQueue bq = new;

    worker A returns error? {
        any err = check bq.take(timeout = 1000);
        test:assertTrue(err is ());
        map<anydata> data = check bq.take(timeout = 1100);
        test:assertEquals(data, {value: 1, isPresent: true});
    }

    worker B returns error? {
        runtime:sleep(2);
        map<anydata> data = {value: 1, isPresent: true};
        check bq.put(data);
    }

    check wait A;
    check wait B;
}

@test:Config
isolated function testPeek() returns error? {
    final BlockingQueue bq = new;

    worker A returns error? {
        any val = check bq.peek();
        test:assertTrue(val is ());
        runtime:sleep(3);
        map<anydata> data = check bq.peek();
        test:assertEquals(data, {value: 1, isPresent: true});
        data = check bq.take(timeout = 1100);
        test:assertEquals(data, {value: 1, isPresent: true});
    }

    worker B returns error? {
        runtime:sleep(2);
        map<anydata> data = {value: 1, isPresent: true};
        check bq.put(data);
    }

    check wait A;
    check wait B;
}
