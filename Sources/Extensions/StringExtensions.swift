//
//  StringExtensions.swift
//  Ello
//
//  Created by Sean Dougherty on 12/15/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

// static variables, to store HTML entities
private var entityReverseLookup : [Character : String]!
private var entityLookup : [String : String]!
private var entitiesEncodedPredicate : dispatch_once_t = 0
private var entitiesDecodedPredicate : dispatch_once_t = 0

extension String {

    func urlEncoded() -> String {
        return CFURLCreateStringByAddingPercentEscapes(
                nil,
                self,
                nil,
                "!*'();:@&=+$,/?%#[]",
                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)
                )
    }

    func urlDecoded() -> String {
        return CFURLCreateStringByReplacingPercentEscapesUsingEncoding(nil,
            self as NSString,
            "",
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
    }

    func entitiesEncoded() -> String {
        dispatch_once(&entitiesEncodedPredicate) {
            entityReverseLookup = [Character : String]()
            let scalarLookup : [(UInt16, String)] = [
                (0x0022, "&quot;"),
                (0x0026, "&amp;"),
                (0x0027, "&apos;"),
                (0x003c, "&lt;"),
                (0x003e, "&gt;"),
                (0x00a0, "&nbsp;"),
                (0x00a1, "&iexcl;"),
                (0x00a2, "&cent;"),
                (0x00a3, "&pound;"),
                (0x00a4, "&curren;"),
                (0x00a5, "&yen;"),
                (0x00a6, "&brvbar;"),
                (0x00a7, "&sect;"),
                (0x00a8, "&uml;"),
                (0x00a9, "&copy;"),
                (0x00aa, "&ordf;"),
                (0x00ab, "&laquo;"),
                (0x00ac, "&not;"),
                (0x00ae, "&reg;"),
                (0x00af, "&macr;"),
                (0x00b0, "&deg;"),
                (0x00b1, "&plusmn;"),
                (0x00b2, "&sup2;"),
                (0x00b3, "&sup3;"),
                (0x00b4, "&acute;"),
                (0x00b5, "&micro;"),
                (0x00b6, "&para;"),
                (0x00b7, "&middot;"),
                (0x00b8, "&cedil;"),
                (0x00b9, "&sup1;"),
                (0x00ba, "&ordm;"),
                (0x00bb, "&raquo;"),
                (0x00bc, "&frac14;"),
                (0x00bd, "&frac12;"),
                (0x00be, "&frac34;"),
                (0x00bf, "&iquest;"),
                (0x00c0, "&Agrave;"),
                (0x00c1, "&Aacute;"),
                (0x00c2, "&Acirc;"),
                (0x00c3, "&Atilde;"),
                (0x00c4, "&Auml;"),
                (0x00c5, "&Aring;"),
                (0x00c6, "&AElig;"),
                (0x00c7, "&Ccedil;"),
                (0x00c8, "&Egrave;"),
                (0x00c9, "&Eacute;"),
                (0x00ca, "&Ecirc;"),
                (0x00cb, "&Euml;"),
                (0x00cc, "&Igrave;"),
                (0x00cd, "&Iacute;"),
                (0x00ce, "&Icirc;"),
                (0x00cf, "&Iuml;"),
                (0x00d0, "&ETH;"),
                (0x00d1, "&Ntilde;"),
                (0x00d2, "&Ograve;"),
                (0x00d3, "&Oacute;"),
                (0x00d4, "&Ocirc;"),
                (0x00d5, "&Otilde;"),
                (0x00d6, "&Ouml;"),
                (0x00d7, "&times;"),
                (0x00d8, "&Oslash;"),
                (0x00d9, "&Ugrave;"),
                (0x00da, "&Uacute;"),
                (0x00db, "&Ucirc;"),
                (0x00dc, "&Uuml;"),
                (0x00dd, "&Yacute;"),
                (0x00de, "&THORN;"),
                (0x00df, "&szlig;"),
                (0x00e0, "&agrave;"),
                (0x00e1, "&aacute;"),
                (0x00e2, "&acirc;"),
                (0x00e3, "&atilde;"),
                (0x00e4, "&auml;"),
                (0x00e5, "&aring;"),
                (0x00e6, "&aelig;"),
                (0x00e7, "&ccedil;"),
                (0x00e8, "&egrave;"),
                (0x00e9, "&eacute;"),
                (0x00ea, "&ecirc;"),
                (0x00eb, "&euml;"),
                (0x00ec, "&igrave;"),
                (0x00ed, "&iacute;"),
                (0x00ee, "&icirc;"),
                (0x00ef, "&iuml;"),
                (0x00f0, "&eth;"),
                (0x00f1, "&ntilde;"),
                (0x00f2, "&ograve;"),
                (0x00f3, "&oacute;"),
                (0x00f4, "&ocirc;"),
                (0x00f5, "&otilde;"),
                (0x00f6, "&ouml;"),
                (0x00f7, "&divide;"),
                (0x00f8, "&oslash;"),
                (0x00f9, "&ugrave;"),
                (0x00fa, "&uacute;"),
                (0x00fb, "&ucirc;"),
                (0x00fc, "&uuml;"),
                (0x00fd, "&yacute;"),
                (0x00fe, "&thorn;"),
                (0x00ff, "&yuml;"),
                (0x0152, "&OElig;"),
                (0x0153, "&oelig;"),
                (0x0160, "&Scaron;"),
                (0x0161, "&scaron;"),
                (0x0178, "&Yuml;"),
                (0x0192, "&fnof;"),
                (0x02c6, "&circ;"),
                (0x02dc, "&tilde;"),
                (0x0393, "&Gamma;"),
                (0x0394, "&Delta;"),
                (0x0398, "&Theta;"),
                (0x039b, "&Lambda;"),
                (0x039e, "&Xi;"),
                (0x03a3, "&Sigma;"),
                (0x03a5, "&Upsilon;"),
                (0x03a6, "&Phi;"),
                (0x03a8, "&Psi;"),
                (0x03a9, "&Omega;"),
                (0x03b1, "&alpha;"),
                (0x0391, "&Alpha;"),
                (0x03b2, "&beta;"),
                (0x0392, "&Beta;"),
                (0x03b3, "&gamma;"),
                (0x03b4, "&delta;"),
                (0x03b5, "&epsilon;"),
                (0x0395, "&Epsilon;"),
                (0x03b6, "&zeta;"),
                (0x0396, "&Zeta;"),
                (0x03b7, "&eta;"),
                (0x0397, "&Eta;"),
                (0x03b8, "&theta;"),
                (0x03b9, "&iota;"),
                (0x0399, "&Iota;"),
                (0x03ba, "&kappa;"),
                (0x039a, "&Kappa;"),
                (0x03bb, "&lambda;"),
                (0x03bc, "&mu;"),
                (0x039c, "&Mu;"),
                (0x03bd, "&nu;"),
                (0x039d, "&Nu;"),
                (0x03be, "&xi;"),
                (0x03bf, "&omicron;"),
                (0x039f, "&Omicron;"),
                (0x03c0, "&pi;"),
                (0x03a0, "&Pi;"),
                (0x03c1, "&rho;"),
                (0x03a1, "&Rho;"),
                (0x03c2, "&sigmaf;"),
                (0x03c3, "&sigma;"),
                (0x03c4, "&tau;"),
                (0x03a4, "&Tau;"),
                (0x03c5, "&upsilon;"),
                (0x03c6, "&phi;"),
                (0x03c7, "&chi;"),
                (0x03a7, "&Chi;"),
                (0x03c8, "&psi;"),
                (0x03c9, "&omega;"),
                (0x03d1, "&thetasym;"),
                (0x03d2, "&upsih;"),
                (0x03d6, "&piv;"),
                (0x2002, "&ensp;"),
                (0x2003, "&emsp;"),
                (0x2009, "&thinsp;"),
                (0x2013, "&ndash;"),
                (0x2014, "&mdash;"),
                (0x2018, "&lsquo;"),
                (0x2019, "&rsquo;"),
                (0x201a, "&sbquo;"),
                (0x201c, "&ldquo;"),
                (0x201d, "&rdquo;"),
                (0x201e, "&bdquo;"),
                (0x2020, "&dagger;"),
                (0x2021, "&Dagger;"),
                (0x2022, "&bull;"),
                (0x2026, "&hellip;"),
                (0x2030, "&permil;"),
                (0x2032, "&prime;"),
                (0x2033, "&Prime;"),
                (0x2039, "&lsaquo;"),
                (0x203a, "&rsaquo;"),
                (0x203e, "&oline;"),
                (0x2044, "&frasl;"),
                (0x20ac, "&euro;"),
                (0x2111, "&image;"),
                (0x2118, "&weierp;"),
                (0x211c, "&real;"),
                (0x2122, "&trade;"),
                (0x2135, "&alefsym;"),
                (0x2190, "&larr;"),
                (0x2191, "&uarr;"),
                (0x2192, "&rarr;"),
                (0x2193, "&darr;"),
                (0x2194, "&harr;"),
                (0x21b5, "&crarr;"),
                (0x21d0, "&lArr;"),
                (0x21d1, "&uArr;"),
                (0x21d2, "&rArr;"),
                (0x21d3, "&dArr;"),
                (0x21d4, "&hArr;"),
                (0x2200, "&forall;"),
                (0x2202, "&part;"),
                (0x2203, "&exist;"),
                (0x2205, "&empty;"),
                (0x2207, "&nabla;"),
                (0x2208, "&isin;"),
                (0x2209, "&notin;"),
                (0x220b, "&ni;"),
                (0x220f, "&prod;"),
                (0x2211, "&sum;"),
                (0x2212, "&minus;"),
                (0x2217, "&lowast;"),
                (0x221a, "&radic;"),
                (0x221d, "&prop;"),
                (0x221e, "&infin;"),
                (0x2220, "&ang;"),
                (0x2227, "&and;"),
                (0x2228, "&or;"),
                (0x2229, "&cap;"),
                (0x222a, "&cup;"),
                (0x222b, "&int;"),
                (0x2234, "&there4;"),
                (0x223c, "&sim;"),
                (0x2245, "&cong;"),
                (0x2248, "&asymp;"),
                (0x2260, "&ne;"),
                (0x2261, "&equiv;"),
                (0x2264, "&le;"),
                (0x2265, "&ge;"),
                (0x2282, "&sub;"),
                (0x2283, "&sup;"),
                (0x2284, "&nsub;"),
                (0x2286, "&sube;"),
                (0x2287, "&supe;"),
                (0x2295, "&oplus;"),
                (0x2297, "&otimes;"),
                (0x22a5, "&perp;"),
                (0x22c5, "&sdot;"),
                (0x2308, "&lceil;"),
                (0x2309, "&rceil;"),
                (0x230a, "&lfloor;"),
                (0x230b, "&rfloor;"),
                (0x27e8, "&lang;"),
                (0x27e9, "&rang;"),
                (0x25ca, "&loz;"),
                (0x2660, "&spades;"),
                (0x2663, "&clubs;"),
                (0x2665, "&hearts;"),
                (0x2666, "&diams;"),
                (0x2028, "<br />"),
            ]
            for (ord, str) in scalarLookup {
                let chr = Character(UnicodeScalar(ord))
                entityReverseLookup[chr] = str
            }
        }

        var entitiesEncoded = ""

        for i in 0 ..< countElements(self) {
            let index = advance(self.startIndex, i)
            let oneChar = self[index]

            if let entity = entityReverseLookup[oneChar] {
                entitiesEncoded += entity
            }
            else
            {
                entitiesEncoded += String(oneChar)
            }
        }

        return entitiesEncoded
    }

    var SHA1String: String? {
        let salt = ElloKeys().salt()
        if let data = (salt + self).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            
            var digest = [UInt8](count: Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
            CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
            let output = NSMutableString(capacity: Int(CC_SHA512_DIGEST_LENGTH));
            for byte in digest {
                output.appendFormat("%02x", byte);
            }
            
            return output
        }
        return .None
    }

    func entitiesDecoded() -> String {
        dispatch_once(&entitiesDecodedPredicate) {
            entityLookup = [
                "quot"     : "\"",
                "amp"      : "&",
                "apos"     : "'",
                "lt"       : "<",
                "gt"       : ">",
                "nbsp"     : "\u{00a0}",
                "iexcl"    : "\u{00a1}",
                "cent"     : "\u{00a2}",
                "pound"    : "\u{00a3}",
                "curren"   : "\u{00a4}",
                "yen"      : "\u{00a5}",
                "brvbar"   : "\u{00a6}",
                "sect"     : "\u{00a7}",
                "uml"      : "\u{00a8}",
                "copy"     : "\u{00a9}",
                "ordf"     : "\u{00aa}",
                "laquo"    : "\u{00ab}",
                "not"      : "\u{00ac}",
                "reg"      : "\u{00ae}",
                "macr"     : "\u{00af}",
                "deg"      : "\u{00b0}",
                "plusmn"   : "\u{00b1}",
                "sup2"     : "\u{00b2}",
                "sup3"     : "\u{00b3}",
                "acute"    : "\u{00b4}",
                "micro"    : "\u{00b5}",
                "para"     : "\u{00b6}",
                "middot"   : "\u{00b7}",
                "cedil"    : "\u{00b8}",
                "sup1"     : "\u{00b9}",
                "ordm"     : "\u{00ba}",
                "raquo"    : "\u{00bb}",
                "frac14"   : "\u{00bc}",
                "frac12"   : "\u{00bd}",
                "frac34"   : "\u{00be}",
                "iquest"   : "\u{00bf}",
                "Agrave"   : "\u{00c0}",
                "Aacute"   : "\u{00c1}",
                "Acirc"    : "\u{00c2}",
                "Atilde"   : "\u{00c3}",
                "Auml"     : "\u{00c4}",
                "Aring"    : "\u{00c5}",
                "AElig"    : "\u{00c6}",
                "Ccedil"   : "\u{00c7}",
                "Egrave"   : "\u{00c8}",
                "Eacute"   : "\u{00c9}",
                "Ecirc"    : "\u{00ca}",
                "Euml"     : "\u{00cb}",
                "Igrave"   : "\u{00cc}",
                "Iacute"   : "\u{00cd}",
                "Icirc"    : "\u{00ce}",
                "Iuml"     : "\u{00cf}",
                "ETH"      : "\u{00d0}",
                "Ntilde"   : "\u{00d1}",
                "Ograve"   : "\u{00d2}",
                "Oacute"   : "\u{00d3}",
                "Ocirc"    : "\u{00d4}",
                "Otilde"   : "\u{00d5}",
                "Ouml"     : "\u{00d6}",
                "times"    : "\u{00d7}",
                "Oslash"   : "\u{00d8}",
                "Ugrave"   : "\u{00d9}",
                "Uacute"   : "\u{00da}",
                "Ucirc"    : "\u{00db}",
                "Uuml"     : "\u{00dc}",
                "Yacute"   : "\u{00dd}",
                "THORN"    : "\u{00de}",
                "szlig"    : "\u{00df}",
                "agrave"   : "\u{00e0}",
                "aacute"   : "\u{00e1}",
                "acirc"    : "\u{00e2}",
                "atilde"   : "\u{00e3}",
                "auml"     : "\u{00e4}",
                "aring"    : "\u{00e5}",
                "aelig"    : "\u{00e6}",
                "ccedil"   : "\u{00e7}",
                "egrave"   : "\u{00e8}",
                "eacute"   : "\u{00e9}",
                "ecirc"    : "\u{00ea}",
                "euml"     : "\u{00eb}",
                "igrave"   : "\u{00ec}",
                "iacute"   : "\u{00ed}",
                "icirc"    : "\u{00ee}",
                "iuml"     : "\u{00ef}",
                "eth"      : "\u{00f0}",
                "ntilde"   : "\u{00f1}",
                "ograve"   : "\u{00f2}",
                "oacute"   : "\u{00f3}",
                "ocirc"    : "\u{00f4}",
                "otilde"   : "\u{00f5}",
                "ouml"     : "\u{00f6}",
                "divide"   : "\u{00f7}",
                "oslash"   : "\u{00f8}",
                "ugrave"   : "\u{00f9}",
                "uacute"   : "\u{00fa}",
                "ucirc"    : "\u{00fb}",
                "uuml"     : "\u{00fc}",
                "yacute"   : "\u{00fd}",
                "thorn"    : "\u{00fe}",
                "yuml"     : "\u{00ff}",
                "OElig"    : "\u{0152}",
                "oelig"    : "\u{0153}",
                "Scaron"   : "\u{0160}",
                "scaron"   : "\u{0161}",
                "Yuml"     : "\u{0178}",
                "fnof"     : "\u{0192}",
                "circ"     : "\u{02c6}",
                "tilde"    : "\u{02dc}",
                "Gamma"    : "\u{0393}",
                "Delta"    : "\u{0394}",
                "Theta"    : "\u{0398}",
                "Lambda"   : "\u{039b}",
                "Xi"       : "\u{039e}",
                "Sigma"    : "\u{03a3}",
                "Upsilon"  : "\u{03a5}",
                "Phi"      : "\u{03a6}",
                "Psi"      : "\u{03a8}",
                "Omega"    : "\u{03a9}",
                "alpha"    : "\u{03b1}",
                "Alpha"    : "\u{0391}",
                "beta"     : "\u{03b2}",
                "Beta"     : "\u{0392}",
                "gamma"    : "\u{03b3}",
                "delta"    : "\u{03b4}",
                "epsilon"  : "\u{03b5}",
                "Epsilon"  : "\u{0395}",
                "zeta"     : "\u{03b6}",
                "Zeta"     : "\u{0396}",
                "eta"      : "\u{03b7}",
                "Eta"      : "\u{0397}",
                "theta"    : "\u{03b8}",
                "iota"     : "\u{03b9}",
                "Iota"     : "\u{0399}",
                "kappa"    : "\u{03ba}",
                "Kappa"    : "\u{039a}",
                "lambda"   : "\u{03bb}",
                "mu"       : "\u{03bc}",
                "Mu"       : "\u{039c}",
                "nu"       : "\u{03bd}",
                "Nu"       : "\u{039d}",
                "xi"       : "\u{03be}",
                "omicron"  : "\u{03bf}",
                "Omicron"  : "\u{039f}",
                "pi"       : "\u{03c0}",
                "Pi"       : "\u{03a0}",
                "rho"      : "\u{03c1}",
                "Rho"      : "\u{03a1}",
                "sigmaf"   : "\u{03c2}",
                "sigma"    : "\u{03c3}",
                "tau"      : "\u{03c4}",
                "Tau"      : "\u{03a4}",
                "upsilon"  : "\u{03c5}",
                "phi"      : "\u{03c6}",
                "chi"      : "\u{03c7}",
                "Chi"      : "\u{03a7}",
                "psi"      : "\u{03c8}",
                "omega"    : "\u{03c9}",
                "thetasym" : "\u{03d1}",
                "upsih"    : "\u{03d2}",
                "piv"      : "\u{03d6}",
                "ensp"     : "\u{2002}",
                "emsp"     : "\u{2003}",
                "thinsp"   : "\u{2009}",
                "ndash"    : "\u{2013}",
                "mdash"    : "\u{2014}",
                "lsquo"    : "\u{2018}",
                "rsquo"    : "\u{2019}",
                "sbquo"    : "\u{201a}",
                "bsquo"    : "\u{201a}",
                "ldquo"    : "\u{201c}",
                "rdquo"    : "\u{201d}",
                "bdquo"    : "\u{201e}",
                "dagger"   : "\u{2020}",
                "Dagger"   : "\u{2021}",
                "bull"     : "\u{2022}",
                "hellip"   : "\u{2026}",
                "permil"   : "\u{2030}",
                "prime"    : "\u{2032}",
                "Prime"    : "\u{2033}",
                "lsaquo"   : "\u{2039}",
                "rsaquo"   : "\u{203a}",
                "oline"    : "\u{203e}",
                "frasl"    : "\u{2044}",
                "euro"     : "\u{20ac}",
                "image"    : "\u{2111}",
                "weierp"   : "\u{2118}",
                "real"     : "\u{211c}",
                "trade"    : "\u{2122}",
                "alefsym"  : "\u{2135}",
                "larr"     : "\u{2190}",
                "uarr"     : "\u{2191}",
                "rarr"     : "\u{2192}",
                "darr"     : "\u{2193}",
                "harr"     : "\u{2194}",
                "crarr"    : "\u{21b5}",
                "lArr"     : "\u{21d0}",
                "uArr"     : "\u{21d1}",
                "rArr"     : "\u{21d2}",
                "dArr"     : "\u{21d3}",
                "hArr"     : "\u{21d4}",
                "forall"   : "\u{2200}",
                "part"     : "\u{2202}",
                "exist"    : "\u{2203}",
                "empty"    : "\u{2205}",
                "nabla"    : "\u{2207}",
                "isin"     : "\u{2208}",
                "notin"    : "\u{2209}",
                "ni"       : "\u{220b}",
                "prod"     : "\u{220f}",
                "sum"      : "\u{2211}",
                "minus"    : "\u{2212}",
                "lowast"   : "\u{2217}",
                "radic"    : "\u{221a}",
                "prop"     : "\u{221d}",
                "infin"    : "\u{221e}",
                "ang"      : "\u{2220}",
                "and"      : "\u{2227}",
                "or"       : "\u{2228}",
                "cap"      : "\u{2229}",
                "cup"      : "\u{222a}",
                "int"      : "\u{222b}",
                "there4"   : "\u{2234}",
                "sim"      : "\u{223c}",
                "cong"     : "\u{2245}",
                "asymp"    : "\u{2248}",
                "ne"       : "\u{2260}",
                "equiv"    : "\u{2261}",
                "le"       : "\u{2264}",
                "ge"       : "\u{2265}",
                "sub"      : "\u{2282}",
                "sup"      : "\u{2283}",
                "nsub"     : "\u{2284}",
                "sube"     : "\u{2286}",
                "supe"     : "\u{2287}",
                "oplus"    : "\u{2295}",
                "otimes"   : "\u{2297}",
                "perp"     : "\u{22a5}",
                "sdot"     : "\u{22c5}",
                "lceil"    : "\u{2308}",
                "rceil"    : "\u{2309}",
                "lfloor"   : "\u{230a}",
                "rfloor"   : "\u{230b}",
                "lang"     : "\u{27e8}",
                "rang"     : "\u{27e9}",
                "loz"      : "\u{25ca}",
                "spades"   : "\u{2660}",
                "clubs"    : "\u{2663}",
                "hearts"   : "\u{2665}",
                "diams"    : "\u{2666}",
            ]
        }

        let scanner = NSScanner(string: self)
        scanner.charactersToBeSkipped = nil
        var entitiesDecoded = ""

        while !scanner.atEnd {
            var scanned : NSString?

            if scanner.scanUpToString("&", intoString:&scanned) {
                entitiesDecoded += scanned!
            }

            if scanner.scanString("&", intoString: nil) {
                var afterAmpersandPtr : NSString?
                if scanner.scanUpToString(";", intoString: &afterAmpersandPtr) {
                    let afterAmpersand = afterAmpersandPtr!

                    if scanner.scanString(";", intoString: nil)  {
                        if afterAmpersand.hasPrefix("#") && afterAmpersand.length <= 6 {
                            let ch = afterAmpersand.substringFromIndex(1).toInt()
                            if let ch = ch {
                                entitiesDecoded += String(format: "%C", ch)
                            }
                            else {
                                entitiesDecoded += "&"
                                entitiesDecoded += afterAmpersand
                                entitiesDecoded += ";"
                            }
                        }
                        else  {
                            let converted = entityLookup[afterAmpersand]

                            if let converted = converted {
                                entitiesDecoded += converted
                            }
                            else  {
                                // not a valid sequence
                                entitiesDecoded += "&"
                                entitiesDecoded += afterAmpersand
                                entitiesDecoded += ";"
                            }
                        }

                    }
                    else  {
                        // no semicolon
                        entitiesDecoded += "&"
                        entitiesDecoded += afterAmpersand
                    }
                }
            }
        }

        return entitiesDecoded
    }
}

