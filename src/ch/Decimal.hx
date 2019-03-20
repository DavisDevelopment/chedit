package ch;

import ch.BigNumber;

//

@:forward
abstract Decimal (BigNumber) from BigNumber to BigNumber {
    public inline function new(base=0, power=0) {
        this = new BigNumber(base, power);
    }

    //@:op(x + y)
    //public static inline function _add_(x:Decimal, y:Decimal):Decimal {
        
    //}

    @:to public inline function toFloat():Float return this.toFloat();
    @:to public inline function toString():String return this.toString();

    @:from public static function fromFloat(n: Float):Decimal return new BigNumber( n );
    @:from public static function fromScientific(n: String):Decimal return new BigNumber( n );
    @:from public static function fromAnon(o:{base:Any, power:Any}):Decimal return new BigNumber(o.base, o.power);
}
