package thx.promise;

import thx.promise.Promise;
using thx.Functions;

/**
 * The ReaderT monad transformer specialized to Promise.
 */
abstract PromiseR<R, A>(R -> Promise<A>) from R -> Promise<A> {
  public static function pure<R, A>(a: A): PromiseR<R, A> {
    return function(_: R) return Promise.value(a);
  }

  public static function ask<R>(): PromiseR<R, R> {
    return function(x: R) return Promise.value(x);
  }

  public inline function run(r: R): Promise<A> {
    return this(r);
  }

  public function map<B>(f: A -> B): PromiseR<R, B> {
    return flatMap(pure.compose(f));
  }

  public function ap<B>(r: PromiseR<R, A -> B>): PromiseR<R, B> {
    return flatMap(function(a: A) return r.map.fn(_(a)));
  }

  public function flatMap<B>(f: A -> PromiseR<R, B>): PromiseR<R, B> {
    return function(r: R) {
      return run(r).flatMap(function(a: A) return f(a).run(r));
    }
  }

  public function parWith<B, C>(that: PromiseR<R, B>, f: A -> B -> C): PromiseR<R, C> {
    return function(r: R) return Promises.par(f, run(r), that.run(r));
  }
}
