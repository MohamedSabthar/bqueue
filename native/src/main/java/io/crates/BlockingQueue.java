package io.crates;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Future;
import io.ballerina.runtime.api.PredefinedTypes;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.creators.TypeCreator;
import io.ballerina.runtime.api.types.UnionType;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;

import static io.ballerina.runtime.api.PredefinedTypes.TYPE_ANY;
import static java.util.concurrent.TimeUnit.MILLISECONDS;

/**
 * Native implementation of the crates/bqueue module.
 */
public class BlockingQueue {
    private static final String QUEUE = "queue";
    private static final String DATA_BINDING_FUNCTION = "dataBind";
    // Using an executor service to submit tasks to avoid blocking the ballerina strands.
    private static final ExecutorService executor = Executors.newCachedThreadPool();

    public static void externInit(BObject bObject) {
        bObject.addNativeData(QUEUE, new LinkedBlockingQueue<>());
    }

    public static Object put(Environment environment, BObject bObject, Object value) {
        Future future = environment.markAsync();
        LinkedBlockingQueue<Object> queue = (LinkedBlockingQueue<Object>) bObject.getNativeData(QUEUE);
        executor.submit(() -> {
            try {
                queue.put(value);
                future.complete(null);
            } catch (InterruptedException e) {
                BString errorMessage = StringUtils.fromString(
                        "Error while putting element to queue: " + e.getMessage());
                future.complete(ErrorCreator.createError(errorMessage));
            }
        });
        return null;
    }

    public static Object take(Environment environment, BObject bObject, Object timeout, BTypedesc typedesc) {
        Future future = environment.markAsync();
        LinkedBlockingQueue<Object> queue = (LinkedBlockingQueue<Object>) bObject.getNativeData(QUEUE);
        executor.submit(() -> {
            try {
                Object value = (timeout == null) ? queue.take() :
                        queue.poll(((BDecimal) timeout).decimalValue().longValue(), MILLISECONDS);
                Object[] args = new Object[]{value, true, typedesc, true};
                ExecutionCallback callback = new ExecutionCallback(future);
                environment.getRuntime()
                        .invokeMethodAsyncConcurrently(bObject, DATA_BINDING_FUNCTION, null, null, callback, null,
                                                       TYPE_ANY, args);
            } catch (InterruptedException e) {
                BString errorMessage = StringUtils.fromString(
                        "Error while taking element from queue: " + e.getMessage());
                future.complete(ErrorCreator.createError(errorMessage));
            }
        });
        return null;
    }

    public static Object peek(Environment environment, BObject bObject, BTypedesc typedesc) {
        Future future = environment.markAsync();
        LinkedBlockingQueue<Object> queue = (LinkedBlockingQueue<Object>) bObject.getNativeData(QUEUE);
        executor.submit(() -> {
            Object value = queue.peek();
            Object[] args = new Object[]{value, true, typedesc, true};
            ExecutionCallback callback = new ExecutionCallback(future);
            UnionType returnType = TypeCreator.createUnionType(TYPE_ANY, PredefinedTypes.TYPE_ERROR);
            environment.getRuntime()
                    .invokeMethodAsyncConcurrently(bObject, DATA_BINDING_FUNCTION, null, null, callback, null,
                                                   returnType, args);
        });
        return null;
    }
}

