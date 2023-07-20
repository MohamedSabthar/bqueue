import ballerina/jballerina.java;

# Represents a blocking queue
public isolated class BlockingQueue {

    # Initialize the BlockingQueue.
    public isolated function init() {
        self.externInit();
    }

    isolated function externInit() = @java:Method {
        'class: "io.crates.BlockingQueue"
    } external;

    # Put an element into the queue.
    # + data - The element to be put into the queue
    # + return - nil if the element was successfully added to this queue, or an error otherwise
    public isolated function put(any data) returns error? = @java:Method {
        'class: "io.crates.BlockingQueue"
    } external;

    # Retrieve and remove an element from the head of the queue.
    # If the queue is empty, this operation will block until an element becomes available.
    # Optionally, you can specify a timeout to wait for an element to become available.
    # + timeout - The maximum time to wait for an element to become available.
    # If not specified, this operation will block indefinitely.
    # On timeout, this operation will return nil
    # + t - They type to which the element should be casted to
    # + return - The element that was removed from the queue, or an error if the operation failed
    public isolated function take(decimal? timeout = (), typedesc<any> t = <>) returns t|error = @java:Method {
        'class: "io.crates.BlockingQueue"
    } external;

    # Retrieve, but do not remove, the head of the queue.
    # + t - They type to which the element should be casted to
    # + return - The element that was retrieve from the queue or nil if the queue is empty. 
    # An error is returned if data cannot be casted to the specified type
    public isolated function peek(typedesc<any> t = <>) returns t|error = @java:Method {
        'class: "io.crates.BlockingQueue"
    } external;

    isolated function dataBind(any data, typedesc<any> t) returns any|error {
        return data.ensureType(t);
    }
}

