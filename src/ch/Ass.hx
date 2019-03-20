package ch;

class Ass {
  public static inline function getHash(string: String) {
    var salt = 'af0ik392jrmt0nsfdghy0';
    var charaters = string.split('');
    charaters.sort(Reflect.compare);
    var sortedCharaters = charaters.join('');
    return haxe.crypto.Md5.encode(sortedCharaters + salt);
  }
}


