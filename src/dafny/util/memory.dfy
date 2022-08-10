/*
 * Copyright 2022 ConsenSys Software Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License. You may obtain
 * a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software dis-
 * tributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
include "int.dfy"
include "bytes.dfy"

/**
 * Memory on the EVM is a byte-addressable (volatile) random access memory.
 */
module Memory {
    import opened Int
    import U256
    import opened Bytes

    // =============================================================================
    // Random Access Memory
    // =============================================================================

    datatype T = Memory(contents:seq<u8>)

    /**
     * Create a memory from an initial sequence of words.
     */
    function method Create() : T {
        Memory(contents:=[])
    }

    /**
     * Return size of memory (in bytes).
     */
    function method Size(mem:T) : nat { |mem.contents| }

    /**
     * Expand memory to include the given address.  Note that the EVM dictates that
     * expansion happens in multiples of 32bytes.
     */
    function method Expand(mem:T, address: nat, length: nat) : T 
      ensures |Expand(mem, address, length).contents| >= address as nat + length
    {
        // Round up size to multiple of 32. 
        var rounded := RoundUp((address as nat)+length,32);
        var diff := rounded - |mem.contents|;
        if diff > 0
        then
            // Expand memory
            mem.(contents := mem.contents + Padding(diff))
        else
            // Do nothing
            mem
    }

    /** Expand memory size if needed.
     *
     *  @param  mem     A memory representation.
     *  @param  address An address to read (an u8) in memory.
     *  @returns        The smallest extension of `mem` that contains `address`
     *                  and has a multiple of 32 bytes elements. 
     *
     *  @note           At the end, `address` should be a valid index of `r` 
     *                  i.e. in 0..(r.size - 1).
     */
    function method Expand2(mem: T, address: nat) : (r: T) 
      ensures |r.contents| > address 
      ensures address >= |mem.contents| ==> 
        (|r.contents| % 32 == 0 &&  |r.contents| - 32 <= address)
    {
        if address < |mem.contents| then 
          mem
        else 
          var extLength := SmallestLarg32(address);
          mem.(contents := mem.contents + Padding(extLength - |mem.contents|))
    }

    /** Smallest number multiple of 32 that is larger than k. */
    function method SmallestLarg32(k: nat): (x:nat)
      ensures x > k
      ensures x % 32 == 0
      ensures (x - 32) <= k
    {
      (k / 32 + 1) * 32
    }

    /**
     * Read the byte at a given address in Memory.  If the given location
     * has not been initialised, then zero is returned as default.
     */
    function method ReadUint8(mem:T, address:nat) : u8 {
        // Read location
        if address < |mem.contents|
        then
          mem.contents[address]
        else
          0
    }

    /**
     * Read a 16bit word from a given address in Memory assuming
     * big-endian addressing.
     */
    function method ReadUint16(mem:T, address:nat) : u16
      requires address + 1 < |mem.contents| {
        var w1 := ReadUint8(mem,address) as u16;
        var w2 := ReadUint8(mem,address+1) as u16;
        (w1 * (TWO_8 as u16)) + w2
    }

    /**
     * Read a 32bit word from a given address in Memory assuming
     * big-endian addressing.
     */
    function method ReadUint32(mem:T, address:nat) : u32
      requires address + 3 < |mem.contents| {
        var w1 := ReadUint16(mem,address) as u32;
        var w2 := ReadUint16(mem,address+2) as u32;
        (w1 * (TWO_16 as u32)) + w2
    }

    /**
     * Read a 64bit word from a given address in Memory assuming
     * big-endian addressing.
     */
    function method ReadUint64(mem:T, address:nat) : u64
      requires address + 7 < |mem.contents| {
        var w1 := ReadUint32(mem,address) as u64;
        var w2 := ReadUint32(mem,address+4) as u64;
        (w1 * (TWO_32 as u64)) + w2
    }

    /**
     * Read a 128bit word from a given address in Memory assuming
     * big-endian addressing.
     */
    function method ReadUint128(mem:T, address:nat) : u128
      requires address + 15 < |mem.contents| {
        var w1 := ReadUint64(mem,address) as u128;
        var w2 := ReadUint64(mem,address+8) as u128;
        (w1 * (TWO_64 as u128)) + w2
    }

    /**
     * Read a 256bit word from a given address in Memory assuming
     * big-endian addressing.
     */
    function method ReadUint256(mem:T, address:nat) : u256
      requires address + 31 < |mem.contents| {
        var w1 := ReadUint128(mem,address) as u256;
        var w2 := ReadUint128(mem,address+16) as u256;
        (w1 * (TWO_128 as u256)) + w2
    }

    /**
     * Write a byte to a given address in Memory.
     */

    function method WriteUint8(mem:T, address:nat, val:u8) : T
        requires address < |mem.contents| {
        // Update size calc.
        // Write location
        Memory(contents:=mem.contents[address:=val])
    }

    /**
     * Write a 16bit word to a given address in Memory using
     * big-endian addressing.
     */
    function method WriteUint16(mem:T, address:nat, val:u16) : T
    requires address + 1 < |mem.contents| {
      var w1 := val / (TWO_8 as u16);
      var w2 := val % (TWO_8 as u16);
      var mem' := WriteUint8(mem,address,w1 as u8);
      WriteUint8(mem',address+1,w2 as u8)
    }

    /**
     * Write a 32bit word to a given address in Memory using
     * big-endian addressing.
     */
    function method WriteUint32(mem:T, address:nat, val:u32) : T
    requires address + 3 < |mem.contents| {
      var w1 := val / (TWO_16 as u32);
      var w2 := val % (TWO_16 as u32);
      var mem' := WriteUint16(mem,address,w1 as u16);
      WriteUint16(mem',address+2,w2 as u16)
    }

    /**
     * Write a 64bit word to a given address in Memory using
     * big-endian addressing.
     */
    function method WriteUint64(mem:T, address:nat, val:u64) : T
    requires address + 7 < |mem.contents| {
      var w1 := val / (TWO_32 as u64);
      var w2 := val % (TWO_32 as u64);
      var mem' := WriteUint32(mem,address,w1 as u32);
      WriteUint32(mem',address+4,w2 as u32)
    }

    /**
     * Write a 128bit word to a given address in Memory using
     * big-endian addressing.
     */
    function method WriteUint128(mem:T, address:nat, val:u128) : T
    requires address + 15 < |mem.contents| {
      var w1 := val / (TWO_64 as u128);
      var w2 := val % (TWO_64 as u128);
      var mem' := WriteUint64(mem,address,w1 as u64);
      WriteUint64(mem',address+8,w2 as u64)
    }

    /**
     * Write a 256bit word to a given address in Memory using
     * big-endian addressing.
     */
    function method WriteUint256(mem:T, address:nat, val:u256) : T
    requires address + 31 < |mem.contents| {
      var w1 := val / (TWO_128 as u256);
      var w2 := val % (TWO_128 as u256);
      var mem' := WriteUint128(mem,address,w1 as u128);
      WriteUint128(mem',address+16,w2 as u128)
    }

    /**
     * Slice out a section of memory.
     */
    function method Slice(mem:T, address:nat, len:nat) : seq<u8> {
      Bytes.Slice(mem.contents,address,len)
    }

    function method Copy(mem:T, address:nat, data:seq<u8>) : T
      requires (address + |data|) <= |mem.contents|
      decreases |data| {
        if |data| == 0 then mem
        else
          var step := WriteUint8(mem,address,data[0]);
          Copy(step,address+1,data[1..])
    }
}
