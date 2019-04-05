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
using pm.Iterators;
using pm.Strings;

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
        if (key.has('.')) {
            return dotGet( key );
        }
        else {
            return _get( key );
        }
    }

    function _get(key: String):Null<Val> {
        return switch (prop( key )) {
            case None|Some(null): null;
            case Some(a): a.get();
        }
    }

    public function set(key:String, val:Val) {
        if (key.has('.'))
            dotSet(key, val);
        else
            _set(key, val);
    }

    function _set(key:String, val:Val) {
        switch (prop( key )) {
            case Some(r):
                r.assign( val );

            case None:
                data[key] = Ref.to( val );
        }
    }

    public function dotGet(key: String) {
        var path = key.split('.');
        return _dotGet(path, _get(path.shift()));
    }

    public function dotSet(key:String, value:Val) {
        var path = key.split('.');
        _dotSet(path, _get(path.shift()), value);
    }

    static function _dotSet(path:Array<String>, container:Null<Val>, value:Val) {
        if (path.length == 1) {
            switch ( container ) {
                case null:
                    throw 'Error';

                case Val.List(array) if (path[0].isNumeric()):
                    array[Std.parseInt(path[0])] = value;

                case Val.Dict(map):
                    map[path[0]] = value;

                default:
                    throw 'Error';
            }
        }
        else {
            var name = path.shift();
            switch (container) {
                case Val.List(array) if (name.isNumeric()):
                    _dotSet(path, array[Std.parseInt(name)], value);

                case Val.Dict(map):
                    _dotSet(path, map[name], value);

                default:
                    throw 'Wut';
            }
        }
    }

    static function _dotGet(path:Array<String>, current:Null<Val>) {
        var name = path.shift();
        if (name.empty())
            return current;
        switch current {
            case Val.List(array) if (name.isNumeric()):
                return _dotGet(path, array[Std.parseInt(name)]);

            case Val.Dict(map):
                return _dotGet(path, map[name]);

            default:
                throw 'Wut';
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
                var s:String = cast(v, String);
                var n:BigNumber = new BigNumber(~/[\d]+[.]?[\d]*e[\d]+/gi.match( s ) ? s : '${s}e0');
                if (n.isNotANumber())
                    throw 'NaN';
                return Val.Num( n );
            }
            catch (e: Dynamic) {
                return Val.Txt('$v');
            }
        }

        if (Arch.isArray( v )) {
            return Val.List(cast(v, Array<Dynamic>).map(x -> _val( x )));
        }

        if (Arch.isObject( v )) {
            return Val.Dict(ValDict.fromAnon( v ));
        }

        if (Arch.isNull( v ))
            return Val.Nil;

        return Val.Other( v );
    }

    public static function _dyn(v: Val):Dynamic {
        return v.getValue();
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

                case List(a):
                    res += '[' + a.map(x -> '$x').join(', ') + ']';

                case Dict(d):
                    res += '$d';

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
    List(l: Array<Val>);
    Dict(d: ValDict);
    Other(o: Dynamic);
}

@:forward
abstract ValDict (Map<String, Val>) from Map<String, Val> to Map<String, Val> {
    public inline function new() {
        this = new Map();
    }

    @:arrayAccess
    public inline function get(key: String):Val {
        return switch this.get( key ) {
            case null: Val.Nil;
            case val: val;
        }
    }

    @:arrayAccess
    public inline function set(key:String, val:Val) {
        return this.set(key, val);
    }

    @:from
    public static inline function fromMap(m: Map<String, Dynamic>):ValDict {
        return [for (key=>value in m) key=>Save._val(value)];
    }

    @:from
    public static inline function fromAnon(d: Dynamic):ValDict {
        var res = new ValDict();
        for (key in Reflect.fields( d )) {
            res[key] = Save._val(Reflect.field(d, key));
        }
        return res;
    }
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
            case List(a): a.map(getValue);
            case Dict(d): d.keyValueIterator().reduce(function(o:Dynamic, pair:{key:String, value:Val}) {
                Reflect.setField(o, pair.key, getValue(pair.value));
                return o;
            }, {});
            case Other(x): x;
            case Num((_:BigNumber)=>num):
                if (num.lteN(2147483647))
                    num.toFloat();
                else
                    num.toScientific();
        }
    }
}
