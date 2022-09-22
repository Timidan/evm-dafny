include "../../dafny/util/int.dfy"
include "utils.dfy"

import opened Int

// Various tests for roundup
method {:test} RoundUpTests() {
    Assert(() => RoundUp(2,16) == 16);
    Assert(() => RoundUp(16,16) == 16);
    Assert(() => RoundUp(17,16) == 32);
    Assert(() => RoundUp(31,16) == 32);
    Assert(() => RoundUp(32,16) == 32);
    Assert(() => RoundUp(33,16) == 48);
}

// Various sanity tests for division.
method {:test} DivTests() {
    // pos-pos
    Assert(()=> Div(6,2) == 3);
    Assert(()=> Div(6,3) == 2);
    Assert(()=> Div(6,4) == 1);
    Assert(()=> Div(9,4) == 2);
    // neg-pos
    Assert(()=> Div(-6,2) == -3);
    Assert(()=> Div(-6,3) == -2);
    Assert(()=> Div(-6,4) == -1);
    Assert(()=> Div(-9,4) == -2);
    // pos-neg
    Assert(()=> Div(6,-2) == -3);
    Assert(()=> Div(6,-3) == -2);
    Assert(()=> Div(6,-4) == -1);
    Assert(()=> Div(9,-4) == -2);
    // neg-neg
    Assert(()=> Div(-6,-2) == 3);
    Assert(()=> Div(-6,-3) == 2);
    Assert(()=> Div(-6,-4) == 1);
    Assert(()=> Div(-9,-4) == 2);
}

// Various sanity tests for Remainder.
method {:test} RemTests() {
    // pos-pos
    Assert(()=> Rem(6,2) == 0);
    Assert(()=> Rem(6,3) == 0);
    Assert(()=> Rem(6,4) == 2);
    Assert(()=> Rem(9,4) == 1);
    // neg-pos
    Assert(()=> Rem(-6,2) == 0);
    Assert(()=> Rem(-6,3) == 0);
    Assert(()=> Rem(-6,4) == -2);
    Assert(()=> Rem(-9,4) == -1);
    // pos-neg
    Assert(()=> Rem(6,-2) == 0);
    Assert(()=> Rem(6,-3) == 0);
    Assert(()=> Rem(6,-4) == 2);
    Assert(()=> Rem(9,-4) == 1);
    // neg-neg
    Assert(()=> Rem(-6,-2) == 0);
    Assert(()=> Rem(-6,-3) == 0);
    Assert(()=> Rem(-6,-4) == -2);
    Assert(()=> Rem(-9,-4) == -1);
}

 // Various sanity tests for exponentiation.
method {:test} PowTests() {
    Assert(()=> Pow(2,8) == TWO_8);
    Assert(()=> Pow(2,15) == TWO_15);
    Assert(()=> Pow(2,16) == TWO_16);
    Assert(()=> Pow(2,24) == TWO_24);
    Assert(()=> Pow(2,31) == TWO_31);
    Assert(()=> Pow(2,32) == TWO_32);
    Assert(()=> Pow(2,40) == TWO_40);
    Assert(()=> Pow(2,48) == TWO_48);
    Assert(()=> Pow(2,56) == TWO_56);
    Assert(()=> Pow(2,63) == TWO_63);
    Assert(()=> Pow(2,64) == TWO_64);
    // NOTE:  I have to break the following ones up because Z3
    // cannot handle it.
    Assert(()=> Pow(2,63) * Pow(2,64) == TWO_127);
    Assert(()=> Pow(2,64) * Pow(2,64) == TWO_128);
    Assert(()=> Pow(2,64) * Pow(2,64) * Pow(2,64) * Pow(2,64) == TWO_256);
    Assert(()=> (TWO_128 / TWO_64) == TWO_64);
    Assert(()=> (TWO_256 / TWO_128) == TWO_128);
}

method {:test} NthUint8Tests() {
    Assert(()=> U16.NthUint8(0xde80,0) == 0xde);
    Assert(()=> U16.NthUint8(0xde80,1) == 0x80);
    // U32
    Assert(()=> U32.NthUint16(0x1230de80,0) == 0x1230);
    Assert(()=> U32.NthUint16(0x1230de80,1) == 0xde80);
    // U64
    Assert(()=> U64.NthUint32(0x00112233_44556677,0) == 0x00112233);
    Assert(()=> U64.NthUint32(0x00112233_44556677,1) == 0x44556677);
    // U128
    Assert(()=> U128.NthUint64(0x0011223344556677_8899AABBCCDDEEFF,0) == 0x0011223344556677);
    Assert(()=> U128.NthUint64(0x0011223344556677_8899AABBCCDDEEFF,1) == 0x8899AABBCCDDEEFF);
    // U256
    Assert(()=> U256.NthUint128(0x00112233445566778899AABBCCDDEEFF_FFEEDDCCBBAA99887766554433221100,0) == 0x00112233445566778899AABBCCDDEEFF);
    Assert(()=> U256.NthUint128(0x00112233445566778899AABBCCDDEEFF_FFEEDDCCBBAA99887766554433221100,1) == 0xFFEEDDCCBBAA99887766554433221100);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,00) == 0x00);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,01) == 0x01);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,02) == 0x02);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,03) == 0x03);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,04) == 0x04);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,05) == 0x05);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,06) == 0x06);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,07) == 0x07);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,08) == 0x08);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,09) == 0x09);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,10) == 0x0A);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,11) == 0x0B);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,12) == 0x0C);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,13) == 0x0D);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,14) == 0x0E);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,15) == 0x0F);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,16) == 0x10);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,17) == 0x11);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,18) == 0x12);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,19) == 0x13);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,20) == 0x14);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,21) == 0x15);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,22) == 0x16);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,23) == 0x17);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,24) == 0x18);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,25) == 0x19);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,26) == 0x1A);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,27) == 0x1B);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,28) == 0x1C);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,29) == 0x1D);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,30) == 0x1E);
    Assert(()=> U256.NthUint8(0x000102030405060708090A0B0C0D0E0F_101112131415161718191A1B1C1D1E1F,31) == 0x1F);
}

method {:test} ToBytesTests() {
    // U16
    Assert(()=>U16.ToBytes(0) == [0x00,0x00]);
    Assert(()=>U16.ToBytes(1) == [0x00,0x01]);
    Assert(()=>U16.ToBytes(258) == [0x01,0x02]);
    Assert(()=>U16.ToBytes(32769) == [0x80,0x01]);
    // U32
    Assert(()=>U32.ToBytes(0) == [0x00,0x00,0x00,0x00]);
    Assert(()=>U32.ToBytes(1) == [0x00,0x00,0x00,0x01]);
    Assert(()=>U32.ToBytes(258) == [0x00,0x00,0x01,0x02]);
    Assert(()=>U32.ToBytes(33554437) == [0x02,0x00,0x00,0x05]);
    // U64
    Assert(()=>U64.ToBytes(0) == [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]);
    Assert(()=>U64.ToBytes(1) == [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01]);
    Assert(()=>U64.ToBytes(258) == [0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x02]);
    Assert(()=>U64.ToBytes(33554437) == [0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x05]);
    Assert(()=>U64.ToBytes(65536 * 33554437) == [0x00,0x00,0x02,0x00,0x00,0x05,0x00,0x00]);

}

method {:test} SarTests() {
    Assert(()=>I256.Sar(4 as i256, 1 as u256) == 2);
    Assert(()=>I256.Sar(4 as i256, 2 as u256) == 1);
    Assert(()=>I256.Sar(4 as i256, 3 as u256) == 0);
    Assert(()=>I256.Sar(4 as i256, 4 as u256) == 0);
    Assert(()=>I256.Sar(15 as i256, 1 as u256) == 7);
    Assert(()=>I256.Sar(15 as i256, 2 as u256) == 3);
    Assert(()=>I256.Sar(15 as i256, 3 as u256) == 1);
    Assert(()=>I256.Sar(15 as i256, 4 as u256) == 0);
    Assert(()=>I256.Sar(90 as i256, 1 as u256) == 45);
    Assert(()=>I256.Sar(90 as i256, 2 as u256) == 22);
    Assert(()=>I256.Sar(90 as i256, 3 as u256) == 11);
    Assert(()=>I256.Sar(90 as i256, 4 as u256) == 5);
    Assert(()=>I256.Sar(-90 as i256, 1 as u256) == -45);
    Assert(()=>I256.Sar(-90 as i256, 2 as u256) == -23);
    Assert(()=>I256.Sar(-90 as i256, 3 as u256) == -12);
    Assert(()=>I256.Sar(-90 as i256, 4 as u256) == -6);
    Assert(()=>I256.Sar(-15 as i256, 1 as u256) == -8);
    Assert(()=>I256.Sar(-15 as i256, 2 as u256) == -4);
    Assert(()=>I256.Sar(-15 as i256, 3 as u256) == -2);
    Assert(()=>I256.Sar(-15 as i256, 4 as u256) == -1);
    Assert(()=>I256.Sar(-4 as i256, 1 as u256) == -2);
    Assert(()=>I256.Sar(-4 as i256, 2 as u256) == -1);
    Assert(()=>I256.Sar(-4 as i256, 3 as u256) == -1);
    Assert(()=>I256.Sar(-4 as i256, 4 as u256) == -1);
}

method {:test} Log256Tests() {
    Assert(()=> U256.Log256(0) == 0);
    Assert(()=> U256.Log256(1) == 0);
    Assert(()=> U256.Log256(0x80) == 0);
    Assert(()=> U256.Log256(0xff) == 0);
    Assert(()=> U256.Log256(0x100) == 1);
    Assert(()=> U256.Log256(0x554) == 1);
    Assert(()=> U256.Log256(0x3334) == 1);
    Assert(()=> U256.Log256(0xffff) == 1);
    Assert(()=> U256.Log256(0x1_0000) == 2);
    Assert(()=> U256.Log256(1020314) == 2);
    Assert(()=> U256.Log256(16777215) == 2);
    Assert(()=> U256.Log256(16777216) == 3);
    Assert(()=> U256.Log256(1677091272) == 3);
    Assert(()=> U256.Log256(0xffff_ffff) == 3);
    Assert(()=> U256.Log256(0x1_0000_0000) == 4);
    Assert(()=> U256.Log256(0xffff_ffff_ff) == 4);
    Assert(()=> U256.Log256(0x1_0000_0000_00) == 5);
    Assert(()=> U256.Log256(0xffff_ffff_ffff) == 5);
    Assert(()=> U256.Log256(0x1_0000_0000_0000) == 6);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ff) == 6);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_00) == 7);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff) == 7);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000) == 8);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ff) == 8);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_00) == 9);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff) == 9);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000) == 10);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ff) == 10);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_00) == 11);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff) == 11);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000) == 12);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ff) == 12);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_00) == 13);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff) == 13);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000) == 14);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ff) == 14);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_00) == 15);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) == 15);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000) == 16);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ff) == 16);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_00) == 17);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) == 17);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000) == 18);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ff) == 18);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_00) == 19);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) == 19);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000) == 20);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ff) == 20);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00) == 21);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) == 21);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000) == 22);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ff) == 22);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00) == 23);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) == 23);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000) == 24);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ff) == 24);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00) == 25);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) == 25);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000) == 26);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ff) == 26);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00) == 27);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) == 27);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000) == 28);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ff) == 28);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00) == 29);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) == 29);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000) == 30);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ff) == 30);
    Assert(()=> U256.Log256(0x1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00) == 31);
    Assert(()=> U256.Log256(0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) == 31);
}

method {:test} WordTests() {
    // ==>
    Assert(()=> Word.asI256(0) == 0);
    Assert(()=> Word.asI256(MAX_U256 as u256) == -1);
    Assert(()=> Word.asI256(MAX_I256 as u256) == (MAX_I256 as i256));
    Assert(()=> Word.asI256((MAX_I256 + 1) as u256) == (MIN_I256 as i256));
    // <==
    Assert(()=> Word.fromI256(0) == 0);
    Assert(()=> Word.fromI256(-1) == (MAX_U256 as u256));
    Assert(()=> Word.fromI256(MAX_I256 as i256) == (MAX_I256 as u256));
    Assert(()=> Word.fromI256(MIN_I256 as i256) == (TWO_255 as u256));
}
