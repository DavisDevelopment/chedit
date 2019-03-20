package ch;

import format.tools.Inflate;
import format.tools.Deflate;
import haxe.extern.EitherType as Or;

import haxe.io.*;
import haxe.crypto.*;
import haxe.DynamicAccess;
import haxe.Json;

import ch.BigNumber;
import ch.Decimal;

import haxe.ds.Option;

import pm.Ref;
import pm.Object;
import pm.Arch;

using pm.Options;
using pm.Functions;

class Save {
    private var src(default, null): Dat;
    private var data(default, null): Map<String, Attr>;

    public function new(d: Dat) {
        src = d;
        data = new Map();
        _pull();
    }

    public function keys() { return data.keys(); }

    public function prop(key: String):Option<Attr> {
        return if (data.exists( key )) Option.Some(data[key]) else Option.None;
    }

    public function r(key: String):Attr {
        switch (prop( key )) {
            case None:
                return data[key] = new Attr();

            case Some(a):
                return a;
        }
    }

    public inline function mod(key:String, fn:ModFn) {
        return fn.apply(r(key));
    }

    public function get(key: String):Null<Val> {
        return switch (prop( key )) {
            case None|Some(null): null;
            case Some(a): a.get();
        }
    }

    public function set(key:String, val:Val) {
        switch (prop( key )) {
            case Some(r):
                r.assign( val );

            case None:
                data[key] = Ref.to( val );
        }
    }

    public function remove(k: String):Bool {
        return data.remove( k );
    }

    public function exists(k: String):Bool {
        return data.exists( k );
    }

    inline function _pull() {
        for (key => value in src) {
            data[key] = _val( value );
        }
    }

    public static function _val(v: Dynamic):Val {
        if ((v is Val))
            return cast(v, Val);

        if (Arch.isBool( v ))
            return Val.Bool( v );

        if (Arch.isFloat( v ))
            return Val.Num(new BigNumber( v ));

        if (Arch.isString( v )) {
            try {
                var n = new BigNumber( v );
                if (n.isNotANumber())
                    throw 'NaN';
                return Val.Num( n );
            }
            catch (e: Dynamic) {
                return Val.Txt('$v');
            }
        }

        if (Arch.isNull( v ))
            return Val.Nil;

        return Val.Other( v );
    }

    public static function _dyn(v: Val):Dynamic {
        return switch ( v ) {
            case Val.Nil: null;
            case Val.Bool(b): b;
            case Val.Num(n): try v.getValue() catch (e: Dynamic) n.toString();
            case Val.Txt(s): s;
            case Val.Other(x): x;
        }
    }

    public function toDat():Dat {
        var o:Dat = src.clone(ShallowRecurse);
        for (k in data.keys()) {
            o[k] = _dyn(data[k].get());
        }
        return o;
    }

    public function toString():String {
        var res = '{\n';
        for (k=>v in data) {
            res += '  ' + Json.stringify( k ) + ': ';
            switch (v.get()) {
                case Nil:
                    res += 'nil';

                case Num((_ : BigNumber)=>big):
                    res += big.toString();

                case Txt(s):
                    res += Json.stringify( s );

                case Bool(b):
                    res += Json.stringify( b );

                case Other(x):
                    res += Type.typeof( x );
            }
            res += ',\n';
        }
        res += '}';
        return res;
    }
}

@:using(ch.Save.Vals)
enum Val {
    Nil;
    Bool(b: Bool);
    Num(d: BigNumber);
    Txt(s: String);

    Other(o: Dynamic);
}

abstract Attr (Ref<Val>) from Ref<Val> to Ref<Val> {
    public inline function new() {
        this = new Ref();
    }

    @:to
    public inline function get():Val {
        return this.get();
    }

    public inline function assign(value: Dynamic) {
        this.assign(Save._val( value ));
    }

    public inline function set(val: Val):Val {
        return this.set( val );
    }

    public inline function getv():Dynamic return get().getValue();
    public inline function setv(v: Dynamic):Dynamic {
        assign( v );
        return v;
    }

    public inline function empty():Bool {
        return this.value == null;
    }

    @:from
    public static inline function of(r: Ref<Val>):Attr {
        return r;
    }

    @:from
    public static inline function ofAny(v: Dynamic):Attr {
        var a = new Attr();
        a.assign( v );
        return a;
    }
}

abstract ModFn (Attr -> Void) from Attr->Void to Attr->Void {
    @:selfCall
    public inline function apply(a: Attr) {
        this.call( a );
    }

    @:from public static inline function ret(fn: Attr -> Attr):ModFn {
        return function(a: Attr) {
            var r = fn( a );
            if (r != a)
                a.assign(r.get());
        }
    }

    @:from public static inline function val(fn: Val -> Val):ModFn {
        return function(a: Attr) {
            a.assign(fn(a.get()));
        }
    }
}

class Vals {
    public static function getValue(v: Val):Dynamic {
        return switch ( v ) {
            case Nil: null;
            case Bool(b): b;
            case Txt(s): s;
            case Other(x): x;
            case Num((_:BigNumber)=>num):
                if (num.lteN(2147483647))
                    num.toFloat();
                else
                    num.toScientific();
        }
    }
}
