package com.bule.free.ireader.common.library.java1_8;

/**
 * Created by suikajy on 2019/4/10
 */
@FunctionalInterface
public interface Supplier<T> {
    /**
     * Gets a result.
     *
     * @return a result
     */
    T get();
}
