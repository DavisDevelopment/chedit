package ch;

/* package com.playsaurus.numbers */
class BigNumber {
    public var stringRepresentation(get, never) : String;
    public var numberRepresentation(get, never) : String;
    
    public var base : Float;
    public var power : Float;
    
    /* Constructor Function */
    public function new(param1:Dynamic = 0, param2:Int = 0, param3:Int = -1) {
        //super();
        if (Std.is(param1, Float)) {
            if (param1 == 0) {
                this.base = 0;
                this.power = 0;
            }
            else {
                this.fromFloat(Std.parseFloat('' + param1));
            }
        }
        else if (Std.is(param1, String)) {
            this.fromString(Std.string( param1 ));
        }
        else if (Std.is(param1, BigNumber)) {
            this.base = (try cast(param1, BigNumber) catch(e:Dynamic) null).base;
            this.power = (try cast(param1, BigNumber) catch(e:Dynamic) null).power;
        }
        else {
            this.base = 0;
            this.power = 0;
        }
    }
    
    public static function _copy(param1 : BigNumber):BigNumber {
        var _loc2_ : BigNumber = new BigNumber(0);
        _loc2_.base = param1.base;
        _loc2_.power = param1.power;
        return _loc2_;
    }
    public inline function copy():BigNumber {
        return _copy( this );
    }
    
    public static inline function clone(param1 : BigNumber) : BigNumber {
        return BigNumber._copy(param1);
    }
    
    public static inline function _max(a:BigNumber, b:BigNumber):BigNumber {
        if (a.gte( b )) {
            return a;
        }
        return b;
    }
    
    public static inline function _min(a:BigNumber, b:BigNumber):BigNumber {
        if (a.lte( b )) {
            return a;
        }
        return b;
    }
    
    public function fromString(param1 : String) : Void {
        var _loc2_ = param1.split("e");
        //this.base = as3hx.Compat.parseFloat(_loc2_[0]);
        this.base = Std.parseFloat(_loc2_[0]);
        _loc2_.splice(0, 1);
        //this.power = as3hx.Compat.parseFloat(_loc2_.join("e"));
        this.power = Std.parseFloat(_loc2_.join( "e" ));
        normalize();
    }
    
    public function toFixed(param1 : Int = 2) : String {
        var _loc2_ : String = null;
        var _loc4_ : String = null;
        var _loc6_ : Int = 0;
        var _loc3_ : Array<Dynamic> = Std.string(this).split("e");
        var _loc5_ : Array<Dynamic> = _loc3_[0].split(".");
        if (_loc5_[1] != null) {
            if (_loc5_[1].length < param1) {
                _loc6_ = _loc5_[1].length;
                while (_loc6_ < param1) {
                    _loc5_[1] = _loc5_[1] + "0";
                    _loc6_++;
                }
            }
            else {
                _loc5_[1] = _loc5_[1].substr(0, param1);
            }
        }
        if (_loc3_[1] != null) {
            _loc3_[0] = !!(_loc5_[1] != null) ? _loc5_.join(".") : _loc5_[0];
            _loc2_ = _loc3_.join("e");
        }
        else {
            _loc2_ = !!(_loc5_[1] != null) ? _loc5_.join(".") : _loc5_[0];
        }
        return _loc2_;
    }
    
    public function toString() : String {
        var _loc3_ : Float = Math.NaN;
        var _loc1_ : Float = this.base;
        var _loc2_ : Float = this.power;
        if (_loc2_ < 5 && _loc2_ >= 0) {
            while (_loc2_ > 0) {
                _loc1_ = _loc1_ * 10;
                _loc2_--;
            }
            _loc3_ = _loc1_;
            this.normalize();
            return Std.string(_loc3_);
        }
        if (_loc2_ > -5 && _loc2_ < 0) {
            while (_loc2_ < 0) {
                _loc1_ = _loc1_ / 10;
                _loc2_++;
            }
            _loc3_ = _loc1_;
            this.normalize();
            return Std.string(_loc3_);
        }
        return Std.string(_loc1_) + "e" + Std.string(_loc2_);
    }
    
    public inline function numberValue():Float {
        return (base * Math.pow(10, power));
    }
    
    public inline function toFloat() : Float {
        return numberValue();
    }
    
    public function normalize2() {
        if (base == 0) {
            power = 0;
            return;
        }

        var floorLog:Float = Math.floor(Math.log(this.base) / 2.30258509299405);
        this.base = this.base / Math.pow(10, floorLog);
        this.power = this.power + floorLog;
    }
    
    public function normalize() {
        var _loc1_ : Float = Math.NaN;
        if (this.base == 0) {
            this.power = 0;
            return;
        }

        var _loc2_ : Float = Math.abs(this.base);
        if (_loc2_ >= 10) {
            _loc1_ = Math.floor(Math.log(_loc2_) / 2.30258509299405);
            this.base = this.base / Math.pow(10, _loc1_);
            this.power = this.power + _loc1_;
        }
        else if (_loc2_ < 1) {
            _loc1_ = 0 - Math.floor(Math.log(_loc2_) / 2.30258509299405);
            this.base = this.base * Math.pow(10, _loc1_);
            this.power = this.power - _loc1_;
        }
    }
    
    public function negate():BigNumber {
        var neg = copy();
        neg.base = -base;
        return neg;
    }
    
    public function fromFloat(n : Float) {
        base = n;
        power = 0;
        normalize();
    }
    
    public function add(param1 : BigNumber):BigNumber {
        var _loc4_ : Float = Math.NaN;
        var _loc2_ : BigNumber = _copy(this);
        var _loc3_ : Float = _loc2_.power - param1.power;
        if (_loc3_ > 10) {
            return _loc2_;
        }
        if (_loc3_ < -10) {
            _loc2_.base = param1.base;
            _loc2_.power = param1.power;
            return _loc2_;
        }
        if (_loc3_ == 0) {
            _loc2_.base = _loc2_.base + param1.base;
            _loc2_.normalize();
            return _loc2_;
        }
        if (_loc3_ > 0) {
            _loc2_.base = _loc2_.base * Math.pow(10, _loc3_);
            _loc2_.power = param1.power;
            _loc2_.base = _loc2_.base + param1.base;
            _loc2_.normalize();
            return _loc2_;
        }
        if (_loc3_ < 0) {
            _loc4_ = param1.base * Math.pow(10, -_loc3_);
            _loc2_.base = _loc2_.base + _loc4_;
            _loc2_.normalize();
            return _loc2_;
        }
        return _loc2_;
    }
    
    public function plusEquals(param1 : BigNumber) {
        var _loc3_ : Float = Math.NaN;
        var _loc2_ : Float = this.power - param1.power;
        if (_loc2_ > 10) {
            return;
        }
        if (_loc2_ < -10) {
            this.base = param1.base;
            this.power = param1.power;
            return;
        }
        if (_loc2_ == 0) {
            this.base = this.base + param1.base;
            this.normalize();
            return;
        }
        if (_loc2_ > 0) {
            this.base = this.base * Math.pow(10, _loc2_);
            this.power = param1.power;
            this.base = this.base + param1.base;
            this.normalize();
            return;
        }
        if (_loc2_ < 0) {
            _loc3_ = param1.base * Math.pow(10, -_loc2_);
            this.base = this.base + _loc3_;
            this.normalize();
            return;
        }
    }
    
    public function minusEquals(param1 : BigNumber) {
        var _loc3_ = Math.NaN;
        var _loc2_ = this.power - param1.power;
        if (_loc2_ > 10) {
            return;
        }
        if (_loc2_ < -10) {
            this.base = -param1.base;
            this.power = param1.power;
            return;
        }
        if (_loc2_ == 0) {
            this.base = this.base - param1.base;
            this.normalize();
            return;
        }
        if (_loc2_ > 0) {
            this.base = this.base * Math.pow(10, _loc2_);
            this.power = param1.power;
            this.base = this.base - param1.base;
            this.normalize();
            return;
        }
        if (_loc2_ < 0) {
            _loc3_ = param1.base * Math.pow(10, -_loc2_);
            this.base = this.base - _loc3_;
            this.normalize();
            return;
        }
    }
    
    public function addN(n : Float):BigNumber {
        return this.add(new BigNumber( n ));
    }
    
    public function subtract(n : BigNumber) : BigNumber {
        var d = _copy( n );
        d.base = -d.base;
        return add( d );
    }
    
    public function multiply(param1 : BigNumber) : BigNumber {
        var _loc2_ : BigNumber = _copy(this);
        _loc2_.base = _loc2_.base * param1.base;
        _loc2_.power = _loc2_.power + param1.power;
        _loc2_.normalize();
        return _loc2_;
    }
    
    public function timesEquals(param1 : BigNumber) {
        this.base = this.base * param1.base;
        this.power = this.power + param1.power;
        this.normalize();
    }
    
    public function multiplyN(param1 : Float):BigNumber {
        var _loc2_ : BigNumber = _copy(this);
        _loc2_.base = _loc2_.base * param1;
        _loc2_.normalize();
        return _loc2_;
    }
    
    public function timesEqualsN(param1 : Float) {
        this.base = this.base * param1;
        this.normalize();
    }
    
    public function divide(param1 : BigNumber) : BigNumber {
        var _loc2_ : BigNumber = _copy(this);
        var _loc3_ : Float = _loc2_.base / param1.base;
        if (_loc3_ < 10000) {
            _loc3_ = _loc3_ * 10000;
            _loc2_.power = _loc2_.power - 4;
        }
        _loc2_.base = _loc3_;
        _loc2_.power = _loc2_.power - param1.power;
        _loc2_.normalize();
        return _loc2_;
    }
    
    public function divideN(param1 : Float) : BigNumber {
        return this.divide(new BigNumber(param1));
    }
    
    public function divideToPercent(param1 : BigNumber) : BigNumber {
        var _loc2_ : BigNumber = this.divide(param1);
        return _loc2_;
    }
    
    public function sqrt() : BigNumber {
        var _loc1_ : BigNumber = _copy(this);
        if (_loc1_.power % 2 != 0) {
            _loc1_.power = _loc1_.power - 1;
            _loc1_.base = _loc1_.base * 10;
        }
        _loc1_.base = Math.sqrt(_loc1_.base);
        _loc1_.power = _loc1_.power / 2;
        _loc1_.normalize();
        return _loc1_;
    }
    
    public function pow(param1 : Int) : BigNumber {
        var _loc2_ : BigNumber = _copy(this);
        var _loc3_ : BigNumber = new BigNumber(1);
        if (param1 == 0) {
            return _loc3_;
        }
        if (param1 < 0) {
            _loc2_ = _loc3_.divide(_loc2_);
            param1 = -param1;
        }
        while (param1 > 1) {
            if (param1 % 2 == 0) {
                _loc2_.base = _loc2_.base * _loc2_.base;
                _loc2_.power = _loc2_.power + _loc2_.power;
                _loc2_.normalize();
                //param1 = as3hx.Compat.parseInt(param1 / 2);
                param1 = Std.parseInt(Std.string(param1 / 2));
            }
            else {
                _loc3_.base = _loc2_.base * _loc3_.base;
                _loc3_.power = _loc2_.power + _loc3_.power;
                _loc3_.normalize();
                _loc2_.base = _loc2_.base * _loc2_.base;
                _loc2_.power = _loc2_.power + _loc2_.power;
                _loc2_.normalize();
                //param1 = as3hx.Compat.parseInt((param1 - 1) / 2);
                param1 = Std.parseInt(Std.string((param1 - 1) / 2));
            }
        }
        _loc2_.base = _loc2_.base * _loc3_.base;
        _loc2_.power = _loc2_.power + _loc3_.power;
        _loc2_.normalize();
        return _loc2_;
    }
    
    public function percentIncreaseToMultiplier() : BigNumber {
        return this.multiplyN(0.01).addN(1);
    }
    
    public function max(param1 : BigNumber) : BigNumber
    {
        var _loc2_ : BigNumber = null;
        if (this.gte(param1))
        {
            _loc2_ = _copy(this);
        }
        else
        {
            _loc2_ = _copy(param1);
        }
        return _loc2_;
    }
    
    public function min(param1 : BigNumber) : BigNumber
    {
        var _loc2_ : BigNumber = null;
        if (this.lte(param1))
        {
            _loc2_ = _copy(this);
        }
        else
        {
            _loc2_ = _copy(param1);
        }
        return _loc2_;
    }
    
    public function lte(param1 : BigNumber) : Bool
    {
        var _loc2_ : Float = Math.NaN;
        if (this.base == 0)
        {
            return param1.base >= 0;
        }
        if (param1.base == 0)
        {
            return this.base <= 0;
        }
        if ((this.base < 0) != (param1.base < 0)) {
            return this.base < param1.base;
          
        }
        _loc2_ = (this.base > 0) ? 1 : -1;
        if (_loc2_ * this.power > _loc2_ * param1.power)
        {
            return false;
        }
        if (this.power == param1.power)
        {
            return this.base <= param1.base;
        }
        return true;
    }
    
    public function gte(param1 : BigNumber) : Bool
    {
        var _loc2_ : Float = Math.NaN;
        if (this.base == 0)
        {
            return param1.base <= 0;
        }
        if (param1.base == 0)
        {
            return this.base >= 0;
        }
        //if (this.base < 0 != param1.base < 0)
          if ((this.base < 0) != (param1.base < 0))
        {
            return this.base > param1.base;
        }
        _loc2_ = (this.base > 0) ? 1 : -1;
        if (_loc2_ * this.power < _loc2_ * param1.power)
        {
            return false;
        }
        if (this.power == param1.power)
        {
            return this.base >= param1.base;
        }
        return true;
    }
    
    public function gt(param1 : BigNumber) : Bool
    {
        var _loc2_ : Float = Math.NaN;
        if (this.base == 0)
        {
            return param1.base < 0;
        }
        if (param1.base == 0)
        {
            return this.base > 0;
        }
        if ((this.base < 0) != (param1.base < 0))
        {
            return this.base > param1.base;
        }
        _loc2_ = (this.base > 0) ? 1 : -1;
        if (_loc2_ * this.power < _loc2_ * param1.power)
        {
            return false;
        }
        if (this.power == param1.power)
        {
            return this.base > param1.base;
        }
        return true;
    }
    
    public function lt(param1 : BigNumber) : Bool
    {
        var _loc2_ : Float = Math.NaN;
        if (this.base == 0)
        {
            return param1.base > 0;
        }
        if (param1.base == 0)
        {
            return this.base < 0;
        }
        //if (this.base < 0 != param1.base < 0)
      if ((this.base < 0) != (param1.base < 0))
        {
            return this.base < param1.base;
        }
        _loc2_ = (this.base > 0) ? 1 : -1;
        if (_loc2_ * this.power > _loc2_ * param1.power)
        {
            return false;
        }
        if (this.power == param1.power)
        {
            return this.base < param1.base;
        }
        return true;
    }
    
    public function eq(param1 : BigNumber) : Bool
    {
        if (this.power != param1.power)
        {
            return false;
        }
        if (this.base == param1.base)
        {
            return true;
        }
        return false;
    }
    
    public function gtN(param1 : Float) : Bool
    {
        if (param1 == 0)
        {
            return this.base > 0;
        }
        if (this.base == 0)
        {
            return param1 < 0;
        }
        if ((this.base < 0) != (param1 < 0))
        {
            return this.base > param1;
        }
        return this.gt(new BigNumber(param1));
    }
    
    public function ltN(param1 : Float) : Bool {
        return this.lt(new BigNumber(param1));
    }
    
    public function gteN(param1 : Float) : Bool {
        if (this.base == 0) {
            return param1 <= 0;
        }
        if (param1 == 0) {
            return this.base >= 0;
        }
        if ((this.base < 0) != (param1 < 0)) {
            return this.base > param1;
        }
        return this.gte(new BigNumber(param1));
    }
    
    public function lteN(param1 : Float) : Bool {
        return this.lte(new BigNumber(param1));
    }
    
    public function eqN(param1 : Float) : Bool {
        return this.eq(new BigNumber(param1));
    }
    
    public function floor() : BigNumber {
        var _loc2_ : Float = Math.NaN;
        var _loc1_ : BigNumber = _copy(this);
        if (_loc1_.power < 15) {
            _loc2_ = _loc1_.power;
            _loc1_.base = _loc1_.base * Math.pow(10, _loc2_);
            _loc1_.power = _loc1_.power - _loc2_;
            _loc1_.base = Math.floor(_loc1_.base);
            _loc1_.normalize();
        }
        return _loc1_;
    }
    
    public function ceil():BigNumber {
        var _loc2_ : Float = Math.NaN;
        var _loc1_ : BigNumber = copy();
        if (_loc1_.power < 15) {
            _loc2_ = _loc1_.power;
            _loc1_.base = _loc1_.base * Math.pow(10, _loc2_);
            _loc1_.power = _loc1_.power - _loc2_;
            _loc1_.base = Math.ceil(_loc1_.base);
            _loc1_.normalize();
        }
        return _loc1_;
    }
    
    public function round():BigNumber {
        var _loc1_:BigNumber = _copy( this );
        var _loc2_:BigNumber = _loc1_.floor();
        if (_loc1_.subtract(_loc2_).gtN( 0.5 )) {
            return _loc1_.ceil();
        }
        return _loc2_;
    }
    
    private inline function get_stringRepresentation():String {
        return Std.string( this );
    }
    
    public inline function toScientific():String {
        return Std.string(this);
    }
    
    private inline function get_numberRepresentation():String {
        return Std.string(numberValue());
    }
    
    public function isNotANumber():Bool {
        return Math.isNaN( base ) || Math.isNaN( power ) || Std.string( this ) == "NaN" || Std.string( this ) == "NaNeInfinity";
    }
}

