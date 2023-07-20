## Overview

The Blocking Queue Module provides an implementation of a Blocking Queue, which is an unbounded queue based on a linked list data structure. This Blocking Queue allows multiple threads to safely enqueue and dequeue elements concurrently, while also offering blocking operations when the queue is empty.

### API

1. `put(data)`
   - Description: Put an element into the queue.
   - Parameters:
     - `data`: The element to be put into the queue.
   - Return:
     - `nil`: If the element was successfully added to the queue.
     - `error`: If an error occurs during the operation.

2. `take(timeout?, t)`
   - Description: Retrieve and remove an element from the head of the queue.
   - Parameters:
     - `timeout` (optional): The maximum time to wait for an element to become available. If not specified, this operation will block indefinitely.
     - `t` (optional): The type to which the element should be casted to.
   - Return:
     - The element that was removed from the queue if the operation is successful.
     - `nil`: On timeout when no element is available in the queue.
     - `error`: If the operation fails or when data binding to the specified type fails.

3. `peek(t)`
   - Description: Retrieve, but do not remove, the head of the queue.
   - Parameters:
     - `t`: The type to which the element should be casted to.
   - Return:
     - The element retrieved from the queue, or `nil` if the queue is empty.
     - `error`: If data cannot be casted to the specified type.

### Usage Example

```ballerina
import ballerina/lang.runtime;
import crates/blocking_queue as bq;

public function main() returns error?{
    final bq:BlockingQueue bq = new;

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
```
