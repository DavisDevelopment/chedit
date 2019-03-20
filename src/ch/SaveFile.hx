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

import pm.Object;
import pm.Arch;

using pm.Functions;

class SaveFile {
  public static function encodeNew(data: Dat, ?replacer:Dynamic->Dynamic->Dynamic) {
    if (replacer == null)
       replacer = identity;
    data = wipe( data );
    data.remove('type');
    data['account'] = cast {
        flag: true,
        name: "Clicker Heroes save editor™",
        author: {
            discord: "Legofury#9425",
            reddit: "/u/Legocro",
            github: "/Legocro"
        },
        note: "This is added by integration and cannot be removed",
        license: "There's no license what did you think"
    };
    var hash:String = "7a990d405d2c6fb93aa8fbb0ec1a3b23";
    var json:String = Json.stringify(cast data, replacer);
    var data = Base64.encode(Deflate.run(Bytes.ofString(json)));
    return hash + data;
  }

  public static function encodeOld(data:Dat, ?replacer:Dynamic->Dynamic->Dynamic) {
      if (replacer == null)
          replacer = identity;
      data = wipe( data );
      data.remove('type');
      data['account'] = cast {
          flag: true,
          name: "Clicker Heroes save editor™",
          author: {
              discord: "Legofury#9425",
              reddit: "/u/Legocro",
              github: "/Legocro"
          },
          note: "This is added by integration and cannot be removed",
          license: "There's no license what did you think"
      };
      
      var json:String = Json.stringify(cast data, replacer);
      var letters = "0123456789abcdefghijklmnopqrstuvwxyz";
      var newdata = Base64.encode(Bytes.ofString( json ));
      var newsprinkle = "";
      for (i in 0...newdata.length) {
          newsprinkle += newdata.charAt(i) + letters.charAt(Math.floor(Math.random() * letters.length));
      }
      var encoded = newsprinkle + "Fe12NAfA3R6z4k0z" + Ass.getHash(newdata);
      return encoded;
  }

  public static function decode(d: String):Dat {
      if (d.indexOf("Fe12NAfA3R6z4k0z") == -1)
          return decodeNew( d );
      else 
          return decodeOld( d );
  }

  public static function encode(d: Or<String, Dat>, ?replace:Dynamic->Dynamic->Dynamic):String {
      if ((d is String))
          d = Json.parse('$d');
      if ((d : Dat)['type'] == 'old')
          return encodeOld(d, replace);
      return encodeNew(d, replace);
  }

  static function identity(k:Dynamic, v:Dynamic):Dynamic {
      return v;
  }

  static function wipe(d: Dat) {
      d['loginValidated'] = false;
      d['email'] = '';
      d['passwordHash'] = '';
      d['prevLoginTimestamp'] = 0;
      d['account'] = null;
      d['accountId'] = 0;
      d['uniqueId'] = '';
      return d;
  }

  public static var isNew = false;
  public static function decodeNew(data: String):Dat {
    isNew = true;
  	var result = data.substring(32);
    data = Inflate.run(haxe.crypto.Base64.decode(result)).toString();
    //data.toString();
    //trace( data );
    //
    var o:Dat = Json.parse( data );
    o.type = cast 'new';
    return o;
  }
  
  public static function decodeOld(data: String):Dat {
    isNew = false;
    var result = data.split("Fe12NAfA3R6z4k0z");
    var txt = "";
    
    //for (var i = 0; i < result[0].length; i += 2)
        //txt += result[0][i];
    var i = 0;
    while (i < result[0].length) {
      txt += result[0].charAt(i);
      
      i += 2;
    }
    
    var data:DynamicAccess<Dynamic> = haxe.Json.parse(Base64.encode(Bytes.ofString(data)));
    data['type'] = "old";
    //console.log(data);
    return data;
  }
}


