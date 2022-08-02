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

include "../../dafny/evm.dfy" 
include "../../dafny/evms/berlin.dfy"
include "../../dafny/util/context.dfy"

module Test10Gas {

    import opened Int
    import opened Opcode
    import opened Bytecode 
    import opened EvmBerlin
    import Context
    import opened Gas
    import Stack

    // Arbitrary limit for now
    const GASLIMIT : nat := 100;

    /**
     *   A very simple program manipulating the stack.
     *
     */
    method main1(g: nat) 
        requires g >= 2*G_VERYLOW + 2*G_LOW
    {
        // Initialise VM
        var vm := InitEmpty(g);

        var a: u8 := 0x01;
        var b: u8 := 0x02;

        ghost var st1 := vm.GetStack();

        vm := Push1(vm, a).UseGas(G_VERYLOW); 
        vm := Push1(vm, b).UseGas(G_VERYLOW);
        vm := Add(vm).UseGas(G_LOW);
        assert vm.Gas() == g - (2 * G_VERYLOW + G_LOW);

        assert vm.Peek(0) as nat == (a + b) as nat; 

        vm := Pop(vm).UseGas(G_LOW); 
        assert vm.GetStack() == st1; 
    }

    /**
     *  A loop.
     */
    method main2(c: u8, g: nat) 
        requires g >= c as nat * (3 * G_VERYLOW + G_BASE)
    {
        // Initialise VM
        var vm := InitEmpty(g);
        var a: u8 := 0x01;
        var b : u8 := 0x02;
        var count: u8 := c;

        ghost var st := vm.GetStack();

        while count > 0 
            invariant !vm.IsFailure()
            invariant  vm.GetStack() == st 
            invariant vm.Gas() >= count as nat * (3 * G_VERYLOW + G_BASE)
        {
            vm := Push1(vm, a).UseGas(G_VERYLOW);
            vm := Push1(vm, b).UseGas(G_VERYLOW);
            vm := Add(vm).UseGas(G_VERYLOW);
            vm := Pop(vm).UseGas(G_BASE);
            count := count - 1 ;
        }
        assert vm.GetStack() == st;
    }

    /**
     *  Compute cout := count - 1 with the stack.
     *  In this first implementation we use a variant of SUB, subR
     *  that computes stack1 - stack0 instead of stack0 - stack1.
     */
    method main3(c: u8, g: nat) 
        requires g >= G_VERYLOW + c as nat * (6*G_VERYLOW + G_BASE)
    {
        var a: u8 := 0x01;
        var b : u8 := 0x02;

        // Initialise Bytecode
        var vm := InitEmpty(g);

        vm := Push1(vm, c).UseGas(G_VERYLOW);
        ghost var count : u256 := c as u256;

        assert count == vm.Peek(0);

        while vm.Peek(0) > 0 
            invariant !vm.IsFailure()
            invariant Stack.Size(vm.GetStack()) > 0  
            invariant count == vm.Peek(0)
            invariant vm.GetStack() == Stack.Make([count])
            invariant vm.Gas() >= count as nat * (6*G_VERYLOW + G_BASE)
        {
            vm := Push1(vm, a).UseGas(G_VERYLOW);
            vm := Push1(vm, b).UseGas(G_VERYLOW);
            vm := Add(vm).UseGas(G_VERYLOW);
            vm := Pop(vm).UseGas(G_BASE);

            //  count := count - 1 ;
            vm := Push1(vm, 0x1).UseGas(G_VERYLOW);
            vm := Swap(vm, 1).UseGas(G_VERYLOW);
            vm := Sub(vm).UseGas(G_VERYLOW);
            count := count - 1;
        }
        assert count == 0;
        assert vm.GetStack() == Stack.Make([0]);
    }

    /**
     *  Test top of stack with LT/GT
     *  instead of count > 0.
     */
    method main5(c: u8, g: nat)  
        requires g >= G_BASE + 4 * G_VERYLOW + c as nat * (2 * G_BASE + 9 * G_VERYLOW)
    {
        // Initialise Bytecode
        var vm := InitEmpty(g);
        
        var a: u8 := 0x01;
        var b : u8 := 0x02;

        vm := Push1(vm, c).UseGas(G_VERYLOW);
        ghost var g := vm.GetStack();
        ghost var count := c as u256;

        assert vm.GetStack() == Stack.Make([count]);

        //  compute count > 0 

        //  top of the stack has the result of count > 0
        //  push 0, then duplicate second element on top
        vm := Push1(vm, 0x0).UseGas(G_VERYLOW);
        vm := Dup(vm, 2).UseGas(G_VERYLOW);
        assert vm.GetStack() == Stack.Make([count, 0, count]);

        //  compute stack[0] > stack[1]
        vm := Gt(vm).UseGas(G_VERYLOW);
        assert vm.GetStack() == Stack.Make([if count > 0 then 1 else 0, count]);

        assert count == vm.Peek(1); 

        while vm.Peek(0) > 0 
            invariant !vm.IsFailure()
            invariant Stack.Size(vm.GetStack()) == 2 
            invariant count == vm.Peek(1)
            invariant count == vm.Peek(1) >= 0
            invariant vm.Peek(0) > 0 <==> count > 0
            invariant vm.Gas() >= G_BASE + count as nat * (2 * G_BASE + 9 * G_VERYLOW)

            decreases count
        {
            //  top of the stack is the last result of stack[0] > stack[1]
            vm := Pop(vm).UseGas(G_BASE);
            assert vm.GetStack() == Stack.Make([count]);

            //  a + b and discard result
            vm := Push1(vm, a).UseGas(G_VERYLOW);
            vm := Push1(vm, b).UseGas(G_VERYLOW);
            vm := Add(vm).UseGas(G_VERYLOW);
            vm := Pop(vm).UseGas(G_BASE);

            assert count == vm.Peek(0) ;
            assert count > 0;
            //  count := count - 1 ;
            vm := Push1(vm, 0x1).UseGas(G_VERYLOW);
            vm := Swap(vm, 1).UseGas(G_VERYLOW);
            assert vm.GetStack() == Stack.Make([count, 1]);

            vm := Sub(vm).UseGas(G_VERYLOW);
            assert vm.GetStack() == Stack.Make([count - 1]);

            //  prepare comparison count > 0. count is at the top
            vm := Push1(vm, 0x0).UseGas(G_VERYLOW);
            vm := Dup(vm, 2).UseGas(G_VERYLOW);
            assert vm.GetStack() == Stack.Make([count - 1, 0, count - 1]);

            //  compute stack[0] > stack[1]
            vm := Gt(vm).UseGas(G_VERYLOW);   
            assert vm.GetStack() == Stack.Make([if count - 1 > 0 then 1 else 0, count - 1]);
            count := count - 1;
        }
        assert vm.Gas() >= G_BASE;
        assert count == vm.Peek(1);
        vm := Pop(vm).UseGas(G_BASE);
        assert vm.Gas() >= 0;
        assert count == vm.Peek(0);
        assert count == 0;
        assert Stack.Size(vm.GetStack()) == 1;
        assert vm.GetStack() == Stack.Make([0]);
    }

}