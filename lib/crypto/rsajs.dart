library rsakeypair;
import 'dart:math' as Math;
import 'package:alm/alm.dart';

/// https://www.npmjs.com/package/rsa-keypair
///
/// Dart RSAKeyPair from js code
/// Author AlmPazel 2021
///

var biRadixBase = 2;
var biRadixBits = 16;
var bitsPerDigit = biRadixBits;
var biRadix = 1 << 16;
var biHalfRadix = biRadix >> 1;
var biRadixSquared = biRadix * biRadix;
int maxDigitVal = biRadix - 1;
var maxInteger = 9999999999999998;
var maxDigits;
List<int> ZERO_ARRAY;
var bigZero, bigOne;

var highBitMasks = [0x0000, 0x8000, 0xC000, 0xE000, 0xF000, 0xF800, 0xFC00, 0xFE00, 0xFF00, 0xFF80, 0xFFC0, 0xFFE0, 0xFFF0, 0xFFF8, 0xFFFC, 0xFFFE, 0xFFFF];
var lowBitMasks = [0x0000, 0x0001, 0x0003, 0x0007, 0x000F, 0x001F, 0x003F, 0x007F, 0x00FF, 0x01FF, 0x03FF, 0x07FF, 0x0FFF, 0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF];
var hexatrigesimalToChar = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];
var hexToChar = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'];

int Number(bool ihh) {
  return ihh ? 1 : 0;
}

class BigInt {
  var digits = <int>[];
  bool isNeg;

  BigInt([bool flag]) {
    if (flag.isNotNull && flag == true) {
      this.digits = [];
    } else {
      this.digits = ZERO_ARRAY.slice(0);
    }
    this.isNeg = false;
  }

  @override
  String toString() {
    return 'BigInt{digits: $digits,isNeg:$isNeg}';
  }
}

BigInt biFromHex(String s) {
  var result = new BigInt();
  var hexInts = s.reversed.chunck(len: 4);
  hexInts.length.loop((i) {
    result.digits[i] = int.tryParse(hexInts[i].reversed, radix: 16) ?? 0;
  });
  return result;
}

void setMaxDigits(value) {
  maxDigits = value;
  ZERO_ARRAY = new List(maxDigits);
  for (var iza = 0; iza < ZERO_ARRAY.length; iza++) ZERO_ARRAY[iza] = 0;
  bigZero = new BigInt();
  bigOne = new BigInt();
  bigOne.digits[0] = 1;
}

var dpl10 = 15;
var lr10 = biFromNumber(1000000000000000);

BigInt biCopy(BigInt bi) {
  var result = new BigInt(true);
  result.digits = bi.digits.slice(0);
  result.isNeg = bi.isNeg;
  return result;
}

BigInt biFromNumber(num i) {
  var result = new BigInt();
  result.isNeg = i < 0;
  var j = 0;
  while (i > 0) {
    result.digits[j++] = maxDigitVal & i;
    i = (i / biRadix).floor();
  }
  return result;
}

int biHighIndex(BigInt x) {
  var result = x.digits.length - 1;
  while (result > 0 && x.digits[result] == 0) --result;
  return result;
}

BigInt biAdd(BigInt x, BigInt y) {
  var result;
  if (x.isNeg != y.isNeg) {
    y.isNeg = !y.isNeg;
    result = biSubtract(x, y);
    y.isNeg = !y.isNeg;
  } else {
    result = new BigInt();
    var c = 0;
    var n;
    for (var i = 0; i < x.digits.length; ++i) {
      n = x.digits[i] + y.digits[i] + c;
      result.digits[i] = n % biRadix;
      c = Number(n >= biRadix);
    }
    result.isNeg = x.isNeg;
  }
  return result;
}

BigInt biSubtract(BigInt x, BigInt y) {
  var result;
  if (x.isNeg != y.isNeg) {
    y.isNeg = !y.isNeg;
    result = biAdd(x, y);
    y.isNeg = !y.isNeg;
  } else {
    result = new BigInt();
    var n, c;
    c = 0;
    for (var i = 0; i < x.digits.length; ++i) {
      n = x.digits[i] - y.digits[i] + c;
      result.digits[i] = n % biRadix;
      // Stupid non-conforming modulus operation.
      if (result.digits[i] < 0) result.digits[i] += biRadix;
      c = 0 - Number(n < 0);
    }
    // Fix up the negative sign, if any.
    if (c == -1) {
      c = 0;
      for (var i = 0; i < x.digits.length; ++i) {
        n = 0 - result.digits[i] + c;
        result.digits[i] = n % biRadix;
        // Stupid non-conforming modulus operation.
        if (result.digits[i] < 0) result.digits[i] += biRadix;
        c = 0 - Number(n < 0);
      }
      // Result is opposite sign of arguments.
      result.isNeg = !x.isNeg;
    } else {
      // Result is same sign.
      result.isNeg = x.isNeg;
    }
  }
  return result;
}

num biNumBits(BigInt x) {
  var n = biHighIndex(x);
  var d = x.digits[n];
  var m = (n + 1) * bitsPerDigit;
  var result;
  for (result = m; result > m - bitsPerDigit; --result) {
    if ((d & 0x8000) != 0) break;
    d <<= 1;
  }
  return result;
}

BigInt biMultiply(BigInt x, BigInt y) {
  var result = new BigInt();
  var c;
  var n = biHighIndex(x);
  var t = biHighIndex(y);
  var uv, k;
  for (var i = 0; i <= t; ++i) {
    c = 0;
    k = i;
    for (var j = 0; j <= n; ++j, ++k) {
      uv = result.digits[k] + x.digits[j] * y.digits[i] + c;
      result.digits[k] = uv & maxDigitVal;
      c = uv >> biRadixBits;
    }
    result.digits[i + n + 1] = c;
  }
  // Someone give me a logical xor, please.
  result.isNeg = x.isNeg != y.isNeg;
  return result;
}

BigInt biMultiplyDigit(BigInt x, num y) {
  var n, c, uv;
  var result = new BigInt();
  n = biHighIndex(x);
  c = 0;
  for (var j = 0; j <= n; ++j) {
    uv = result.digits[j] + x.digits[j] * y + c;
    result.digits[j] = uv & maxDigitVal;
    c = uv >> biRadixBits;
    //c = Math.floor(uv / biRadix);
  }
  result.digits[1 + n] = c;
  return result;
}

BigInt biShiftLeft(BigInt x, num n) {
  var digitCount = (n / bitsPerDigit).floor();
  var result = new BigInt();
  arrayCopy(x.digits, 0, result.digits, digitCount, result.digits.length - digitCount);
  var bits = n % bitsPerDigit;
  var rightBits = bitsPerDigit - bits;
  int i = (result.digits.length - 1), i1;
  for (i1 = i - 1; i > 0; --i, --i1) {
    result.digits[i] = ((result.digits[i] << bits) & maxDigitVal) | ((result.digits[i1] & highBitMasks[bits]) >> (rightBits));
  }
  result.digits[0] = ((result.digits[i] << bits) & maxDigitVal);
  result.isNeg = x.isNeg;
  return result;
}

void arrayCopy(List<dynamic> src, int srcStart, List<dynamic> dest, int destStart, int n) {
  var m = Math.min(srcStart + n, src.length);
  for (var i = srcStart, j = destStart; i < m; ++i, ++j) {
    dest[j] = src[i];
  }
}

BigInt biShiftRight(BigInt x, num n) {
  var digitCount = (n / bitsPerDigit).floor();
  var result = new BigInt();
  arrayCopy(x.digits, digitCount, result.digits, 0, x.digits.length - digitCount);
  var bits = n % bitsPerDigit;
  var leftBits = bitsPerDigit - bits;
  for (var i = 0, i1 = i + 1; i < result.digits.length - 1; ++i, ++i1) {
    result.digits[i] = (result.digits[i] >> bits) | ((result.digits[i1] & lowBitMasks[bits]) << leftBits);
  }
  result.digits[result.digits.length - 1] >>= bits;
  result.isNeg = x.isNeg;
  return result;
}

BigInt biMultiplyByRadixPower(BigInt x, num n) {
  var result = new BigInt();
  arrayCopy(x.digits, 0, result.digits, n, result.digits.length - n);
  return result;
}

BigInt biDivideByRadixPower(BigInt x, num n) {
  var result = new BigInt();
  arrayCopy(x.digits, n, result.digits, 0, result.digits.length - n);
  return result;
}

BigInt biModuloByRadixPower(BigInt x, num n) {
  var result = new BigInt();
  arrayCopy(x.digits, 0, result.digits, 0, n);
  return result;
}

num biCompare(BigInt x, BigInt y) {
  if (x.isNeg != y.isNeg) {
    return 1 - 2 * Number(x.isNeg);
  }
  for (var i = x.digits.length - 1; i >= 0; --i) {
    if (x.digits[i] != y.digits[i]) {
      if (x.isNeg) {
        return 1 - 2 * Number(x.digits[i] > y.digits[i]);
      } else {
        return 1 - 2 * Number(x.digits[i] < y.digits[i]);
      }
    }
  }
  return 0;
}

List<BigInt> biDivideModulo(BigInt x, BigInt y) {
  var nb = biNumBits(x);
  var tb = biNumBits(y);
  var origYIsNeg = y.isNeg;
  BigInt q, r;
  if (nb < tb) {
    // |x| < |y|
    if (x.isNeg) {
      q = biCopy(bigOne);
      q.isNeg = !y.isNeg;
      x.isNeg = false;
      y.isNeg = false;
      r = biSubtract(y, x);
      // Restore signs, 'cause they're references.
      x.isNeg = true;
      y.isNeg = origYIsNeg;
    } else {
      q = new BigInt();
      r = biCopy(x);
    }
    return [q, r];
  }

  q = new BigInt();
  r = x;
  // Normalize Y.
  int t = (tb / bitsPerDigit).ceil() - 1;
  int lambda = 0;
  while (y.digits[t] < biHalfRadix) {
    y = biShiftLeft(y, 1);
    ++lambda;
    ++tb;
    t = (tb / bitsPerDigit).ceil() - 1;
  }
  // Shift r over to keep the quotient constant. We'll shift the
  // remainder back at the end.
  r = biShiftLeft(r, lambda);
  nb += lambda; // Update the bit count for x.
  var n = (nb / bitsPerDigit).ceil() - 1;

  var b = biMultiplyByRadixPower(y, n - t);
  while (biCompare(r, b) != -1) {
    ++q.digits[n - t];
    r = biSubtract(r, b);
  }
  for (var i = n; i > t; --i) {
    var ri = (i >= r.digits.length) ? 0 : r.digits[i];
    var ri1 = (i - 1 >= r.digits.length) ? 0 : r.digits[i - 1];
    var ri2 = (i - 2 >= r.digits.length) ? 0 : r.digits[i - 2];
    var yt = (t >= y.digits.length) ? 0 : y.digits[t];
    var yt1 = (t - 1 >= y.digits.length) ? 0 : y.digits[t - 1];
    if (ri == yt) {
      q.digits[i - t - 1] = maxDigitVal;
    } else {
      q.digits[i - t - 1] = (((ri * biRadix + ri1) / yt)).floor();
    }

    var c1 = q.digits[i - t - 1] * ((yt * biRadix) + yt1);
    var c2 = (ri * biRadixSquared) + ((ri1 * biRadix) + ri2);
    while (c1 > c2) {
      --q.digits[i - t - 1];
      c1 = q.digits[i - t - 1] * ((yt * biRadix) | yt1);
      c2 = (ri * biRadix * biRadix) + ((ri1 * biRadix) + ri2);
    }

    b = biMultiplyByRadixPower(y, i - t - 1);
    r = biSubtract(r, biMultiplyDigit(b, q.digits[i - t - 1]));
    if (r.isNeg) {
      r = biAdd(r, b);
      --q.digits[i - t - 1];
    }
  }
  r = biShiftRight(r, lambda);
  // Fiddle with the signs and stuff to make sure that 0 <= r < y.
  q.isNeg = x.isNeg != origYIsNeg;
  if (x.isNeg) {
    if (origYIsNeg) {
      q = biAdd(q, bigOne);
    } else {
      q = biSubtract(q, bigOne);
    }
    y = biShiftRight(y, lambda);
    r = biSubtract(y, r);
  }
  // Check for the unbelievably stupid degenerate case of r == -0.
  if (r.digits[0] == 0 && biHighIndex(r) == 0) r.isNeg = false;

  return [q, r];
}

BigInt biDivide(BigInt x, BigInt y) {
  return biDivideModulo(x, y)[0];
}

BigInt biModulo(BigInt x, BigInt y) {
  return biDivideModulo(x, y)[1];
}

BigInt biMultiplyMod(BigInt x, BigInt y, BigInt m) {
  return biModulo(biMultiply(x, y), m);
}

BigInt biPow(BigInt x, int y) {
  var result = bigOne;
  var a = x;
  while (true) {
    if ((y & 1) != 0) result = biMultiply(result, a);
    y >>= 1;
    if (y == 0) break;
    a = biMultiply(a, a);
  }
  return result;
}

BigInt biPowMod(BigInt x, BigInt y, BigInt m) {
  var result = bigOne;
  var a = x;
  var k = y;
  while (true) {
    if ((k.digits[0] & 1) != 0) result = biMultiplyMod(result, a, m);
    k = biShiftRight(k, 1);
    if (k.digits[0] == 0 && biHighIndex(k) == 0) break;
    a = biMultiplyMod(a, a, m);
  }
  return result;
}

String digitToHex(n) {
  var mask = 0xf;
  var result = "";
  for (var i = 0; i < 4; ++i) {
    result += hexToChar[n & mask];
    n >>= 4;
  }
  var reverseStr = (String s) {
    var result = "";
    for (var i = s.length - 1; i > -1; --i) {
      result += s[i];
    }
    return result;
  };
  return reverseStr(result);
}

String biToHex(BigInt x) {
  var result = "";
  var n = biHighIndex(x);
  for (var i = biHighIndex(x); i > -1; --i) {
    result += digitToHex(x.digits[i]);
  }
  return result;
}

num charToHex(c) {
  var ZERO = 48;
  var NINE = ZERO + 9;
  var littleA = 97;
  var littleZ = littleA + 25;
  var bigA = 65;
  var bigZ = 65 + 25;
  var result;

  if (c >= ZERO && c <= NINE) {
    result = c - ZERO;
  } else if (c >= bigA && c <= bigZ) {
    result = 10 + c - bigA;
  } else if (c >= littleA && c <= littleZ) {
    result = 10 + c - littleA;
  } else {
    result = 0;
  }
  return result;
}

int hexToDigit(String s) {
  var result = 0;
  var sl = Math.min(s.length, 4);
  for (var i = 0; i < sl; ++i) {
    result <<= 4;
    result |= charToHex(s.codeUnitAt(i));
  }
  return result;
}

class RSAKeyPair {
  BigInt modulus;
  BigInt exponent;
  int k = 64;
  BigInt mu;
  BigInt bkplus1;

  RSAKeyPair(String modulus, String exponent,{int maxSize=131}) {
    setMaxDigits(maxSize);
    this.modulus = biFromHex(modulus);
    this.exponent = biFromHex(exponent);
    var b2k = new BigInt();
    b2k.digits[2 * this.k] = 1; // b2k = b^(2k)
    this.mu = biDivide(b2k, this.modulus);
    this.bkplus1 = new BigInt();
    this.bkplus1.digits[this.k + 1] = 1; // bkplus1 = b^(k+1)
  }

  BigInt modulo(x) {
    var q1 = biDivideByRadixPower(x, this.k - 1);
    var q2 = biMultiply(q1, this.mu);
    var q3 = biDivideByRadixPower(q2, this.k + 1);
    var r1 = biModuloByRadixPower(x, this.k + 1);
    var r2term = biMultiply(q3, this.modulus);
    var r2 = biModuloByRadixPower(r2term, this.k + 1);
    var r = biSubtract(r1, r2);
    if (r.isNeg) {
      r = biAdd(r, this.bkplus1);
    }
    var rgtem = biCompare(r, this.modulus) >= 0;
    while (rgtem) {
      r = biSubtract(r, this.modulus);
      rgtem = biCompare(r, this.modulus) >= 0;
    }
    return r;
  }

  BigInt multiplyMod(BigInt x, BigInt y) {
    var xy = biMultiply(x, y);
    var xyn = this.modulo(xy);
    return xyn;
  }

  String encryptedString(String msg) {
    var result = new BigInt();
    result.digits[0] = 1;
    var a = biFromHex(msg.reversed.toHex());
    var k = this.exponent;
    while (true) {
      if ((k.digits[0] & 1) != 0) result = this.multiplyMod(result, a);
      k = biShiftRight(k, 1);
      if (k.digits[0] == 0 && biHighIndex(k) == 0) break;
      a = this.multiplyMod(a, a);
    }
    return biToHex(result);
  }
}
