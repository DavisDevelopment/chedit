package ;

import format.tools.Inflate;
import format.tools.Deflate;
import haxe.extern.EitherType as Or;

import haxe.io.*;
import haxe.crypto.*;
import haxe.DynamicAccess;
import haxe.Json;
import sys.io.File;

import ch.BigNumber;
import ch.Decimal;
import ch.SaveFile;
import ch.Save;
import ch.Save.Val;
import ch.Dat;

import pm.Object;
import pm.Arch;
import pm.Pair;

using pm.Strings;
using pm.Iterators;
using pm.Arrays;
using pm.Helpers;
using pm.Functions;
using ch.Save;

// Betty
class CHEdit {
    function new() {
        options = new Map();
        getOptions();
        parseOptions();
        run();
    }

    function getOptions() {
        var argv = Sys.args();
        if (argv.empty()) {
            printHelp();
            Sys.exit( 0 );
        }
        else if (argv[0].matchFor('help'|'--help' ? true : false)) {
            printHelp();
            Sys.exit( 0 );
        }

        var itr = argv.iterator();
        while (itr.hasNext()) {
            var s = itr.next();
            if (s.startsWith('--')) {
                options[s.substring(2)] = itr.next();
            }
        }
    }

    function parseOptions() {
        if (options.exists('input')) {
            input = new BytesInput(File.getBytes(options['input']));
        }

        if (options.exists('output')) {
            output = File.write(options['output'], true);
        }

        var ops = ['add', 'subtract', 'multiply', 'divide'];
        var opers = new Map();
        inline function oper(name:String, fn:Save->String->Dynamic->Void) opers[name] = fn;
        inline function nmod(save:Save, key:String, fn:BigNumber->Void) {
            save.mod(key, (val:Attr) -> val.set(val.get().matchFor(Num(n) ? {fn(n);val.get();} : val.get())));
        }

        inline function numop(name:String, fn:BigNumber->Dynamic->Void) {
            oper(name, function(save:Save, key:String, value:Dynamic) {
                nmod(save, key, fn.bind(_, value));
            });
        }

        numop('add', (a, b) -> a.plusEquals(new BigNumber( b )));
        numop('subtract', (a:BigNumber, b:Dynamic) -> a.minusEquals(new BigNumber( b )));
        numop('multiply', (a:BigNumber, b:Dynamic) -> a.timesEquals(new BigNumber( b )));
        numop('divide', (a:BigNumber, b:Dynamic) -> a.fromString(a.divide(new BigNumber(b)).toString()));

        oper('set', function(save:Save, name:String, value:Dynamic) {
            save.set(name, Save._val( value ));
        });

        for (op in opers.keys()) {
            if (options.exists( op )) {
                var pair = Std.string(options.get( op )).split(':').map(x -> x.trim()).map(x -> x.split(','));
                switch ( pair ) {
                    case [keys, values]:
                        Arrays
                        .zip(keys, values, function(key, value) {
                            return new Pair(key, parseNum(value));
                        })
                        .map(pair -> switch pair {
                            case {left:key, right:value}:
                                opers[op].bind(_, key, value);

                            default:
                                throw 'Wtf';
                        })
                        .forEach(fn -> operations.push( fn ));

                    default:
                        throw 'Wtf';
                }
            }
        }
    }

    inline function parseNum(s: String):Dynamic {
        var bn:BigNumber = new BigNumber(~/[\d]+[.]?[\d]*e[\d]+/gi.match( s ) ? s : '${s}e0');
        if (!bn.isNotANumber())
            return bn;
        throw 'Invalid';
    }

    function run() {
        io();

        var sdata = input.readLine();
        input.close();

        var d:Dat;
        d = SaveFile.decode( sdata );
        var save = new ch.Save( d );

        var fn = inline operations.iterator().reduce(function(res:ch.Save->Void, f:ch.Save->Void):ch.Save->Void {
            return inline res.join( f );
        }, function(d) {
            //
        });
        
        fn( save );
        //save.set('heroCollection.heroes.16.level', Save._val( 16500 ));
        //trace(save.get('heroCollection.heroes.16.level'));

        var betty = SaveFile.encode(save.toDat());
        output.writeString( betty );
        output.close();
        Sys.exit( 0 );
    }

    function io() {
        if (input == null)
            input = Sys.stdin();
        if (output == null)
            output = Sys.stdout();
    }

    function printHelp() {
        var lines = [
            'example usage:',
            '  chedit --input {current save} --output {edited save} {options}',
            ' ',
            'available operators:',
            ' --add',
            ' --subtract',
            ' --multiply',
            ' --divide',
            ' ',
            'operator usage:',
            ' ',
            ' --{op} {attrs}:{values}',
            'example: ',
            ' --add gold,rubies:2.2e225,1000'
        ];
        Sys.println('');
        for (line in lines) {
            Sys.println( line );
        }
    }

    var options: Map<String, String>;
    var input: Input = null;
    var output: Output = null;

    var operations: List<ch.Save -> Void> = new List();

    static function main() new CHEdit();
}


